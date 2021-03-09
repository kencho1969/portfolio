<%@ page contentType="text/html;charset=UTF-8" %>
<%@ page import="java.io.*" %>
<%@ page import="java.sql.*" %>
<%@ page import="java.util.*" %>
<%@ page import="myutil.*" %>
<%!
	String _dbname = null;
%>
<%
	// iniファイルから自分のデータベース情報を読み込む
	String iniFilePath = application.getRealPath("WEB-INF/le4db.ini");
	try {
		FileInputStream fis = new FileInputStream(iniFilePath);
		Properties prop = new Properties();
		prop.load(fis);
		_dbname = prop.getProperty("dbname");
	} catch (Exception e) {
		e.printStackTrace();
	}
	String store=request.getParameter("store");
	store = store==null?"":store;
	int filter=0;
	int recept=0;
	int order=0;
	int post_opt=0;//1...recept, 2...cancel
	int update_id=0;
	try{
		filter=Integer.valueOf(request.getParameter("fil"));
		recept=Integer.valueOf(request.getParameter("rec"));
		order=Integer.valueOf(request.getParameter("ord"));
		post_opt=Integer.valueOf(request.getParameter("post_opt"));
		update_id=Integer.valueOf(request.getParameter("update_id"));
	}catch(NumberFormatException ex){}

%>
<html>
<head>
<meta charset="utf-8">
<title>○×寿司 - <%=Sanitize.forHtml(store)%>予約一覧</title>
<link rel="stylesheet" href="https://stackpath.bootstrapcdn.com/bootstrap/4.5.2/css/bootstrap.min.css" integrity="sha384-JcKb8q3iqJ61gNV9KGb8thSsNjpSL0n8PARn9HuZOnIxN0hoP+VmmDGMN5t9UJ0Z" crossorigin="anonymous">
<link rel="stylesheet" href="../default.css">
</head>
<body>
<h2><%=Sanitize.forHtml(store)%>予約一覧</h2>
<form action="reservations.jsp" method="GET">
<h4>フィルタ・並び替え</h4>
<%
	out.println("<input type='text' name='store' value='"+Sanitize.forHtml(store)+"' hidden>"); 
%>
<select name=fil>
<%
	out.println("<option value='0' "+(filter==0?"selected":"")+">時間指定+待ち</option>");
	out.println("<option value='1' "+(filter==1?"selected":"")+">時間指定予約</option>");
	out.println("<option value='2' "+(filter==2?"selected":"")+">待ち予約</option>");
%>
</select>
<select name=rec>
<%
	out.println("<option value='0' "+(recept==0?"selected":"")+">未受付</option>");
	out.println("<option value='1' "+(recept==1?"selected":"")+">受付済</option>");
%>
</select>
<select name=ord>
<%
	out.println("<option value='0' "+(order==0?"selected":"")+">予約番号昇順</option>");
	out.println("<option value='1' "+(order==1?"selected":"")+">予約番号降順</option>");
	out.println("<option value='2' "+(order==2?"selected":"")+">推奨受付順</option>");
%>
</select>
<input type='submit' value='適用'>
</form>
<%
	Class.forName("org.sqlite.JDBC");
	String dbfile = application.getRealPath("WEB-INF/" + _dbname);
	try(Connection conn = DriverManager.getConnection("jdbc:sqlite:" + dbfile)){
		if(post_opt==1||post_opt==2){
			PreparedStatement st1 = conn.prepareStatement("UPDATE reservation SET recept=? WHERE store=? AND reserve_id=?");
			PreparedStatement st2 = conn.prepareStatement("UPDATE waiting SET recept=? WHERE store=? AND reserve_id=?");
			st1.setInt(1, 2-post_opt);
			st2.setInt(1, 2-post_opt);
			st1.setString(2, store);
			st2.setString(2, store);
			st1.setInt(3, update_id);
			st2.setInt(3, update_id);
			int row_num1=st1.executeUpdate();
			int row_num2=st2.executeUpdate();
			if(row_num1+row_num2>1){
				System.err.println("Suspicious update detected in "+row_num1+" rows(reservation) and "+row_num2+" rows(waiting).");
			}
		}
		if(order==2&&recept==0&&filter==0){
			PreparedStatement st = conn.prepareStatement("SELECT capacity_all FROM store WHERE name=?");
			st.setString(1, store);
			ResultSet rs = st.executeQuery();
			rs.next();
			int capacity=rs.getInt("capacity_all");
			PreparedStatement st1 = conn.prepareStatement("SELECT reserve_id, time, name, number FROM reservation WHERE store=? AND recept=0 ORDER BY reserve_id ASC");
			PreparedStatement st2 = conn.prepareStatement("SELECT reserve_id, -1 AS time, name, number FROM waiting WHERE store=? AND recept=0 ORDER BY reserve_id ASC");
			st1.setString(1, store);
			st2.setString(1, store);
			try (ResultSet reservations = st1.executeQuery(); ResultSet waitings = st2.executeQuery()){
				double now=MyTime.now();
				int m=(int)Math.round((now-(int)now)*capacity);
				boolean esc=false;
				boolean res_used=true;
				boolean res_closed=false;
	        	out.println("<table border=\"1\">");
	        	out.println("<tr><th>予約番号</th><th>時間</th><th>名前</th><th>人数</th></tr>");
				for(int n=(int)now;!esc;n++){
					for(;m<capacity;m++){
						if(res_used){
							res_closed=!reservations.next();
							res_used=res_closed;
						}
						if(!res_closed&&reservations.getInt("time")<=n){
							printRow(reservations, out, store, filter, recept, order);
							res_used=true;
						}else{
							if(waitings.next()){
								printRow(waitings, out, store, filter, recept, order);
							}else{
								if(!res_used){
									printRow(reservations, out, store, filter, recept, order);
								}
								while(reservations.next()){
									printRow(reservations, out, store, filter, recept, order);
								}
								esc=true;
								break;
							}
						}
					}
					m=0;
				}
	        	out.println("</table>");
			}
		}else{
			if(order==2){
				order=0;
			}
			String query="";
			switch(filter){
				case 1: query=
					"SELECT reserve_id, time, name, number FROM reservation WHERE store=? AND recept="+recept+
					" ORDER BY reserve_id "+(order==1?"DESC":"ASC");
					break;
				case 2: query=
					"SELECT reserve_id, -1 AS time, name, number FROM waiting WHERE store=? AND recept="+recept+
					" ORDER BY reserve_id "+(order==1?"DESC":"ASC");
					break;
				default: query=
					"SELECT reserve_id, time, name, number FROM reservation WHERE store=? AND recept="+recept+
					" UNION SELECT reserve_id, -1 AS time, name, number FROM waiting WHERE store=? AND recept="+recept+
					" ORDER BY reserve_id "+(order==1?"DESC":"ASC");
			}
			PreparedStatement st = conn.prepareStatement(query);
        	st.setString(1, store);
			if(filter!=1&&filter!=2){
        		st.setString(2, store);
			}
			try (ResultSet rs = st.executeQuery()){
	        	out.println("<table border=\"1\">");
	        	out.println("<tr><th>予約番号</th><th>時間</th><th>名前</th><th>人数</th></tr>");
				while (rs.next()) {
					printRow(rs, out, store, filter, recept, order);
				}
	        	out.println("</table>");
			}
		}
	} catch (Exception e) {
		e.printStackTrace();
	}
%>
<br>
<form action='deletereservationconfirmation.jsp'>
<input type='text' name='store' value='<%=Sanitize.forHtml(store)%>' hidden>
<input type='submit' value='予約情報を削除する'>
</form>
<a href=stores.jsp>全店管理ページに戻る</a>
<script src="https://code.jquery.com/jquery-3.3.1.slim.min.js" integrity="sha384-q8i/X+965DzO0rT7abK41JStQIAqVgRVzpbzo5smXKp4YfRvH+8abtTE1Pi6jizo" crossorigin="anonymous"></script>
<script src="https://stackpath.bootstrapcdn.com/bootstrap/4.5.2/js/bootstrap.min.js" integrity="sha384-B4gt1jrGC7Jh4AgTPSdUtOBvfO8shuf57BaghqFfPlYxofvL8/KUEfYiJOMMV+rV" crossorigin="anonymous"></script>
</body>
</html>
<%!
	private void printRow(ResultSet rs, JspWriter ps, String store, int filter, int recept, int order){
		try{
			int reserve_id = rs.getInt("reserve_id");
			int time = rs.getInt("time");
			String name = rs.getString("name");
			int number = rs.getInt("number");
			ps.println("<tr>");
			ps.println("<td>" + reserve_id + "</td>");
			ps.println("<td>" + (time<0?"--:--":String.format("%02d:%d0", time/6, time%6)) + "</td>");
			ps.println("<td>" + Sanitize.forHtml(name) + "</td>");
        	ps.println("<td>" + number + "名</td>");
			ps.println("<td><form action=\"reservations.jsp?store=" + Sanitize.forHtml(store) +"&fil="+filter+"&rec="+recept+"&ord="+order+"\" method='POST'>");
			ps.println("<input type='text' name='update_id' value='"+ reserve_id +"' hidden>");
			ps.println("<input type='text' name='post_opt' value='"+ (recept+1) +"' hidden>");
			ps.println("<input type='submit' value='"+(recept==0?"受付":"取消")+"'></form></td>");
			ps.println("</tr>");
		}catch(Exception ex){
			ex.printStackTrace();
		}
	}
%>
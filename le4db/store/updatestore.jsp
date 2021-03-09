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
	String update_name=request.getParameter("update_name");
	String update_address=request.getParameter("update_address");
	update_name = update_name==null?"":update_name;
	update_address = update_address==null?"":update_address;
    int update_open_h=0;
    int update_open_m=0;
    int update_close_h=0;
    int update_close_m=0;
    int update_capacity_all=0;
    int update_capacity_res=0;
	try{
    	update_open_h=Integer.valueOf(request.getParameter("update_open_h"));
    	update_open_m=Integer.valueOf(request.getParameter("update_open_m"));
    	update_close_h=Integer.valueOf(request.getParameter("update_close_h"));
    	update_close_m=Integer.valueOf(request.getParameter("update_close_m"));
    	update_capacity_all=Integer.valueOf(request.getParameter("update_capacity_all"));
    	update_capacity_res=Integer.valueOf(request.getParameter("update_capacity_res"));
	}catch(Exception ex){}
%>
<html>
<head>
<meta charset="utf-8">
<title>○×寿司 - 店舗情報更新</title>
<link rel="stylesheet" href="https://stackpath.bootstrapcdn.com/bootstrap/4.5.2/css/bootstrap.min.css" integrity="sha384-JcKb8q3iqJ61gNV9KGb8thSsNjpSL0n8PARn9HuZOnIxN0hoP+VmmDGMN5t9UJ0Z" crossorigin="anonymous">
<link rel="stylesheet" href="../default.css">
</head>
<body>
<h2>店舗情報更新</h2>
<%
	Class.forName("org.sqlite.JDBC");
	String dbfile = application.getRealPath("WEB-INF/" + _dbname);
	out.println("<table border=\"1\">");
    out.println("<tr><th>店舗名</th><th>"+Sanitize.forHtml(update_name)+"</th></tr>");
    out.println("<tr><th>住所</th><th>"+Sanitize.forHtml(update_address)+"</th></tr>");
    out.println("<tr><th>開店時間</th><th>"+update_open_h+"時"+update_open_m+"0分</th></tr>");
    out.println("<tr><th>店舗名</th><th>"+update_close_h+"時"+update_close_m+"0分</th></tr>");
    out.println("<tr><th>店舗容量</th><th>"+update_capacity_all+"件/10分</th></tr>");
    out.println("<tr><th>予約容量</th><th>"+update_capacity_res+"件/10分</th></tr>");
	out.println("</table>");
	try(Connection conn = DriverManager.getConnection("jdbc:sqlite:" + dbfile)){
		try{
			conn.setAutoCommit(false);
	    	PreparedStatement st1 = conn.prepareStatement("SELECT COUNT(*) FROM reservation WHERE store=?");
	    	PreparedStatement st2 = conn.prepareStatement("SELECT COUNT(*) FROM waiting WHERE store=?");
			st1.setString(1, update_name);
			st2.setString(1, update_name);
			ResultSet rs1=st1.executeQuery();
			ResultSet rs2=st2.executeQuery();
			rs1.next();
			rs2.next();
			if(rs1.getInt("COUNT(*)")+rs2.getInt("COUNT(*)")==0){
	    		PreparedStatement st3 = conn.prepareStatement("UPDATE store SET address=?, open=?, close=?, capacity_all=?, capacity_res=? WHERE name=?");
				st3.setString(1, update_address);
				st3.setInt(2, update_open_h*6+update_open_m);
				st3.setInt(3, update_close_h*6+update_close_m);
				st3.setInt(4, update_capacity_all);
				st3.setInt(5, update_capacity_res);
				st3.setString(6, update_name);
				int row_num=st3.executeUpdate();
				if(row_num==1){
        			out.println("<p>以上の内容で店舗情報を更新しました。</p>");
				}else if(row_num<1){
        			out.println("<p>更新に失敗しました。編集中の店舗情報は既に削除された可能性があります。</p>");
				}else{
					throw new InputMismatchException("Suspicious delete detected in "+row_num+" rows.(store)");
				}
			}else{
        		out.println("<p>予約情報が残っているため、店舗情報を変更することができませんでした。<br>全ての予約情報を削除した上で、もう一度やり直してください。</p>");
			}
			conn.commit();
		}catch(Exception ex){
        	out.println("<p>更新に失敗しました。入力内容を確認し、やり直してください。</p>");
			conn.rollback();
        	ex.printStackTrace();
    	}
    }catch(Exception ex){
        out.println("<p>更新に失敗しました。入力内容を確認し、やり直してください。</p>");
        ex.printStackTrace();
    }
%>
<a href=stores.jsp>全店管理ページに戻る</a>
<script src="https://code.jquery.com/jquery-3.3.1.slim.min.js" integrity="sha384-q8i/X+965DzO0rT7abK41JStQIAqVgRVzpbzo5smXKp4YfRvH+8abtTE1Pi6jizo" crossorigin="anonymous"></script>
<script src="https://stackpath.bootstrapcdn.com/bootstrap/4.5.2/js/bootstrap.min.js" integrity="sha384-B4gt1jrGC7Jh4AgTPSdUtOBvfO8shuf57BaghqFfPlYxofvL8/KUEfYiJOMMV+rV" crossorigin="anonymous"></script>
</body>
</html>

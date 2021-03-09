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
	if(store==null){
		response.sendRedirect("search.jsp");
	}
	String register_name=request.getParameter("register_name");
	register_name = register_name==null?"":register_name;
    int register_time=-1;
    int register_number=1;
	try{
    	register_time=Integer.valueOf(request.getParameter("register_time"));
    	register_number=Integer.valueOf(request.getParameter("register_number"));
	}catch(Exception ex){}
%>
<html>
<head>
<meta charset="utf-8">
<title>○×寿司 - 予約情報入力</title>
<link rel="stylesheet" href="https://stackpath.bootstrapcdn.com/bootstrap/4.5.2/css/bootstrap.min.css" integrity="sha384-JcKb8q3iqJ61gNV9KGb8thSsNjpSL0n8PARn9HuZOnIxN0hoP+VmmDGMN5t9UJ0Z" crossorigin="anonymous">
<link rel="stylesheet" href="../default.css">
</head>
<body>
<h2>予約情報入力</h2>
<%
	ArrayList<Integer> possible=new ArrayList<>();
	Class.forName("org.sqlite.JDBC");
	String dbfile = application.getRealPath("WEB-INF/" + _dbname);
	try(Connection conn = DriverManager.getConnection("jdbc:sqlite:" + dbfile)){
		conn.setAutoCommit(false);
	    PreparedStatement st1 = conn.prepareStatement("SELECT open, close, capacity_all, capacity_res FROM store WHERE name=?");
	    PreparedStatement st2 = conn.prepareStatement("SELECT time, COUNT(*) FROM reservation WHERE store=? GROUP BY time ORDER BY time ASC");
	    PreparedStatement st3 = conn.prepareStatement("SELECT COUNT(*) FROM waiting WHERE store=? AND recept=0");
		st1.setString(1, store);
		st2.setString(1, store);
		st3.setString(1, store);
        try(ResultSet rs1 = st1.executeQuery(); ResultSet rs2 = st2.executeQuery(); ResultSet rs3 = st3.executeQuery()){
			conn.commit();
            rs1.next();
			int open = rs1.getInt("open");
			int close = rs1.getInt("close");
			int capacity_all = rs1.getInt("capacity_all");
			int capacity_res = rs1.getInt("capacity_res");
            rs3.next();
            int waiting_num=rs3.getInt("COUNT(*)");
			double now_d = MyTime.now();
			int now=(int)now_d;
			HashMap<Integer, Integer> res=new HashMap<>();
            while(rs2.next()){
                res.put(rs2.getInt("time"), rs2.getInt("COUNT(*)"));
            }
			boolean no_wait=false;
			for(int n=now; MyTime.isOpen(n, open, close)&&MyTime.getTimeUntilClose(n, close)>3; n++){
				int res_n=res.getOrDefault(n, 0);
				if(waiting_num>0){
					waiting_num-=(int)((capacity_all-res_n)*(n==now?now-now_d+1:1));
				}else{
					no_wait=true;
				}
				if(n>=now+3&&res_n<capacity_res&&no_wait){
					possible.add(n);
				}
			}
        }
    }catch(Exception ex){
        ex.printStackTrace();
    }
%>
<form action="registerconfirmation.jsp" method="POST">
<table border='1'>
<tr><th>予約店舗</th><td><%=Sanitize.forHtml(store)%></td></tr>
<tr><th>予約時間</th><td>
<select name=register_time required>
<option value="">時間を選択してください</option>
<%
	for(Integer t:possible){
		out.println("<option value='"+t+"' "+(t==register_time?"selected":"")+">"+String.format("%02d時%d0分 ～ %d0分", (t/6)%24, t%6, t%6+1)+"</option>");
	}
%>
</select>
</td></tr>
<tr><th>お名前(フルネーム)</th><td><input type='text' name='register_name' value='<%=Sanitize.forHtml(register_name)%>' required></td></tr>
<tr><th>人数</th><td>
<select name=register_number>
<%
	for(int n=1;n<10;n++){
		out.println("<option value='"+n+"' "+(n==register_number?"selected":"")+">"+n+"名</option>");
	}
%>
</select>
</td></tr>
</table>
<input type="text" name="store" value='<%=Sanitize.forHtml(store)%>' hidden>
<input type="submit" value="確認画面に進む">
</form>
<p>※このページが表示されてから10分以内に予約を完了してください。</p>
<script src="https://code.jquery.com/jquery-3.3.1.slim.min.js" integrity="sha384-q8i/X+965DzO0rT7abK41JStQIAqVgRVzpbzo5smXKp4YfRvH+8abtTE1Pi6jizo" crossorigin="anonymous"></script>
<script src="https://stackpath.bootstrapcdn.com/bootstrap/4.5.2/js/bootstrap.min.js" integrity="sha384-B4gt1jrGC7Jh4AgTPSdUtOBvfO8shuf57BaghqFfPlYxofvL8/KUEfYiJOMMV+rV" crossorigin="anonymous"></script>
</body>
</html>

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
	String add_name=request.getParameter("add_name");
	String add_address=request.getParameter("add_address");
	add_name = add_name==null?"":add_name;
	add_address = add_address==null?"":add_address;
    int add_open_h=0;
    int add_open_m=0;
    int add_close_h=0;
    int add_close_m=0;
    int add_capacity_all=0;
    int add_capacity_res=0;
	try{
    	add_open_h=Integer.valueOf(request.getParameter("add_open_h"));
    	add_open_m=Integer.valueOf(request.getParameter("add_open_m"));
    	add_close_h=Integer.valueOf(request.getParameter("add_close_h"));
    	add_close_m=Integer.valueOf(request.getParameter("add_close_m"));
    	add_capacity_all=Integer.valueOf(request.getParameter("add_capacity_all"));
    	add_capacity_res=Integer.valueOf(request.getParameter("add_capacity_res"));
	}catch(Exception ex){}
%>
<html>
<head>
<meta charset="utf-8">
<title>○×寿司 - 店舗登録完了</title>
<link rel="stylesheet" href="https://stackpath.bootstrapcdn.com/bootstrap/4.5.2/css/bootstrap.min.css" integrity="sha384-JcKb8q3iqJ61gNV9KGb8thSsNjpSL0n8PARn9HuZOnIxN0hoP+VmmDGMN5t9UJ0Z" crossorigin="anonymous">
<link rel="stylesheet" href="../default.css">
</head>
<body>
<h2>新規店舗登録</h2>
<%
	Class.forName("org.sqlite.JDBC");
	String dbfile = application.getRealPath("WEB-INF/" + _dbname);
	out.println("<table border=\"1\">");
    out.println("<tr><th>店舗名</th><th>"+Sanitize.forHtml(add_name)+"</th></tr>");
    out.println("<tr><th>住所</th><th>"+Sanitize.forHtml(add_address)+"</th></tr>");
    out.println("<tr><th>開店時間</th><th>"+add_open_h+"時"+add_open_m+"0分</th></tr>");
    out.println("<tr><th>店舗名</th><th>"+add_close_h+"時"+add_close_m+"0分</th></tr>");
    out.println("<tr><th>店舗容量</th><th>"+add_capacity_all+"件/10分</th></tr>");
    out.println("<tr><th>予約容量</th><th>"+add_capacity_res+"件/10分</th></tr>");
	out.println("</table>");
	try(Connection conn = DriverManager.getConnection("jdbc:sqlite:" + dbfile)){
	    PreparedStatement st = conn.prepareStatement("INSERT INTO store VALUES(?, ?, ?, ?, ?, ?)");
		st.setString(1, add_name);
		st.setString(2, add_address);
		st.setInt(3, add_open_h*6+add_open_m);
		st.setInt(4, add_close_h*6+add_close_m);
		st.setInt(5, add_capacity_all);
		st.setInt(6, add_capacity_res);
        st.executeUpdate();
        out.println("<p>以上の内容で新規店舗情報を登録しました。</p>");
        out.println("<a href=\"reservations.jsp?store="+Sanitize.forHtml(add_name)+"\">新規店舗の予約管理ページはこちら</a>");
    }catch(SQLException ex){
        out.println("<p>登録に失敗しました。入力内容を再確認してください。</p>");
        ex.printStackTrace();
    }
    out.println("<a href=\"stores.jsp\">全店管理ページに戻る</a>");
%>
<script src="https://code.jquery.com/jquery-3.3.1.slim.min.js" integrity="sha384-q8i/X+965DzO0rT7abK41JStQIAqVgRVzpbzo5smXKp4YfRvH+8abtTE1Pi6jizo" crossorigin="anonymous"></script>
<script src="https://stackpath.bootstrapcdn.com/bootstrap/4.5.2/js/bootstrap.min.js" integrity="sha384-B4gt1jrGC7Jh4AgTPSdUtOBvfO8shuf57BaghqFfPlYxofvL8/KUEfYiJOMMV+rV" crossorigin="anonymous"></script>
</body>
</html>

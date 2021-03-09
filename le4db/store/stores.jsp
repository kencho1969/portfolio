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
	String search_name=request.getParameter("search_name");
	String search_address=request.getParameter("search_address");
	search_name = search_name==null?"":search_name;
	search_address = search_address==null?"":search_address;
%>
<html>
<head>
<meta charset="utf-8">
<title>○×寿司 - 全店管理ページ</title>
<link rel="stylesheet" href="https://stackpath.bootstrapcdn.com/bootstrap/4.5.2/css/bootstrap.min.css" integrity="sha384-JcKb8q3iqJ61gNV9KGb8thSsNjpSL0n8PARn9HuZOnIxN0hoP+VmmDGMN5t9UJ0Z" crossorigin="anonymous">
<link rel="stylesheet" href="../default.css">
</head>
<body>
<h1>全店管理ページ</h1>
<h3>以下から店舗を選択してください</h3>
<h4>絞り込み</h4>
<form action="stores.jsp" method="GET">
店舗名： 
<%
out.print("<input type=\"text\" name=\"search_name\" value="+Sanitize.forHtml(search_name)+">");
%>
<br>
住所： 
<%
out.print("<input type=\"text\" name=\"search_address\" value="+Sanitize.forHtml(search_address)+">");
%>
<br>
<input type="submit" value="絞り込む"/>
</form>
<%
	out.println("<table border=\"1\">");
	out.println("<tr><th>店舗名</th><th>住所</th><th>開店時間</th><th>閉店時間</th><th>店舗容量</th><th>予約容量</th></tr>");
	Class.forName("org.sqlite.JDBC");
	String dbfile = application.getRealPath("WEB-INF/" + _dbname);
	try(Connection conn = DriverManager.getConnection("jdbc:sqlite:" + dbfile)){
		PreparedStatement st = null;
		st = conn.prepareStatement("SELECT * FROM store WHERE name LIKE ? AND address LIKE ?");
		st.setString(1, "%"+search_name+"%");
		st.setString(2, "%"+search_address+"%");
		try (ResultSet rs = st.executeQuery()){
			while (rs.next()) {
				String name = rs.getString("name");
				String address = rs.getString("address");
				int open = rs.getInt("open");
				int close = rs.getInt("close");
				int capacity_all = rs.getInt("capacity_all");//How many reservations and waitings this store can afford per 10 min.
				int capacity_res = rs.getInt("capacity_res");//How many reservations this store can afford per 10 min.
				out.println("<tr>");
				out.println("<td><a href=\"reservations.jsp?store=" + Sanitize.forHtml(name) + "\">" + Sanitize.forHtml(name)	+ "</a></td>");
				out.println("<td>" + Sanitize.forHtml(address) + "</td>");
				out.println("<td>" + String.format("%02d:%d0", open/6, open%6) + "</td>");
				out.println("<td>" + String.format("%02d:%d0", close/6, close%6) + "</td>");
				out.println("<td>" + capacity_all + "</td>");
				out.println("<td>" + capacity_res + "</td>");
				out.println("<td><a href=\"editstore.jsp?store="+ Sanitize.forHtml(name) +"\">編集</a></td>");
				out.println("<td><a href=\"deletestoreconfirmation.jsp?store="+ Sanitize.forHtml(name) +"\">削除</a></td>");
				out.println("</tr>");
			}
		}
	} catch (Exception e) {
		e.printStackTrace();
	}
	out.println("</table>");
%>
<br>
<h2>新規店舗登録</h2>
<form action="addstore.jsp" method="POST">
店舗名： 
<input type="text" name="add_name" required/>
<br/>
住所： 
<input type="text" name="add_address" style="width: 300px" required/>
<br/>
開店時間： 
<select name="add_open_h">
<%
	for(int n=0;n<24;n++){
		out.println("<option value=\""+n+"\">"+n+"</option>");
	}
%>
</select>
時
<select name="add_open_m">
<%
	for(int n=0;n<6;n++){
		out.println("<option value=\""+n+"\">"+n+"0</option>");
	}
%>
</select>
分
<br/>
閉店時間： 
<select name="add_close_h">
<%
	for(int n=0;n<30;n++){
		out.println("<option value=\""+n+"\">"+n+"</option>");
	}
%>
</select>
時
<select name="add_close_m">
<%
	for(int n=0;n<6;n++){
		out.println("<option value=\""+n+"\">"+n+"0</option>");
	}
%>
</select>
分
<br/>
店舗容量：
<select name="add_capacity_all">
<%
	for(int n=1;n<=50;n++){
		out.println("<option value=\""+n+"\">"+n+"</option>");
	}
%>
</select>
件/10分
<br/>
予約容量：
<select name="add_capacity_res">
<%
	for(int n=1;n<=50;n++){
		out.println("<option value=\""+n+"\">"+n+"</option>");
	}
%>
</select>
件/10分
<br/>
<input type="submit" value="登録"/>
</form>
<script src="https://code.jquery.com/jquery-3.3.1.slim.min.js" integrity="sha384-q8i/X+965DzO0rT7abK41JStQIAqVgRVzpbzo5smXKp4YfRvH+8abtTE1Pi6jizo" crossorigin="anonymous"></script>
<script src="https://stackpath.bootstrapcdn.com/bootstrap/4.5.2/js/bootstrap.min.js" integrity="sha384-B4gt1jrGC7Jh4AgTPSdUtOBvfO8shuf57BaghqFfPlYxofvL8/KUEfYiJOMMV+rV" crossorigin="anonymous"></script>
</body>
</html>

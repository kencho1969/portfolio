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
<title>○×寿司 - 予約店舗検索</title>
<link rel="stylesheet" href="https://stackpath.bootstrapcdn.com/bootstrap/4.5.2/css/bootstrap.min.css" integrity="sha384-JcKb8q3iqJ61gNV9KGb8thSsNjpSL0n8PARn9HuZOnIxN0hoP+VmmDGMN5t9UJ0Z" crossorigin="anonymous">
<link rel="stylesheet" href="../default.css">
</head>
<body>
<h1>○×寿司<h1>
<h2>時間指定予約</h2>
<h3>絞り込み</h3>
<form action="search.jsp" method="GET">
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
				out.println("<div>");
				out.println("<h3>" + Sanitize.forHtml(name)	+ "</h3>");
				out.println("<p>住所：" + Sanitize.forHtml(address) + "</p>");
				out.println("<p>営業時間：" + String.format("%02d:%d0 ～ %02d:%d0", open/6, open%6, close/6, close%6) + "</p>");
                out.println("<form action='register.jsp' method='GET'><input type='text' name='store' value="+ Sanitize.forHtml(name) +" hidden><input type='submit' value='予約する'></form>");
				out.println("</div>");
			}
		}
	} catch (Exception e) {
		e.printStackTrace();
	}
%>
<script src="https://code.jquery.com/jquery-3.3.1.slim.min.js" integrity="sha384-q8i/X+965DzO0rT7abK41JStQIAqVgRVzpbzo5smXKp4YfRvH+8abtTE1Pi6jizo" crossorigin="anonymous"></script>
<script src="https://stackpath.bootstrapcdn.com/bootstrap/4.5.2/js/bootstrap.min.js" integrity="sha384-B4gt1jrGC7Jh4AgTPSdUtOBvfO8shuf57BaghqFfPlYxofvL8/KUEfYiJOMMV+rV" crossorigin="anonymous"></script>
</body>
</html>
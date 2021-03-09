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
		response.sendRedirect("selectstore.jsp");
	}
%>
<html>
<head>
<meta charset="utf-8">
<meta http-equiv="Refresh" content="60; URL=register.jsp?store=<%=Sanitize.forHtml(store)%>">
<title>○×寿司 - 待ち予約</title>
<link rel="stylesheet" href="https://stackpath.bootstrapcdn.com/bootstrap/4.5.2/css/bootstrap.min.css" integrity="sha384-JcKb8q3iqJ61gNV9KGb8thSsNjpSL0n8PARn9HuZOnIxN0hoP+VmmDGMN5t9UJ0Z" crossorigin="anonymous">
<link rel="stylesheet" href="storedevice.css">
</head>
<body>
<h2>待ち予約</h2>
<p>人数を選択してください。</p>
<form action="registername.jsp" method="POST">
<div class="button-radio">
<%
    for(int n=1;n<10;n++){
        out.println("<input type='radio' name='register_number' id='num"+n+"' value='"+n+"' required><label for='num"+n+"'>"+n+"</label>");
    }
%>
<div>
<input type="text" name='store' value='<%=Sanitize.forHtml(store)%>' hidden>
<input type="submit" value="決定">
</form>
<script src="https://code.jquery.com/jquery-3.3.1.slim.min.js" integrity="sha384-q8i/X+965DzO0rT7abK41JStQIAqVgRVzpbzo5smXKp4YfRvH+8abtTE1Pi6jizo" crossorigin="anonymous"></script>
<script src="https://stackpath.bootstrapcdn.com/bootstrap/4.5.2/js/bootstrap.min.js" integrity="sha384-B4gt1jrGC7Jh4AgTPSdUtOBvfO8shuf57BaghqFfPlYxofvL8/KUEfYiJOMMV+rV" crossorigin="anonymous"></script>
</body>
</html>

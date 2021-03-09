<%@ page contentType="text/html;charset=UTF-8" %>
<%@ page import="java.io.*" %>
<%@ page import="java.sql.*" %>
<%@ page import="java.util.*" %>
<%@ page import="myutil.*" %>
<%
	String store=request.getParameter("store");
	String register_name=request.getParameter("register_name");
    int register_number=0;
	try{
    	register_number=Integer.valueOf(request.getParameter("register_number"));
	}catch(Exception ex){}
	if(store==null||register_number<1||register_number>9||register_name==null){
		response.sendRedirect("storeselect.jsp");
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
<form method="POST">
<table border='1'>
<tr><th>人数</th><td><%=register_number%>名</td></tr>
<tr><th>お名前</th><td><%=Sanitize.forHtml(register_name)%></td></tr>
</table>
<input type="text" name="store" value='<%=Sanitize.forHtml(store)%>' hidden>
<input type="text" name="register_name" value='<%=Sanitize.forHtml(register_name)%>' hidden>
<input type="text" name="register_number" value='<%=register_number%>' hidden>
<input type="submit" formaction="registernumber.jsp" value="入力をやり直す">
<input type="submit" formaction="registercomplete.jsp" value="確定する">
</form>
<script src="https://code.jquery.com/jquery-3.3.1.slim.min.js" integrity="sha384-q8i/X+965DzO0rT7abK41JStQIAqVgRVzpbzo5smXKp4YfRvH+8abtTE1Pi6jizo" crossorigin="anonymous"></script>
<script src="https://stackpath.bootstrapcdn.com/bootstrap/4.5.2/js/bootstrap.min.js" integrity="sha384-B4gt1jrGC7Jh4AgTPSdUtOBvfO8shuf57BaghqFfPlYxofvL8/KUEfYiJOMMV+rV" crossorigin="anonymous"></script>
</body>
</html>

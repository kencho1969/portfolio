<%@ page contentType="text/html;charset=UTF-8" %>
<%@ page import="java.io.*" %>
<%@ page import="java.sql.*" %>
<%@ page import="java.util.*" %>
<%@ page import="myutil.*" %>
<%
	String store=request.getParameter("store");
	if(store==null){
		response.sendRedirect("search.jsp");
	}
	String register_name=request.getParameter("register_name");
	register_name = register_name==null?"":register_name;
    int register_time=0;
    int register_number=0;
	try{
    	register_time=Integer.valueOf(request.getParameter("register_time"));
    	register_number=Integer.valueOf(request.getParameter("register_number"));
	}catch(Exception ex){}
%>
<html>
<head>
<meta charset="utf-8">
<title>○×寿司 - 予約情報確認</title>
<link rel="stylesheet" href="https://stackpath.bootstrapcdn.com/bootstrap/4.5.2/css/bootstrap.min.css" integrity="sha384-JcKb8q3iqJ61gNV9KGb8thSsNjpSL0n8PARn9HuZOnIxN0hoP+VmmDGMN5t9UJ0Z" crossorigin="anonymous">
<link rel="stylesheet" href="../default.css">
</head>
<body>
<h2>予約情報確認</h2>
<p>まだ予約は確定されていません。以下の内容をご確認の上、よろしければ「予約を確定する」を押してください。</p>
<form method="POST">
<table border='1'>
<tr><th>予約店舗</th><td><%=Sanitize.forHtml(store)%></td></tr>
<tr><th>予約時間</th><td><%=String.format("%02d時%d0分 ～ %d0分", register_time/6, register_time%6, register_time%6+1)%></td></tr>
<tr><th>お名前(フルネーム)</th><td><%=Sanitize.forHtml(register_name)%></td></tr>
<tr><th>人数</th><td><%=register_number%>名</td></tr>
</table>
<input type="text" name="store" value='<%=Sanitize.forHtml(store)%>' hidden>
<input type="text" name="register_time" value='<%=register_time%>' hidden>
<input type="text" name="register_name" value='<%=Sanitize.forHtml(register_name)%>' hidden>
<input type="text" name="register_number" value='<%=register_number%>' hidden>
<input type="submit" formaction="register.jsp" value="入力内容を修正する">
<input type="submit" formaction="registercomplete.jsp" value="予約を確定する">
</form>
<script src="https://code.jquery.com/jquery-3.3.1.slim.min.js" integrity="sha384-q8i/X+965DzO0rT7abK41JStQIAqVgRVzpbzo5smXKp4YfRvH+8abtTE1Pi6jizo" crossorigin="anonymous"></script>
<script src="https://stackpath.bootstrapcdn.com/bootstrap/4.5.2/js/bootstrap.min.js" integrity="sha384-B4gt1jrGC7Jh4AgTPSdUtOBvfO8shuf57BaghqFfPlYxofvL8/KUEfYiJOMMV+rV" crossorigin="anonymous"></script>
</body>
</html>

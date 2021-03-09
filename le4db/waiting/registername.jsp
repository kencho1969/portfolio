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
    int register_number=0;
	try{
    	register_number=Integer.valueOf(request.getParameter("register_number"));
	}catch(Exception ex){}
	if(store==null||register_number<1||register_number>9){
		response.sendRedirect("selectstore.jsp");
	}
%>
<html>
<head>
<meta charset="utf-8">
<meta http-equiv="Refresh" content="120; URL=register.jsp?store=<%=Sanitize.forHtml(store)%>">
<title>○×寿司 - 待ち予約</title>
<link rel="stylesheet" href="https://stackpath.bootstrapcdn.com/bootstrap/4.5.2/css/bootstrap.min.css" integrity="sha384-JcKb8q3iqJ61gNV9KGb8thSsNjpSL0n8PARn9HuZOnIxN0hoP+VmmDGMN5t9UJ0Z" crossorigin="anonymous">
<link rel="stylesheet" href="storedevice.css">
</head>
<body>
<h2>待ち予約</h2>
<p>名前を入力してください。(10文字以内)</p>
<form action="registerconfirmation.jsp" method="POST">
<input type='text' id='name_field' name='register_name' value='' required readonly>
<table>
<%
    String[] strs=new String[]{"ア","イ","ウ","エ","オ","カ","キ","ク","ケ","コ","サ","シ","ス","セ","ソ","タ","チ","ツ","テ","ト","ナ","ニ","ヌ","ネ","ノ","ハ","ヒ","フ","ヘ","ホ","マ","ミ","ム","メ","モ","ヤ","","ユ","","ヨ","ラ","リ","ル","レ","ロ","ワ","","ン","","ー","小字","゛゜","","","消す"};
    for(int n=0;n<5;n++){
        out.println("<tr>");
        for(int m=10;m>=0;m--){
            if(strs[n+m*5].equals("")){
                out.println("<td></td>");
            }else{
                out.println("<td><input type='button' onclick='addString(\""+strs[n+m*5]+"\")' value='"+strs[n+m*5]+"'></td>");
            }
        }
        out.println("</tr>");
    }
%>
</table>
<input type="text" name='store' value='<%=Sanitize.forHtml(store)%>' hidden>
<input type="text" name='register_number' value='<%=register_number%>' hidden>
<input id="submit" type="submit" value="決定" disabled>
</form>
<script src="https://code.jquery.com/jquery-3.3.1.slim.min.js" integrity="sha384-q8i/X+965DzO0rT7abK41JStQIAqVgRVzpbzo5smXKp4YfRvH+8abtTE1Pi6jizo" crossorigin="anonymous"></script>
<script src="https://stackpath.bootstrapcdn.com/bootstrap/4.5.2/js/bootstrap.min.js" integrity="sha384-B4gt1jrGC7Jh4AgTPSdUtOBvfO8shuf57BaghqFfPlYxofvL8/KUEfYiJOMMV+rV" crossorigin="anonymous"></script>
<script src="registername.js"></script>
</body>
</html>

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
	String register_name=request.getParameter("register_name");
	if(store==null||register_name==null){
		response.sendRedirect("search.jsp");
	}
    int register_number=1;
	try{
    	register_number=Integer.valueOf(request.getParameter("register_number"));
	}catch(Exception ex){}
	if(register_number<1||register_number>9){
		response.sendRedirect("search.jsp");
	}
%>
<html>
<head>
<meta charset="utf-8">
<meta http-equiv="Refresh" content="60; URL=register.jsp?store=<%=Sanitize.forHtml(store)%>">
<title>○×寿司 - 予約完了</title>
<link rel="stylesheet" href="https://stackpath.bootstrapcdn.com/bootstrap/4.5.2/css/bootstrap.min.css" integrity="sha384-JcKb8q3iqJ61gNV9KGb8thSsNjpSL0n8PARn9HuZOnIxN0hoP+VmmDGMN5t9UJ0Z" crossorigin="anonymous">
<link rel="stylesheet" href="storedevice.css">
</head>
<body>
<%
	Class.forName("org.sqlite.JDBC");
	String dbfile = application.getRealPath("WEB-INF/" + _dbname);
    int reserve_id=-1;
	try(Connection conn = DriverManager.getConnection("jdbc:sqlite:" + dbfile)){
        try{
            conn.setAutoCommit(false);
	        PreparedStatement st1 = conn.prepareStatement("SELECT open, close, capacity_res FROM store WHERE name=?");
	        PreparedStatement st2 = conn.prepareStatement("SELECT COUNT(*) FROM waiting WHERE store=?");
            st1.setString(1, store);
            st2.setString(1, store);
            ResultSet rs1=st1.executeQuery();
            ResultSet rs2=st2.executeQuery();
            rs1.next();
            rs2.next();
            int open=rs1.getInt("open");
            int close=rs1.getInt("close");
            int capacity=rs1.getInt("capacity_res");
            reserve_id=MyTime.getTimeAfterOpen(close, open)*capacity+rs2.getInt("COUNT(*)");
	        PreparedStatement st3 = conn.prepareStatement("INSERT INTO waiting VALUES(?, ?, ?, ?, 0)");
            st3.setString(1, store);
            st3.setInt(2, reserve_id);
            st3.setString(3, register_name);
            st3.setInt(4, register_number);
            st3.executeUpdate();
            conn.commit();
			out.println("<h2>受付完了</h2>");
			out.println("<p>受付が完了しました。予約番号は<b>"+reserve_id+"</b>です。</p>");
        }catch(Exception ex){
			out.println("<h2>受付エラー</h2>");
			out.println("<p>エラーが発生しました。お手数ですが、もう一度最初からやり直してください。</p>");
            conn.rollback();
            ex.printStackTrace();
        }
    }catch(Exception ex){
        ex.printStackTrace();
    }
%>
<form action="register.jsp" method="GET">
<input type='text' name="store" value="<%=Sanitize.forHtml(store)%>" hidden>
<input type='submit' value="TOPに戻る">
</form>
<script src="https://code.jquery.com/jquery-3.3.1.slim.min.js" integrity="sha384-q8i/X+965DzO0rT7abK41JStQIAqVgRVzpbzo5smXKp4YfRvH+8abtTE1Pi6jizo" crossorigin="anonymous"></script>
<script src="https://stackpath.bootstrapcdn.com/bootstrap/4.5.2/js/bootstrap.min.js" integrity="sha384-B4gt1jrGC7Jh4AgTPSdUtOBvfO8shuf57BaghqFfPlYxofvL8/KUEfYiJOMMV+rV" crossorigin="anonymous"></script>
</body>
</html>

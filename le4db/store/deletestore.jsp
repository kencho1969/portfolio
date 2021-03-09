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
	store = store==null?"":store;
%>
<html>
<head>
<meta charset="utf-8">
<title>○×寿司 - 店舗削除完了</title>
<link rel="stylesheet" href="https://stackpath.bootstrapcdn.com/bootstrap/4.5.2/css/bootstrap.min.css" integrity="sha384-JcKb8q3iqJ61gNV9KGb8thSsNjpSL0n8PARn9HuZOnIxN0hoP+VmmDGMN5t9UJ0Z" crossorigin="anonymous">
<link rel="stylesheet" href="../default.css">
</head>
<body>
<%
	Class.forName("org.sqlite.JDBC");
	String dbfile = application.getRealPath("WEB-INF/" + _dbname);
	try(Connection conn = DriverManager.getConnection("jdbc:sqlite:" + dbfile)){
		try{
			conn.setAutoCommit(false);
	    	PreparedStatement st1 = conn.prepareStatement("SELECT COUNT(*) FROM reservation WHERE store=?");
	    	PreparedStatement st2 = conn.prepareStatement("SELECT COUNT(*) FROM waiting WHERE store=?");
			st1.setString(1, store);
			st2.setString(1, store);
			ResultSet rs1=st1.executeQuery();
			ResultSet rs2=st2.executeQuery();
			rs1.next();
			rs2.next();
			if(rs1.getInt("COUNT(*)")+rs2.getInt("COUNT(*)")==0){
	    		PreparedStatement st3 = conn.prepareStatement("DELETE FROM store WHERE name=?");
				st3.setString(1, store);
				int row_num=st3.executeUpdate();
				if(row_num<=1){
					out.println("<h2>店舗情報削除</h2>");
        			out.println("<p>削除が完了しました。</p>");
				}else{
					throw new InputMismatchException("Suspicious delete detected in "+row_num+" rows.(store)");
				}
			}else{
				out.println("<h2>削除エラー</h2>");
        		out.println("<p>予約情報が残っているため、店舗情報を削除することができませんでした。<br>全ての予約情報を削除した上で、もう一度やり直してください。</p>");
			}
			conn.commit();
		}catch(Exception ex){
			out.println("<h2>削除エラー</h2>");
        	out.println("<p>削除に失敗しました。もう一度やり直してください。</p>");
			conn.rollback();
        	ex.printStackTrace();
    	}
    }
%>
<a href=stores.jsp>全店管理ページに戻る</a>
<script src="https://code.jquery.com/jquery-3.3.1.slim.min.js" integrity="sha384-q8i/X+965DzO0rT7abK41JStQIAqVgRVzpbzo5smXKp4YfRvH+8abtTE1Pi6jizo" crossorigin="anonymous"></script>
<script src="https://stackpath.bootstrapcdn.com/bootstrap/4.5.2/js/bootstrap.min.js" integrity="sha384-B4gt1jrGC7Jh4AgTPSdUtOBvfO8shuf57BaghqFfPlYxofvL8/KUEfYiJOMMV+rV" crossorigin="anonymous"></script>
</body>
</html>

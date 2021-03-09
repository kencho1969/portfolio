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
<%
    int est_time=-1;
	Class.forName("org.sqlite.JDBC");
	String dbfile = application.getRealPath("WEB-INF/" + _dbname);
	try(Connection conn = DriverManager.getConnection("jdbc:sqlite:" + dbfile)){
		conn.setAutoCommit(false);
	    PreparedStatement st1 = conn.prepareStatement("SELECT open, close, capacity_all FROM store WHERE name=?");
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
            rs3.next();
            int waiting_num=rs3.getInt("COUNT(*)");
			double now_d = MyTime.now();
			int now=(int)now_d;
			HashMap<Integer, Integer> res=new HashMap<>();
            while(rs2.next()){
                res.put(rs2.getInt("time"), rs2.getInt("COUNT(*)"));
            }
			for(int n=now; MyTime.isOpen(n, open, close)&&MyTime.getTimeUntilClose(n, close)>3; n++){
				est_time=-2;//detect if this loop is entered
				int res_n=res.getOrDefault(n, 0);
				waiting_num-=(int)((capacity_all-res_n)*(n==now?now-now_d+1:1));
				if(waiting_num<0){
                    est_time=n;
                    break;
				}
			}
        }
    }catch(Exception ex){
        ex.printStackTrace();
    }
    if(est_time==-1){
        out.println("本日の受付は終了いたしました。");
    }else if(est_time==-2){
        out.println("申し訳ありませんが大変混み合っておりますため、現在受付を行っておりません。");
	}else{
        out.println("予約がお済みでない方はこちらで受付を行っております。<br>");
        out.println("現在のお呼び出し目安時間は"+String.format("%02d:%d0 ～ %02d:%d0", (est_time/6)%24, est_time%6, ((est_time+1)/6)%24, (est_time+1)%6)+"です。");
        out.println("<form action='registernumber.jsp' method='GET'><input type='text' name='store' value="+ Sanitize.forHtml(store) +" hidden><input type='submit' value='受付'></form>");
    }
%>
<script src="https://code.jquery.com/jquery-3.3.1.slim.min.js" integrity="sha384-q8i/X+965DzO0rT7abK41JStQIAqVgRVzpbzo5smXKp4YfRvH+8abtTE1Pi6jizo" crossorigin="anonymous"></script>
<script src="https://stackpath.bootstrapcdn.com/bootstrap/4.5.2/js/bootstrap.min.js" integrity="sha384-B4gt1jrGC7Jh4AgTPSdUtOBvfO8shuf57BaghqFfPlYxofvL8/KUEfYiJOMMV+rV" crossorigin="anonymous"></script>
</body>
</html>

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
    int register_time=-1;
    int register_number=1;
	try{
    	register_time=Integer.valueOf(request.getParameter("register_time"));
    	register_number=Integer.valueOf(request.getParameter("register_number"));
	}catch(Exception ex){}
	if(register_time<0||register_number<1||register_number>9){
		response.sendRedirect("search.jsp");
	}
	Class.forName("org.sqlite.JDBC");
	String dbfile = application.getRealPath("WEB-INF/" + _dbname);
    boolean accept=false;
    int reserve_id=-1;
	try(Connection conn = DriverManager.getConnection("jdbc:sqlite:" + dbfile)){
        conn.setAutoCommit(false);
        //予約枠最終判定
	    PreparedStatement st1 = conn.prepareStatement("SELECT open, close, capacity_all, capacity_res FROM store WHERE name=?");
	    PreparedStatement st2 = conn.prepareStatement("SELECT time, COUNT(*) FROM reservation WHERE store=? GROUP BY time ORDER BY time ASC");
	    PreparedStatement st3 = conn.prepareStatement("SELECT COUNT(*) FROM waiting WHERE store=? AND recept=0");
		st1.setString(1, store);
		st2.setString(1, store);
		st3.setString(1, store);
        try(ResultSet rs1 = st1.executeQuery(); ResultSet rs2 = st2.executeQuery(); ResultSet rs3 = st3.executeQuery()){
            rs1.next();
			int open = rs1.getInt("open");
			int close = rs1.getInt("close");
			int capacity_all = rs1.getInt("capacity_all");
			int capacity_res = rs1.getInt("capacity_res");
            rs3.next();
            int waiting_num=rs3.getInt("COUNT(*)");
			double now_d = MyTime.now();
			int now=(int)now_d;
			HashMap<Integer, Integer> res=new HashMap<>();
            while(rs2.next()){
                res.put(rs2.getInt("time"), rs2.getInt("COUNT(*)"));
            }
			for(int n=now; MyTime.isOpen(n, open, close)&&MyTime.getTimeUntilClose(n, close)>3; n++){
				int res_n=res.getOrDefault(n, 0);
                if(n==register_time){
                    reserve_id=MyTime.getTimeAfterOpen(n, open)*capacity_res+res_n+1;
                    accept = n>=now+2&&res_n<capacity_res&&waiting_num<capacity_all-res_n;
                    break;
                }else if(waiting_num>0){
					waiting_num-=(int)((capacity_all-res_n)*(n==now?now-now_d+1:1));
				}
			}
            //予約操作
            if(accept){
	            PreparedStatement st4 = conn.prepareStatement("INSERT INTO reservation VALUES(?, ?, ?, ?, ?, 0)");
                st4.setString(1, store);
                st4.setInt(2, reserve_id);
                st4.setInt(3, register_time);
                st4.setString(4, register_name);
                st4.setInt(5, register_number);
                st4.executeUpdate();
            }
            conn.commit();
        }catch(Exception ex){
            conn.rollback();
            accept=false;
            ex.printStackTrace();
        }
    }catch(Exception ex){
        ex.printStackTrace();
    }
%>
<html>
<head>
<meta charset="utf-8">
<title>○×寿司 - 予約完了</title>
<link rel="stylesheet" href="https://stackpath.bootstrapcdn.com/bootstrap/4.5.2/css/bootstrap.min.css" integrity="sha384-JcKb8q3iqJ61gNV9KGb8thSsNjpSL0n8PARn9HuZOnIxN0hoP+VmmDGMN5t9UJ0Z" crossorigin="anonymous">
<link rel="stylesheet" href="../default.css">
</head>
<body>
<h2><%=accept?"予約完了":"予約エラー"%></h2>
<%
    if(accept){
        out.println("<p>ご予約を承りました。予約番号は<b>"+reserve_id+"</b>です。ご来店お待ちしております。</p>");
    }else{
        out.println("<p>予約に失敗しました。お手数ですが、もう一度最初からやり直してください。</p>");
    }
%>
<a href="search.jsp">店舗一覧に戻る</a>
<script src="https://code.jquery.com/jquery-3.3.1.slim.min.js" integrity="sha384-q8i/X+965DzO0rT7abK41JStQIAqVgRVzpbzo5smXKp4YfRvH+8abtTE1Pi6jizo" crossorigin="anonymous"></script>
<script src="https://stackpath.bootstrapcdn.com/bootstrap/4.5.2/js/bootstrap.min.js" integrity="sha384-B4gt1jrGC7Jh4AgTPSdUtOBvfO8shuf57BaghqFfPlYxofvL8/KUEfYiJOMMV+rV" crossorigin="anonymous"></script>
</body>
</html>

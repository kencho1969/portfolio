package myutil;

import java.time.LocalTime;

public class MyTime {

    public static double now(){
        LocalTime now=LocalTime.now();
        return now.getHour()*6+now.getMinute()/10D+now.getSecond()/600D;
    }

    public static boolean isOpen(int time, int open, int close){
        if(open<close){
            return (open<=time&&time<close)||(open<=time+144&&time+144<close);
        }else{
            return (open<=time&&time<close+144)||(open<=time+144&&time+144<close+144);
        }
    }

    public static boolean isOpenNow(int open, int close){
        return isOpen((int)now(), open, close);
    }

    public static int getTimeAfterOpen(int time, int open){
        if(time-open<0){
            return time-open+144;
        }if(time-open>=144){
            return time-open-144;
        }else{
            return time-open;
        }
    }

    public static int getTimeUntilClose(int time, int close){
        if(close-time<=0){
            return close-time+144;
        }if(close-time>144){
            return close-time-144;
        }else{
            return close-time;
        }
    }
}

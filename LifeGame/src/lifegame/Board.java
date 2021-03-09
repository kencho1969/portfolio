/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package lifegame;

import java.util.Arrays;

/**
 *
 * @author yomogi
 */
public class Board {
    private int[][] data;//固定配列
    private int width;//有効幅
    private int height;//有効高さ
    
    private boolean extinct;//全死滅しているかどうか
    private boolean settlement;//安定が確定しているかどうか
    private int[][] pre_data;
    private final int PERIOD=12;//安定判定周期
    private int count;//周期カウンター
    
    private int[][][] born_rule;//0:void,1:blue|red,2:green
    private int[][][] blue_rule;//0:death,1:survive,2:prey,3:neutral
    private int[][][] green_rule;//0:death,1:survive,2:passive
    
    public Board(int w,int h){
        data=new int[200][200];//black:0,blue:1,red:2,green:3
        pre_data=new int[200][200];
        born_rule=new int[7][7][7];
        blue_rule=new int[7][7][7];
        green_rule=new int[7][7][7];
        for(int[] col : data){Arrays.fill(col,0);}
        for(int[] col : pre_data){Arrays.fill(col,-1);}
        width=w;
        height=h;
        extinct=true;
        settlement=false;
        count=6;
    }
    
    public Board copy(){
        Board copy=new Board(width,height);
        for(int n=0;n<data.length;n++){System.arraycopy(data[n],0,copy.data[n],0,data[n].length);}
        for(int m=0;m<born_rule.length;m++){for(int n=0;n<born_rule[m].length;n++){System.arraycopy(born_rule[m][n],0,copy.born_rule[m][n],0,born_rule[m][n].length);}}
        for(int m=0;m<blue_rule.length;m++){for(int n=0;n<blue_rule[m].length;n++){System.arraycopy(blue_rule[m][n],0,copy.blue_rule[m][n],0,blue_rule[m][n].length);}}
        for(int m=0;m<green_rule.length;m++){for(int n=0;n<green_rule[m].length;n++){System.arraycopy(green_rule[m][n],0,copy.green_rule[m][n],0,green_rule[m][n].length);}}
        return copy;
    }
    
    public void next(){
        int[][] temp=new int[width][height];
        for(int n=0;n<height;n++){
            for(int m=0;m<width;m++){
                temp[m][n]=data[m][n];
            }
        }
        extinct=true;
        if(count==0){
            settlement=true;
        }
        for(int n=0;n<height;n++){
            for(int m=0;m<width;m++){
                int[] around=new int[4];//6近傍の[黒,青,赤,緑]
                int[][] checklist=new int[][]{{-1,0},{1,0},{0,-1},{0,1},{n%2==0?-1:1,-1},{n%2==0?-1:1,1}};
                for(int[] pos:checklist){
                    around[temp[Math.floorMod(m+pos[0],width)][Math.floorMod(n+pos[1],height)]]++;
                }
                switch(temp[m][n]){
                    case 0:
                        if(around[1]>around[2]){
                            switch(born_rule[around[3]][around[1]][around[2]]){
                                case 1:data[m][n]=1;break;
                                case 2:data[m][n]=3;break;
                            }
                        }else{
                            switch(born_rule[around[3]][around[2]][around[1]]){
                                case 1:data[m][n]=2;break;
                                case 2:data[m][n]=3;break;
                            }
                        }
                        break;
                    case 1:
                        data[m][n]=blue_rule[around[3]][around[1]][around[2]];
                        break;
                    case 2:
                        switch(blue_rule[around[3]][around[2]][around[1]]){
                            case 0:data[m][n]=0;break;
                            case 2:data[m][n]=1;break;
                            case 3:data[m][n]=3;break;
                        }
                        break;
                    case 3:
                        if(around[1]>around[2]){
                            switch(green_rule[around[3]][around[1]][around[2]]){
                                case 0:data[m][n]=0;break;
                                case 2:data[m][n]=1;break;
                            }
                        }else{
                            switch(green_rule[around[3]][around[2]][around[1]]){
                                case 0:data[m][n]=0;break;
                                case 2:data[m][n]=2;break;
                            }
                        }
                        break;
                }
                if(count==0){
                    if(data[m][n]!=pre_data[m][n]){
                        settlement=false;
                    }
                    pre_data[m][n]=data[m][n];
                }
                if(data[m][n]!=0){
                    extinct=false;
                }
            }
        }
        if(count==0){
            count=PERIOD;
        }
        count--;
    }
    public int getPoint(int x,int y){
        return data[x][y];
    }
    public void setPoint(int x,int y,int value){
        data[x][y]=value;
    }
    public int getWidth(){
        return width;
    }
    public void setWidth(int width){
        this.width=width;
    }
    public int getHeight(){
        return height;
    }
    public void setHeight(int height){
        this.height=height;
    }
    public int getBornRule(int self,int enemy,int neutral){
        return born_rule[neutral][self][enemy];
    }
    public int getBlueRule(int self,int enemy,int neutral){
        return blue_rule[neutral][self][enemy];
    }
    public int getGreenRule(int self,int enemy,int neutral){
        return green_rule[neutral][self][enemy];
    }
    public void setBornRule(int self,int enemy,int neutral,int value){
        born_rule[neutral][self][enemy]=value;
    }
    public void setBlueRule(int self,int enemy,int neutral,int value){
        blue_rule[neutral][self][enemy]=value;
    }
    public void setGreenRule(int self,int enemy,int neutral,int value){
        green_rule[neutral][self][enemy]=value;
    }
    public void changeBornRule(int self,int enemy,int neutral){
        if(self+enemy+neutral<=6){
            if(self>enemy){
                born_rule[neutral][self][enemy]=(born_rule[neutral][self][enemy]+1)%3;
            }else if(self==enemy){
                born_rule[neutral][self][enemy]=2-born_rule[neutral][self][enemy];
            }
        }
    }
    public void changeBlueRule(int self,int enemy,int neutral){
        if(self+enemy+neutral<=6){
            blue_rule[neutral][self][enemy]=(blue_rule[neutral][self][enemy]+1)%4;
        }
    }
    public void changeGreenRule(int self,int enemy,int neutral){
        if(self+enemy+neutral<=6){
            if(self>enemy){
                green_rule[neutral][self][enemy]=(green_rule[neutral][self][enemy]+1)%3;
            }else if(self==enemy){
                green_rule[neutral][self][enemy]=1-green_rule[neutral][self][enemy];
            }
        }
    }
    public void randomFill(double blue,double red,double green){
        for(int n=0;n<height;n++){
            for(int m=0;m<width;m++){
                double rand=Math.random();
                if(rand<blue){
                    data[m][n]=1;
                }else if(rand<blue+red){
                    data[m][n]=2;
                }else if(rand<blue+red+green){
                    data[m][n]=3;
                }else{
                    data[m][n]=0;
                }
            }
        }
    }
    public void clearAll(){
        for(int[] col : data){Arrays.fill(col,0);}
        for(int[] col : pre_data){Arrays.fill(col,-1);}
        count=6;
        settlement=false;
    }
    public boolean extinct(){
        return extinct;
    }
    public boolean settlement(){
        return settlement;
    }
}

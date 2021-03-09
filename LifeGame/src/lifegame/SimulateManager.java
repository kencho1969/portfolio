/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package lifegame;

import java.util.ArrayList;
import java.util.Arrays;

/**
 *
 * @author Yomogi
 */
public class SimulateManager {
    private Panel panel;
    private Board main;
    public SimulateManager(Panel display){
        panel=display;
        main=new Board(50,50);
    }
    public void start(){
        ArrayList<Integer> result=new ArrayList<>();
        
        int[][] field=new int[][]{
            {23,23},{24,23},{25,23},
            {23,24},{24,24},{25,24},{26,24},
            {22,25},{23,25},{24,25},{25,25},{26,25},
            {23,26},{24,26},{25,26},{26,26},
            {23,27},{24,27},{25,27},
        };
        main.changeBornRule(2, 0, 0);
        main.changeBlueRule(3, 0, 0);
        main.changeBlueRule(4, 0, 0);
        
        for(int n=0;n<Math.pow(2,19);n++){
            String bin=Integer.toBinaryString(n);
            for(int m=0;m<bin.length();m++){
                if(bin.charAt(m)=='1'){
                    main.setPoint(field[19-bin.length()+m][0],field[19-bin.length()+m][1],1);
                }
            }
            boolean found=false;
            for(int m=0;m<300;m++){
                main.next();
                if(main.extinct()||main.settlement()){break;}
                for(int k=0;k<main.getWidth();k++){
                    if(main.getPoint(k, 0)==1||main.getPoint(0, k)==1){
                        found=true;
                        break;
                    }
                }
                if(found){break;}
            }
            if(found){
                System.out.println("Moving Object Detected. "+n+" ("+bin+")");
                panel.setBoard(main.copy());
                result.add(n);
            }else{
                System.out.println("Failed. "+n+" ("+bin+")");
            }
            main.clearAll();
        }
        System.out.println(Arrays.toString(result.toArray()));
    }
}

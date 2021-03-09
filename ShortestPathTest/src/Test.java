/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */

/**
 *
 * @author よもぎ
 */
public class Test {

    public static void main(String args[]) {
        int w=5;
        int n=10;
        int y=128;
        String result="";
        while(n>0){
            n--;
            if(y<combination(n, w)){
                result+="0";
            }else{
                result+="1";
                y-=combination(n, w);
                w--;
            }
        }
        System.out.println(result);
    }

    //return nCm
    private static int combination(int n, int m) {
        if (n < m) {
            return 0;
        } else {
            return fac(n) / (fac(n - m) * fac(m));
        }
    }

    //return n!
    private static int fac(int n) {
        if (n <= 1) {
            return 1;
        } else {
            return fac(n - 1) * n;
        }
    }

}

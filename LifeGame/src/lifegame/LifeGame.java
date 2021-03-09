/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package lifegame;

/**
 *
 * @author Yomogi
 */
public class LifeGame {

    /**
     * @param args the command line arguments
     */
    public static void main(String[] args) {
        Frame frame=new Frame();
        Panel panel=new Panel();
        frame.add(panel);
        frame.setVisible(true);
        //SimulateManager simulator=new SimulateManager(panel);
        //simulator.start();
    }
    
}

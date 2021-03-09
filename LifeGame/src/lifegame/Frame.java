/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package lifegame;

import java.awt.Dimension;
import javax.swing.JFrame;

/**
 *
 * @author Yomogi
 */
public class Frame extends JFrame{
    public Frame(){
        setTitle("LifeSimulator");
        setResizable(false);
        getContentPane().setPreferredSize(new Dimension(1080,720));
        pack();
        setDefaultCloseOperation(EXIT_ON_CLOSE);
    }
}

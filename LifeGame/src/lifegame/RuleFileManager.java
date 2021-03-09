/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package lifegame;

import java.awt.Component;
import java.io.File;
import java.io.FileReader;
import java.io.FileWriter;
import java.io.IOException;
import javax.swing.JFileChooser;

/**
 *
 * @author Yomogi
 */
public class RuleFileManager {
    
    private final String DIRPASS="./rules/";
    private final File DIRECTORY;
    
    public RuleFileManager(){
        DIRECTORY=new File(DIRPASS);
    }
    
    public void saveRuleFile(Board board,String name){
        DIRECTORY.mkdirs();
        File file=new File(DIRPASS+name+".rd");
        saveRuleFile(board,file);
    }
    public void saveRuleFile(Board board,File file){
        try {
            file.createNewFile();
            FileWriter writer=new FileWriter(file);
            for(int n=0;n<7;n++){  
                for(int m=0;m<7;m++){
                    for(int k=0;k<7;k++){
                        writer.write(String.valueOf(board.getBornRule(n, m, k)));
                        writer.write(String.valueOf(board.getBlueRule(n, m, k)));
                        writer.write(String.valueOf(board.getGreenRule(n, m, k)));
                    }  
                }
            }
            writer.flush();
            writer.close();
        } catch (IOException ex) {
            System.out.println("駄目です。");
        }
    }
    public void loadRuleFile(Board board,String name){
        loadRuleFile(board,new File(DIRPASS+name+".rd"));
    }
    public void loadRuleFile(Board board,File file){
        try {
            if(!file.exists()){
                System.out.println("File Not Found");
                return;
            }
            FileReader reader=new FileReader(file);
            for(int n=0;n<7;n++){  
                for(int m=0;m<7;m++){
                    for(int k=0;k<7;k++){
                        board.setBornRule(n, m, k,reader.read()-48);
                        board.setBlueRule(n, m, k,reader.read()-48);
                        board.setGreenRule(n, m, k,reader.read()-48);
                    }
                }
            }
            reader.close();
        } catch (IOException ex) {
            System.out.println("駄目です。");
        }
    }
    public void importRuleFile(Board board,Component parent){
        JFileChooser chooser=new JFileChooser();
        if(chooser.showOpenDialog(parent)==JFileChooser.APPROVE_OPTION){
            loadRuleFile(board,chooser.getSelectedFile());
        }
    }
    public void exportRuleFile(Board board,Component parent){
        JFileChooser chooser=new JFileChooser();
        if(chooser.showSaveDialog(parent)==JFileChooser.APPROVE_OPTION){
            saveRuleFile(board,chooser.getSelectedFile());
        }
    }
}

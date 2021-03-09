/*
 * To change this license header, choose License Headers in Project Properties.
 * To change this template file, choose Tools | Templates
 * and open the template in the editor.
 */
package lifegame;

import java.awt.Color;
import java.awt.Font;
import java.awt.Graphics;
import java.awt.Point;
import java.awt.Polygon;
import java.awt.event.KeyEvent;
import java.awt.event.KeyListener;
import java.awt.event.MouseEvent;
import java.awt.event.MouseWheelEvent;
import java.awt.event.MouseWheelListener;
import static java.lang.Math.sqrt;
import javax.swing.JPanel;
import javax.swing.event.MouseInputListener;

/**
 *
 * @author Yomogi
 */
public class Panel extends JPanel implements MouseInputListener,MouseWheelListener,KeyListener,Runnable{
    
    private Board board;
    private int scale;
    private Point basis;
    
    private boolean working;
    private boolean grid;
    private double speed;
    
    private Point pre_mousepos=new Point(-1,-1);
    private int palette=1;
    private int[] slicer=new int[3];
    private boolean green_axis=true;
    private RuleFileManager rulemanager=new RuleFileManager();
    
    public Panel(){
        board=new Board(100,100);
        scale=4;
        basis=new Point(300,0);
        working=false;
        grid=true;
        speed=1;
        addMouseListener(this);
        addMouseMotionListener(this);
        addKeyListener(this);
        addMouseWheelListener(this);
        setFocusable(true);
        Thread thread=new Thread(this);
        thread.start();
    }

    @Override
    public void paintComponent(Graphics g) {
        super.paintComponent(g);
        double[][] vertex=new double[][]{{sqrt(3),0},{0,1},{0,3},{sqrt(3),4},{sqrt(3)*2,3},{sqrt(3)*2,1}};
        Polygon hex=new Polygon();
        for(int n=0;n<6;n++){
            hex.addPoint((int)(vertex[n][0]*scale),(int)(vertex[n][1]*scale));
        }
        hex.translate(basis.x,basis.y);
        Color[] COLORS=new Color[]{Color.BLACK,Color.BLUE,Color.RED,Color.GREEN};
        for(int n=0;n<board.getHeight();n++){
            for(int m=0;m<board.getWidth();m++){
                g.setColor(COLORS[board.getPoint(m, n)]);
                g.fillPolygon(hex);
                if(grid){
                    g.setColor(Color.white);
                    g.drawPolygon(hex);
                }
                hex.translate((int)(sqrt(3)*2*scale),0);
            }
            hex.translate(basis.x-hex.xpoints[1]-(int)Math.round((sqrt(3)*scale)*(n%2-1)),3*scale);
        }
        //オプション背景
        g.setColor(Color.LIGHT_GRAY);
        g.fillRect(0,0,300,720);
        //ルール表示
        g.setColor(COLORS[0]);
        g.fillRect(4,4,18,18);
        g.setColor(COLORS[1]);
        g.fillRect(152,4,18,18);
        g.setColor(COLORS[3]);
        g.fillRect(4,152,18,18);
        for(int m=0;m<7;m++){
            for(int n=0;n<7;n++){
                //born
                g.setColor(new Color[]{Color.BLACK,Color.BLUE,Color.GREEN}[green_axis ? board.getBornRule(m, n,slicer[0]) : board.getBornRule(m, slicer[0],n)]);
                g.fillRect((m+1)*18+4, (n+1)*18+4, 18, 18);
                //blue
                g.setColor(COLORS[green_axis ? board.getBlueRule(m, n, slicer[1]) : board.getBlueRule(m, slicer[1] ,n)]);
                g.fillRect((m+1)*18+152, (n+1)*18+4, 18, 18);
                //green
                g.setColor(new Color[]{Color.BLACK,Color.GREEN,Color.BLUE}[green_axis ? board.getGreenRule(m, n, slicer[2]) : board.getGreenRule(m, slicer[2], n)]);
                g.fillRect((m+1)*18+4, (n+1)*18+152, 18, 18);
                //grid
                g.setColor(Color.WHITE);
                g.drawRect((m+1)*18+4, (n+1)*18+4, 18, 18);
                g.drawRect((m+1)*18+152, (n+1)*18+4, 18, 18);
                g.drawRect((m+1)*18+4, (n+1)*18+152, 18, 18);
            }
        }
        g.setFont(new Font("Arial",Font.BOLD,13));
        g.setColor(Color.WHITE);
        g.drawString(Integer.toString(slicer[0]),11,20);
        g.drawString(Integer.toString(slicer[1]),159,20);
        g.drawString(Integer.toString(slicer[2]),11,168);
        for(int n=0;n<7;n++){
            g.setColor(COLORS[1]);
            g.drawString(Integer.toString(n),29+18*n,20);
            g.drawString(Integer.toString(n),29+18*n,168);
            g.drawString(Integer.toString(n),177+18*n,20);
            g.setColor(green_axis ? COLORS[2] : COLORS[3]);
            g.drawString(Integer.toString(n),11,38+18*n);
            g.drawString(Integer.toString(n),11,186+18*n);
            g.drawString(Integer.toString(n),159,38+18*n);
        }
        //パレット表示
        g.setColor(Color.GRAY);
        g.fillRect(310,660,50,50);
        g.setColor(COLORS[palette]);
        g.fillRect(315,665,40,40);
        //スピード表示
        g.setColor(Color.WHITE);
        g.setFont(new Font("Arial",Font.BOLD,15));
        g.drawString("SPEED x"+(Math.round(speed*10)/10.0)+(working?"  Running..":""),10,705);
        //サイズ表示
        g.drawString("SIZE "+board.getWidth()+"x"+board.getHeight(),10,685);
        //説明表示
        g.setColor(Color.WHITE);
        g.setFont(new Font("Arial",Font.BOLD,12));
        g.drawString("S : Start/Stop",10,320);
        g.drawString("X : Speed up",10,340);
        g.drawString("Z : Speed down",10,360);
        g.drawString("C : Change palette color",10,380);
        g.drawString("F : Change field size",10,400);
        g.drawString("K : Change table's axis",10,420);
        g.drawString("R : Random fill(V,B)",10,440);
        g.drawString("T : Random fill(V,B,R)",10,460);
        g.drawString("Y : Random fill(B,R)",10,480);
        g.drawString("U : Random fill(V,B,R,G)",10,500);
        g.drawString("D : Clear field",10,520);
        g.drawString("G : Grid on/off",10,540);
        g.drawString("Space : Frame advance",10,560);
    }
    @Override
    public void run() {
        while(true){
            if(working){
                board.next();
                repaint();
            }
            try{
                Thread.sleep((int)(1024/Math.pow(2,speed)));
            }catch(Exception e){}
        }
    }
    
    public void setBoard(Board board){
        this.board=board;
    }
    
    @Override
    public void mouseClicked(MouseEvent e) {}
    @Override
    public void mousePressed(MouseEvent e) {
        switch(e.getButton()){
            case MouseEvent.BUTTON1:
                if(e.getX()>4&&e.getX()<148&&e.getY()>4&&e.getY()<148){
                    int x=(int)Math.floor((e.getX()-22)/18.0);
                    int y=(int)Math.floor((e.getY()-22)/18.0);
                    if(x==-1&&y==-1){
                        slicer[0]=(slicer[0]+1)%7;
                    }else if(x>=0&&y>=0){
                        if(green_axis){
                            board.changeBornRule(x,y,slicer[0]);
                        }else{
                            board.changeBornRule(x,slicer[0],y);
                        }
                    }
                }else if(e.getX()>152&&e.getX()<296&&e.getY()>4&&e.getY()<148){
                    int x=(int)Math.floor((e.getX()-170)/18.0);
                    int y=(int)Math.floor((e.getY()-22)/18.0);
                    if(x==-1&&y==-1){
                        slicer[1]=(slicer[1]+1)%7;
                    }else if(x>=0&&y>=0){
                        if(green_axis){
                            board.changeBlueRule(x,y,slicer[1]);
                        }else{
                            board.changeBlueRule(x,slicer[1],y);
                        }
                    }
                }else if(e.getX()>4&&e.getX()<148&&e.getY()>152&&e.getY()<296){
                    int x=(int)Math.floor((e.getX()-22)/18.0);
                    int y=(int)Math.floor((e.getY()-170)/18.0);
                    if(x==-1&&y==-1){
                        slicer[2]=(slicer[2]+1)%7;
                    }else if(x>=0&&y>=0){
                        if(green_axis){
                            board.changeGreenRule(x,y,slicer[2]);
                        }else{
                            board.changeGreenRule(x,slicer[2],y);
                        }
                    }
                }else if(e.getX()>300){
                    Point p=e.getPoint();
                    p.translate(-basis.x-(int)Math.round(sqrt(3)*scale),-basis.y-(int)(0.5*scale));
                    int y=(int)Math.floor(p.y/(double)(3*scale));
                    int x= y%2==0 ? (int)Math.round((double)p.x/(int)(sqrt(3)*2*scale)) : (int)Math.floor((double)p.x/(int)(sqrt(3)*2*scale)) ;
                    if(x>=0&&x<board.getWidth()&&y>=0&&y<board.getHeight()){
                        board.setPoint(x, y,palette);
                    }
                }
                break;
            case MouseEvent.BUTTON3:
                pre_mousepos=e.getPoint();
                break;
        }
        repaint();
    }
    @Override
    public void mouseReleased(MouseEvent e) {
        switch(e.getButton()){
            case MouseEvent.BUTTON1:
                break;
            case MouseEvent.BUTTON3:
                pre_mousepos=new Point(-1,-1);
                break;
        }
    }
    @Override
    public void mouseEntered(MouseEvent e) {}
    @Override
    public void mouseExited(MouseEvent e) {}
    @Override
    public void mouseDragged(MouseEvent e) {
        if(pre_mousepos.x>=0){
            basis.translate(e.getX()-pre_mousepos.x,e.getY()-pre_mousepos.y);
            pre_mousepos=e.getPoint();
            repaint();
        }
    }
    @Override
    public void mouseMoved(MouseEvent e) {}

    @Override
    public void mouseWheelMoved(MouseWheelEvent e) {
        int pre_scale=scale;
        if ( e.getWheelRotation() == -1 ) {
            scale=(int)Math.round(scale*1.3);
        } else if (e.getWheelRotation() == 1 && scale>2) {
            scale=(int)Math.round(scale*0.8);
	}
        basis.translate((int)Math.round(((int)(sqrt(3)*2*pre_scale)-(int)(sqrt(3)*2*scale))/Math.floor(sqrt(3)*2*pre_scale)*(e.getX()-basis.x)),(int)Math.round((pre_scale-scale)/(double)pre_scale*(e.getY()-basis.y)));
        repaint();
    }

    @Override
    public void keyTyped(KeyEvent e) {}
    @Override
    public void keyPressed(KeyEvent e) {
        switch(e.getKeyCode()){
            case KeyEvent.VK_S: working=!working;break;
            case KeyEvent.VK_Z: speed=Math.max(speed-0.1,0.1);break;
            case KeyEvent.VK_X: speed=Math.min(speed+0.1,10);break;
            case KeyEvent.VK_C: palette=(palette+1)%4;break;
            case KeyEvent.VK_K: green_axis=!green_axis;break;
            case KeyEvent.VK_R: board.randomFill(0.5,0,0);break;
            case KeyEvent.VK_T: board.randomFill(0.333,0.333,0);break;
            case KeyEvent.VK_Y: board.randomFill(0.5,0.5,0);break;
            case KeyEvent.VK_U: board.randomFill(0.25,0.25,0.25);break;
            case KeyEvent.VK_D: board.clearAll();break;
            case KeyEvent.VK_G: grid=!grid;break;
            case KeyEvent.VK_F: 
                board.setWidth(board.getWidth()<200 ? board.getWidth()+25 : 25);
                board.setHeight(board.getHeight()<200 ? board.getHeight()+25 : 25);
                break;
            case KeyEvent.VK_SPACE: board.next();break;
            case KeyEvent.VK_I: for(int n=0;n<10;n++)board.next();break;
            case KeyEvent.VK_P: rulemanager.exportRuleFile(board,this);break;
            case KeyEvent.VK_L: rulemanager.importRuleFile(board,this);break;
        }
        repaint();
    }
    @Override
    public void keyReleased(KeyEvent e) {}
}

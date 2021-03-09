
public class MyEdge {

    protected int tip1;
    protected int tip2;
    protected int weight;

    public MyEdge(int tip1, int tip2, int weight) {
        this.tip1 = tip1;
        this.tip2 = tip2;
        this.weight = weight;
    }

    //get inverse of this edge
    public MyEdge getInverse() {
        return new MyEdge(tip2, tip1, weight);
    }
}

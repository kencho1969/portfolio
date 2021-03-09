
public class DistanceGraphTest {

    public static void main(String args[]) {
        if (args.length != 7) {
            System.err.println("Usage: graph_filename, coordinate_filename, start_longitude, start_latitude, terminal_longitude, terminal_latitude, output_filename");
            return;
        }
        final String GRAPH_FILE = args[0];
        final String COORDINATE_FILE = args[1];
        final String OUTPUT_FILE = args[6];
        double start_longitude = Double.valueOf(args[2]);
        double start_latitude = Double.valueOf(args[3]);
        double terminal_longitude = Double.valueOf(args[4]);
        double terminal_latitude = Double.valueOf(args[5]);
        DistanceGraph graph = new DistanceGraph();
        graph.readFromFile(GRAPH_FILE, COORDINATE_FILE);
        for(int n=0;n<1;n++){
            graph.outputShortestPass(start_longitude, start_latitude, terminal_longitude, terminal_latitude, OUTPUT_FILE);
        }
    }
}

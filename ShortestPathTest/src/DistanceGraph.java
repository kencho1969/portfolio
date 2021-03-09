
import java.awt.Point;
import java.io.File;
import java.io.FileNotFoundException;
import java.io.FileWriter;
import java.io.IOException;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Collections;
import java.util.Comparator;
import java.util.InputMismatchException;
import java.util.Iterator;
import java.util.LinkedList;
import java.util.List;
import java.util.Scanner;

public class DistanceGraph {

    private ArrayList<LinkedList<MyEdge>> edges = new ArrayList<>();
    private ArrayList<ArrayList<Label>> label;//[distance, basis-vertex, prev-vertex]
    private Point[] coordinate;
    private KDNode kd_root;

    public void readFromFile(String graphfile, String coordinatefile) {
        System.out.print("Loading graph file... ");
        File file = new File(graphfile);
        try (Scanner scan = new Scanner(file)) {
            int vertex_num = scan.nextInt();
            int edge_num = scan.nextInt();
            for (int n = 0; n < vertex_num; n++) {
                edges.add(new LinkedList<>());
            }
            int signal = 0;
            int[] temp = new int[3];
            while (scan.hasNext()) {
                temp[signal] = scan.nextInt();
                signal = (signal + 1) % 3;
                if (signal == 0) {
                    if (temp[0] >= vertex_num || temp[1] >= vertex_num) {
                        System.err.println("頂点番号が上限を超えています");
                    } else if (temp[0] == temp[1]) {
                        System.err.println("同一頂点間に辺を作ることはできません");
                    } else {
                        MyEdge edge = new MyEdge(temp[0], temp[1], temp[2]);
                        edges.get(temp[0]).add(edge);
                        edges.get(temp[1]).add(edge.getInverse());
                        edge_num--;
                    }
                }
            }
            if (signal != 0) {
                System.err.println("入力データの整合性が取れませんでした");
            }
            if (edge_num != 0) {
                System.err.println("辺数が誤っているか、一部の辺データを読み込めませんでした");
            }
        } catch (FileNotFoundException ex) {
            System.err.println("グラフファイルが見つかりません");
        } catch (InputMismatchException ex) {
            System.err.println("データは整数値で入力してください");
        }
        System.out.println("done.");
        constructLabel();
        //Coordinate
        System.out.print("Loading coordinate file... ");
        file = new File(coordinatefile);
        try (Scanner scan = new Scanner(file)) {
            coordinate = new Point[edges.size()];
            if (coordinate.length != scan.nextInt()) {
                System.err.println("グラフファイルと座標ファイルが対応していません");
            }
            int signal = 0;
            int[] temp = new int[3];
            while (scan.hasNext()) {
                temp[signal] = scan.nextInt();
                signal = (signal + 1) % 3;
                if (signal == 0) {
                    coordinate[temp[0]] = new Point(temp[1], temp[2]);
                }
            }
        } catch (FileNotFoundException ex) {
            System.err.println("座標ファイルが見つかりません");
        } catch (InputMismatchException ex) {
            System.err.println("データは整数値で入力してください");
        }
        System.out.println("done.");
        System.out.print("Constructing neighborhood tree... ");
        ArrayList<CoordinateVertex> vertexes = new ArrayList<>();
        for (int n = 0; n < coordinate.length; n++) {
            vertexes.add(new CoordinateVertex(n, coordinate[n]));
        }
        kd_root = new KDNode(vertexes, true);
        System.out.println("done.");
    }

    private void constructLabel() {
        ArrayList<Integer> order = new ArrayList<>();
        for (int n = 0; n < edges.size(); n++) {
            order.add(n);
        }
        order.sort(Comparator.comparing(x -> edges.get(x).size(), Comparator.reverseOrder()));
        label = new ArrayList<>();
        for (LinkedList<MyEdge> edge : edges) {
            label.add(new ArrayList<>());
        }
        int[] distance = new int[edges.size()];//distance from the starting vertex
        int[] prev = new int[edges.size()];//previous vertex on the shortest path
        int[][] heap = new int[edges.size()][2];
        int[] index_trans = new int[edges.size()];//index_trans[vertex_index]=heap_index
        int ver_count = 0;
        int process = 0;
        double interval = Math.pow(edges.size(), 1 / 3d) / 100;
        for (Integer v : order) {
            while (ver_count >= Math.pow(process * interval, 3) - 2 && process <= 100) {
                System.out.print("Constructing label... " + process + "% ");
                if (process == 100) {
                    System.out.println("done.");
                } else {
                    System.out.println("");
                }
                process++;
            }
            ver_count++;
            Arrays.fill(distance, Integer.MAX_VALUE);
            distance[v] = 0;
            heap[0] = new int[]{v, 0};
            index_trans[v] = 0;
            int heap_limit = 0;//maximum index of heap region
            while (true) {
                if (heap_limit < 0) {
                    break;
                }
                int ver = heap[0][0];
                swapHeap(heap, index_trans, 0, heap_limit);
                heap_limit--;
                downHeap(heap, index_trans, 0, heap_limit);
                if (query(v, ver)[0] <= distance[ver]) {
                    continue;
                }
                int min = 0;
                int max = label.get(ver).size();
                while (min != max) {
                    if (label.get(ver).get((min + max) / 2).basis < v) {
                        min = (min + max) / 2 + 1;
                    } else {
                        max = (min + max) / 2;
                    }
                }
                label.get(ver).add(min, new Label(distance[ver], v, prev[ver]));
                for (MyEdge edg : getEdges(ver)) {
                    int nei = edg.tip2;
                    if (distance[nei] == Integer.MAX_VALUE) {
                        distance[nei] = distance[ver] + edg.weight;
                        heap_limit++;
                        index_trans[nei] = heap_limit;
                        heap[heap_limit][0] = nei;
                        heap[heap_limit][1] = distance[nei];
                        upHeap(heap, index_trans, heap_limit);
                        prev[nei] = ver;
                    } else if (distance[nei] > distance[ver] + edg.weight) {
                        distance[nei] = distance[ver] + edg.weight;
                        heap[index_trans[nei]][1] = distance[nei];
                        upHeap(heap, index_trans, index_trans[nei]);
                        downHeap(heap, index_trans, nei, heap_limit);
                        prev[nei] = ver;
                    }
                }
            }
        }
    }

    public LinkedList<MyEdge> getEdges(int id) {
        return edges.get(id);
    }

    private int[] query(int start, int terminal) {
        Iterator<Label> ite1 = label.get(start).iterator();
        Iterator<Label> ite2 = label.get(terminal).iterator();
        int[] result = new int[]{Integer.MAX_VALUE, -1};
        if (!(ite1.hasNext() && ite2.hasNext())) {
            return result;
        }
        Label lab1 = ite1.next();
        Label lab2 = ite2.next();
        while (true) {
            if (lab1.basis == lab2.basis) {
                if (lab1.distance + lab2.distance < result[0]) {
                    result[0] = lab1.distance + lab2.distance;
                    result[1] = lab1.basis;
                }
                if (!(ite1.hasNext() && ite2.hasNext())) {
                    return result;
                }
                lab1 = ite1.next();
                lab2 = ite2.next();
            } else if (lab1.basis < lab2.basis) {
                if (!ite1.hasNext()) {
                    return result;
                }
                lab1 = ite1.next();
            } else {
                if (!ite2.hasNext()) {
                    return result;
                }
                lab2 = ite2.next();
            }
        }
    }

    public void outputShortestPass(double start_longitude, double start_latitude, double terminal_longitude, double terminal_latitude, String outputfile) {
        long time1 = System.nanoTime();
        Point start_temp = new Point((int) (start_longitude * 1e6), (int) (start_latitude * 1e6));
        Point terminal_temp = new Point((int) (terminal_longitude * 1e6), (int) (terminal_latitude * 1e6));
        int start = kd_root.findNearestPoint(start_temp).id;
        int terminal = kd_root.findNearestPoint(terminal_temp).id;
        long time2 = System.nanoTime();
        int relay = query(start, terminal)[1];
        long time3 = System.nanoTime();
        if (relay != -1) {
            ArrayList<Integer> path1 = new ArrayList<>(100);
            ArrayList<Integer> path2 = new ArrayList<>(100);
            path1.add(start);
            path2.add(terminal);
            int pos = start;
            ArrayList<Label> labels;
            Label temp;
            int min, max;
            while (pos != relay) {
                labels = label.get(pos);
                min = 0;
                max = labels.size() - 1;
                while ((temp = labels.get((min + max) / 2)).basis != relay) {
                    if (temp.basis < relay) {
                        min = (min + max) / 2 + 1;
                    } else {
                        max = (min + max) / 2 - 1;
                    }
                }
                path1.add(pos = temp.prev);
            }
            pos = terminal;
            while (pos != relay) {
                labels = label.get(pos);
                min = 0;
                max = labels.size() - 1;
                while ((temp = labels.get((min + max) / 2)).basis != relay) {
                    if (temp.basis < relay) {
                        min = (min + max) / 2 + 1;
                    } else {
                        max = (min + max) / 2 - 1;
                    }
                }
                path2.add(pos = temp.prev);
            }
            path2.remove(path2.size()-1);
            Collections.reverse(path2);
            path1.addAll(path2);
            long time4 = System.nanoTime();
            System.out.println("----------Result----------");
            System.out.println("Find nearest vertex: " + (time2 - time1) + "ns");
            System.out.println("Query time: " + (time3 - time2) + "ns");
            System.out.println("Determine shortest path: " + (time4 - time3) + "ns");
            System.out.println("Total time: " + (time4 - time1) + "ns");
            File output = new File(outputfile);
            try (FileWriter writer = new FileWriter(output)) {
                for (int ver : path1) {
                    writer.write(coordinate[ver].x + " " + coordinate[ver].y + "\n");
                }
                writer.flush();
            } catch (IOException ex) {
            }
        } else {
            System.out.println("頂点間のパスは存在しません");
        }
    }

    private void swapHeap(int[][] heap, int[] index_trans, int heap_index1, int heap_index2) {
        index_trans[heap[heap_index1][0]] = heap_index2;
        index_trans[heap[heap_index2][0]] = heap_index1;
        int[] temp = heap[heap_index1];
        heap[heap_index1] = heap[heap_index2];
        heap[heap_index2] = temp;
    }

    private void downHeap(int[][] heap, int[] index_trans, int heap_index, int limit) {
        while (heap_index * 2 + 1 <= limit) {
            int child;
            if (heap_index * 2 + 1 == limit || heap[heap_index * 2 + 1][1] < heap[heap_index * 2 + 2][1]) {
                child = heap_index * 2 + 1;
            } else {
                child = heap_index * 2 + 2;
            }
            if (heap[heap_index][1] > heap[child][1]) {
                swapHeap(heap, index_trans, heap_index, child);
                heap_index = child;
            } else {
                break;
            }
        }
    }

    private void upHeap(int[][] heap, int[] index_trans, int heap_index) {
        while (heap_index > 0) {
            int parent = (heap_index - 1) / 2;
            if (heap[heap_index][1] < heap[parent][1]) {
                swapHeap(heap, index_trans, heap_index, parent);
                heap_index = parent;
            } else {
                break;
            }
        }
    }

    private class KDNode extends CoordinateVertex {

        private KDNode child_l = null;
        private KDNode child_r = null;
        private boolean axis;

        //axis: true=x, false=y
        private KDNode(List<CoordinateVertex> points, boolean axis) {
            super();
            points.sort(Comparator.comparing(p -> axis ? p.x : p.y));
            this.axis = axis;
            ArrayList<CoordinateVertex> left = new ArrayList<>();
            for (int n = 0; n < points.size() / 2; n++) {
                left.add(points.remove(0));
            }
            CoordinateVertex self = points.remove(0);
            x = self.x;
            y = self.y;
            id = self.id;
            if (!left.isEmpty()) {
                child_l = new KDNode(left, !axis);
            }
            if (!points.isEmpty()) {
                child_r = new KDNode(points, !axis);
            }
        }

        private CoordinateVertex findNearestPoint(Point target) {
            if (child_l == null && child_r == null) {
                return this;
            } else if (child_r == null) {
                return target.distanceSq(this) < target.distanceSq(child_l) ? this : child_l;
            }
            CoordinateVertex temp = ((axis ? target.x < x : target.y < y) ? child_l : child_r).findNearestPoint(target);
            double temp_dissq = target.distanceSq(temp);
            if (Math.pow(axis ? target.x - x : target.y - y, 2) < temp_dissq) {
                double this_dissq = target.distanceSq(this);
                CoordinateVertex another = ((axis ? target.x < x : target.y < y) ? child_r : child_l).findNearestPoint(target);
                if (this_dissq < temp_dissq) {
                    temp = this;
                    temp_dissq = this_dissq;
                }
                if (target.distanceSq(another) < temp_dissq) {
                    return another;
                }
            }
            return temp;
        }
    }

    private class CoordinateVertex extends Point {

        protected int id;

        private CoordinateVertex() {
            super();
        }

        private CoordinateVertex(int vertex_id, Point point) {
            super(point);
            id = vertex_id;
        }
    }

    private static class Label {

        int distance;
        int basis;
        int prev;

        private Label(int distance, int basis, int prev) {
            this.distance = distance;
            this.basis = basis;
            this.prev = prev;
        }
    }
}

import java.io.File;
import java.io.FileWriter;
import java.io.IOException;

public class ExperimentHQ {

	/*
	 * 計算機実験(シミュレーション)
	 */

	public static void main(String[] args) {
		String dir = System.getProperty("user.dir"); //ファイルのディレクトリパスを取得
		File file = new File(dir + "/exp_hypercube_20161007.txt");
		FileWriter filewriter = null;
		for(int j=0; j<10; j++){//故障率：0～9割
			int trials = 10000;
			double dfs_suc = 0.0, bfs_suc = 0.0, rc_suc = 0.0, drc_suc = 0.0;
			double prob_suc = 0.0, arp0_suc = 0.0, arp1_suc = 0.0;
			double pathlen_dfs = 0.0, pathlen_bfs = 0.0, pathlen_rc = 0.0, pathlen_drc = 0.0;
			double pathlen_prob = 0.0, pathlen_arp0 = 0.0, pathlen_arp1 = 0.0;
			RoutingHQ val = new RoutingHQ(10, (double)j / 10);
			val.setNeighbors();
			for(int i=0; i<trials; i++){
				val.setFault();
				val.setSrcDst();
				if(val.bfs(val.getSrcNode(), val.getDstNode(), val.getFault()) == 1){
					//System.out.println("Source Node :      " + Integer.toBinaryString(val.getSrcNode()));
					//System.out.println("Destination Node : " + Integer.toBinaryString(val.getDstNode()));
					//System.out.println("Distance : " + val.getDistance(val.getSrcNode(), val.getDstNode()));
					bfs_suc++;
					pathlen_bfs += val.pathlen_bfs;
					if(val.dfs(val.getSrcNode(), val.getDstNode(), val.getFault()) == 1){
						dfs_suc++;
						pathlen_dfs += val.pathlen_dfs;
					}
					val.setRC(val.getSize(), val.getDim(), val.getNeighbors(), val.getFault());//経路選択能力
					if(val.route0(val.getSrcNode(), val.getDstNode(), val.getFault()) == 1){
						rc_suc++;
						pathlen_rc += val.pathlen_rc;
					}
					val.setDRC(val.getSize(), val.getDim(), val.getNeighbors(), val.getFault());//有向経路選択能力
					if(val.route1(val.getSrcNode(), val.getDstNode(), val.getFault()) == 1){
						drc_suc++;
						pathlen_drc += val.pathlen_drc;
					}
					val.setPRB(val.getSize(), val.getDim(), val.getNeighbors(), val.getFault());//確率的手法(Al-Sadiら)
					if(val.pb_routing(val.getSrcNode(), val.getDstNode(), val.getFault()) == 1){
						prob_suc++;
						pathlen_prob += val.pathlen_prob;
					}
					val.setARP(val.getSize(), val.getDim(), val.getNeighbors(), val.getFault());//近似到達確率
					if(val.dk0(val.getSrcNode(), val.getDstNode(), val.getFault()) == 1){
						arp0_suc++;
						pathlen_arp0 += val.pathlen_apr0;
					}
					if(val.dk1(val.getSrcNode(), val.getSrcNode(), val.getDstNode(), val.getFault()) == 1){
						arp1_suc++;
						pathlen_arp1 += val.pathlen_apr1;
					}
				}
				else i--;
			}

			try{
				filewriter = new FileWriter(file, true);
				if(j == 0){
					filewriter.write(",BFS,DFS,RC,DRC,PRB,ARP0,ARP1,BFS,DFS,RC,DRC,PRB,ARP0,ARP1\r\n");
				}
				filewriter.write(j * 10 + ",");
				filewriter.write(100 * bfs_suc / trials + ",");
				filewriter.write(100 * dfs_suc / trials + ",");
				filewriter.write(100 * rc_suc / trials + ",");
				filewriter.write(100 * drc_suc / trials + ",");
				filewriter.write(100 * prob_suc / trials + ",");
				filewriter.write(100 * arp0_suc / trials + ",");
				filewriter.write(100 * arp1_suc / trials + ",");
				filewriter.write(pathlen_bfs / bfs_suc + ",");
				filewriter.write(pathlen_dfs / dfs_suc + ",");
				filewriter.write(pathlen_rc /rc_suc + ",");
				filewriter.write(pathlen_drc /drc_suc + ",");
				filewriter.write(pathlen_prob /prob_suc + ",");
				filewriter.write(pathlen_arp0 /arp0_suc + ",");
				filewriter.write(pathlen_arp1 /arp1_suc + "\r\n");

				System.out.println("実験結果をファイルに書き込みました");
			}
			catch(IOException e){
				System.out.println(e);
			}
			finally{
				if(filewriter != null)
					try{
						filewriter.close();
					}
				catch(IOException e){
					System.out.println(e);
				}
			}
			System.out.println("Ratio of Reachability BFS : " + 100 * bfs_suc / trials + "[%]");
			System.out.println("Average Path Length BFS : " + pathlen_bfs / bfs_suc);
			System.out.println("Ratio of Reachability DFS : " + 100 * dfs_suc / trials + "[%]");
			System.out.println("Average Path Length DFS : " + pathlen_dfs / dfs_suc);
			System.out.println("Ratio of Reachability RC : " + 100 * rc_suc / trials + "[%]");
			System.out.println("Average Path Length RC : " + pathlen_rc / rc_suc);
			System.out.println("Ratio of Reachability DRC : " + 100 * drc_suc / trials + "[%]");
			System.out.println("Average Path Length DRC : " + pathlen_drc / drc_suc);
			System.out.println("Ratio of Reachability PB : " + 100 * prob_suc / trials + "[%]");
			System.out.println("Average Path Length PB : " + pathlen_prob / prob_suc);
			System.out.println("Ratio of Reachability DK0 : " + 100 * arp0_suc / trials + "[%]");
			System.out.println("Average Path Length DK0 : " + pathlen_arp0 / arp0_suc);
			System.out.println("Ratio of Reachability DK1 : " + 100 * arp1_suc / trials + "[%]");
			System.out.println("Average Path Length DK1 : " + pathlen_arp1 / arp1_suc);
		}

	}

}
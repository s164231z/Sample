import java.util.Arrays;
import java.util.LinkedList;

class RoutingHQ extends Hypercube{

	/*
	 * Hypercubeにおける
	 * 幅優先探索
	 * 距離優先探索
	 * 制限付き帯域情報に基づくルーティング
	 */

	int pathlen_bfs = 0, pathlen_dfs = 0, pathlen_rc = 0, pathlen_drc = 0;
	int pathlen_prob = 0, pathlen_apr0 = 0, pathlen_apr1 = 0;
	int dist, cnt_bfs = 0, cnt = -1, n0, n1;
	int[] check = new int[getSize()];
	int[] check_bfs = new int[getSize()];

	public RoutingHQ(int dim, double ratio){
		super(dim, ratio);
	}

	public int bfs(int src, int dst, int[] fault){//Breadth First Search
		int[][] nei = getNeighbors();
		check_bfs[src] = 1;
		LinkedList<Integer> queue = new LinkedList<Integer>();
		queue.offer(src);
		queue.offer(-1);
		while(queue.peek() != null){
			int t = queue.poll();
			if(t == dst){
				Arrays.fill(check_bfs, 0);
				pathlen_bfs = cnt_bfs;
				cnt_bfs = 0;
				return 1;
			}
			else if(t == -1){
				cnt_bfs++;
				queue.offer(-1);
				if(queue.peek() == -1){
					break;
				}
			}
			else{
				for(int i=0; i<nei[t].length; i++){
					int str = nei[t][i];
					if(fault[str] != 1 && check_bfs[str] != 1){
						check_bfs[str] = 1;
						queue.offer(str);
					}
				}
			}
		}
		Arrays.fill(check_bfs, 0);
		cnt_bfs = 0;
		return 0;
	}

	public int dfs(int src, int dst, int[] fault){//Distance First Search
		cnt++;
		dist = getDistance(src, dst);
		if(dist == 0){
			pathlen_dfs = cnt;
			cnt = -1;
			Arrays.fill(check, 0);
			return 1;
		}
		else if(dist == 1){
			check[src] = 1;
			return dfs(dst, dst, fault);
		}
		else{
			LinkedList<Integer> prfnode = getPrfNode(src, dst);
			while(prfnode.peek() != null){
				int str = prfnode.poll();
				if(fault[str] != 1){
					if(check[str] == 1){
						cnt = -1;
						Arrays.fill(check, 0);
						return 0;
					}
					check[str] = 1;
					return dfs(str, dst, fault);
				}
			}
			LinkedList<Integer> sprnode = getSprNode(src, dst);
			while(sprnode.peek() != null){
				int str = sprnode.poll();
				if(fault[str] != 1){
					if(check[str] == 1){
						cnt = -1;
						Arrays.fill(check, 0);
						return 0;
					}
					check[str] = 1;
					return dfs(str, dst, fault);
				}
			}
		}
		cnt = -1;
		Arrays.fill(check, 0);
		return 0;
	}

	public int route0(int src, int dst, int[] fault){//Fault-tolerant routing based on routing capabilities
		int r = 1;
		cnt++;
		dist = getDistance(src, dst);
		if(dist == 0){
			pathlen_rc = cnt;
			cnt = -1;
			Arrays.fill(check, 0);
			return 1;
		}
		else if(dist == 1){
			check[src] = 1;
			return route0(dst, dst, fault);
		}
		else{
			int[][] str_cpb = getRC();
			LinkedList<Integer> prfnode = getPrfNode(src, dst);
			while(prfnode.peek() != null){
				int str = prfnode.poll();
				if(fault[str] != 1 && str_cpb[str][dist-1] == 1){
					if(check[str] == 1){
						cnt = -1;
						Arrays.fill(check, 0);
						return 0;
					}
					check[str] = 1;
					return route0(str, dst, fault);
				}
			}
			while(dist + r <= getDim()){
				LinkedList<Integer> sprnode = getSprNode(src, dst);
				while(sprnode.peek() != null){
					int str = sprnode.poll();
					if(fault[str] != 1 && str_cpb[str][dist+r] == 1){
						if(check[str] == 1){
							cnt = -1;
							Arrays.fill(check, 0);
							return 0;
						}
						check[str] = 1;
						return route0(str, dst, fault);
					}
				}
				r += 2;
			}
			LinkedList<Integer> prfnode1 = getPrfNode(src, dst);
			while(prfnode1.peek() != null){
				int str = prfnode1.poll();
				if(fault[str] != 1){
					if(check[str] == 1){
						cnt = -1;
						Arrays.fill(check, 0);
						return 0;
					}
					check[str] = 1;
					return route0(str, dst, fault);
				}
			}
			LinkedList<Integer> sprnode1 = getSprNode(src, dst);
			while(sprnode1.peek() != null){
				int str = sprnode1.poll();
				if(fault[str] != 1){
					if(check[str] == 1){
						cnt = -1;
						Arrays.fill(check, 0);
						return 0;
					}
					check[str] = 1;
					return route0(str, dst, fault);
				}
			}
		}
		cnt = -1;
		Arrays.fill(check, 0);
		return 0;
	}

	public int route1(int src, int dst, int[] fault){//Fault-tolerant routing based on directed routing capabilities
		int r = 1;
		cnt++;
		dist = getDistance(src, dst);
		if(dist == 0){
			pathlen_drc = cnt;
			cnt = -1;
			Arrays.fill(check, 0);
			return 1;
		}
		else if(dist == 1){
			check[src] = 1;
			return route1(dst, dst, fault);
		}
		else{
			int[][] str_cpb = getDRC();
			LinkedList<Integer> prfnode = getPrfNode(src, dst);
			while(prfnode.peek() != null){
				int str = prfnode.poll();
				if(fault[str] != 1 && str_cpb[str][dist-1] == 1){
					if(check[str] == 1){
						cnt = -1;
						Arrays.fill(check, 0);
						return 0;
					}
					check[str] = 1;
					return route1(str, dst, fault);
				}
			}
			while(dist + r <= getDim()){
				LinkedList<Integer> sprnode = getSprNode(src, dst);
				while(sprnode.peek() != null){
					int str = sprnode.poll();
					if(fault[str] != 1 && str_cpb[str][dist+r] == 1){
						if(check[str] == 1){
							cnt = -1;
							Arrays.fill(check, 0);
							return 0;
						}
						check[str] = 1;
						return route1(str, dst, fault);
					}
				}
				r += 2;
			}
			LinkedList<Integer> prfnode1 = getPrfNode(src, dst);
			while(prfnode1.peek() != null){
				int str = prfnode1.poll();
				if(fault[str] != 1){
					if(check[str] == 1){
						cnt = -1;
						Arrays.fill(check, 0);
						return 0;
					}
					check[str] = 1;
					return route1(str, dst, fault);
				}
			}
			LinkedList<Integer> sprnode1 = getSprNode(src, dst);
			while(sprnode1.peek() != null){
				int str = sprnode1.poll();
				if(fault[str] != 1){
					if(check[str] == 1){
						cnt = -1;
						Arrays.fill(check, 0);
						return 0;
					}
					check[str] = 1;
					return route1(str, dst, fault);
				}
			}
		}
		cnt = -1;
		Arrays.fill(check, 0);
		return 0;
	}

	public int pb_routing(int cur, int dst, int[] fault){//probability-based fault-tolerant routing
		double pmin = 1.0;
		cnt++;
		dist = getDistance(cur, dst);
		if(dist == 0){
			pathlen_prob = cnt;
			cnt = -1;
			Arrays.fill(check, 0);
			return 1;
		}
		else if(dist == 1){
			check[cur] = 1;
			return pb_routing(dst, dst, fault);
		}
		else{
			double[][] str_prob = getPRB();
			LinkedList<Integer> prfnode = getPrfNode(cur, dst);
			while(prfnode.peek() != null){
				int str = prfnode.poll();
				if(fault[str] != 1){
					if(pmin > str_prob[str][dist-1]){
						pmin = str_prob[str][dist-1];
						n0 = str;
					}
				}
			}
			if(pmin < 1.0){
				if(check[n0] == 1){
					cnt = -1;
					Arrays.fill(check, 0);
					return 0;
				}
				check[n0] = 1;
				return pb_routing(n0, dst, fault);
			}
			pmin = 1.0;
			LinkedList<Integer> sprnode = getSprNode(cur, dst);
			while(sprnode.peek() != null){
				int str = sprnode.poll();
				if(fault[str] != 1){
					if(pmin > str_prob[str][dist+1]){
						pmin = str_prob[str][dist+1];
						n1 = str;
					}
				}
			}
			if(pmin < 1.0){
				if(check[n1] == 1){
					cnt = -1;
					Arrays.fill(check, 0);
					return 0;
				}
				check[n1] = 1;
				return pb_routing(n1, dst, fault);
			}
		}
		cnt = -1;
		Arrays.fill(check, 0);
		return 0;
	}

	public int dk0(int cur, int dst, int[] fault){//Fault-tolerant routing based on approximate routable probabilities
		double pmax = 0.0;
		cnt++;
		dist = getDistance(cur, dst);
		if(dist == 0){
			pathlen_apr0 = cnt;
			cnt = -1;
			Arrays.fill(check, 0);
			return 1;
		}
		else if(dist == 1){
			check[cur] = 1;
			return dk0(dst, dst, fault);
		}
		else{
			double[][] str_prob = getARP();
			LinkedList<Integer> prfnode = getPrfNode(cur, dst);
			while(prfnode.peek() != null){
				int str = prfnode.poll();
				if(fault[str] != 1){
					if(pmax < str_prob[str][dist-1]){
						pmax = str_prob[str][dist-1];
						n0 = str;
					}
				}
			}
			if(pmax > 0.0){
				if(check[n0] == 1){
					cnt = -1;
					Arrays.fill(check, 0);
					return 0;
				}
				check[n0] = 1;
				return dk0(n0, dst, fault);
			}
			pmax = 0.0;
			LinkedList<Integer> sprnode = getSprNode(cur, dst);
			while(sprnode.peek() != null){
				int str = sprnode.poll();
				if(fault[str] != 1){
					if(pmax < str_prob[str][dist+1]){
						pmax = str_prob[str][dist+1];
						n1 = str;
					}
				}
			}
			if(pmax > 0.0){
				if(check[n1] == 1){
					cnt = -1;
					Arrays.fill(check, 0);
					return 0;
				}
				check[n1] = 1;
				return dk0(n1, dst, fault);
			}
		}
		cnt = -1;
		Arrays.fill(check, 0);
		return 0;
	}

	public int dk1(int pre, int cur, int dst, int[] fault){//Improvement of DK0 considering by previous node
		double pmax = 0.0;
		cnt++;
		dist = getDistance(cur, dst);
		if(dist == 0){
			pathlen_apr1 = cnt;
			cnt = -1;
			Arrays.fill(check, 0);
			return 1;
		}
		else if(dist == 1){
			check[cur] = 1;
			return dk1(cur, dst, dst, fault);
		}
		else{
			double[][] str_prob = getARP();
			LinkedList<Integer> prfnode = getPrfNode(cur, dst);
			while(prfnode.peek() != null){
				int str = prfnode.poll();
				if(fault[str] != 1){
					if(pmax < str_prob[str][dist-1]){
						pmax = str_prob[str][dist-1];
						n0 = str;
					}
				}
			}
			if(pmax > 0.0){
				if(check[n0] == 1){
					cnt = -1;
					Arrays.fill(check, 0);
					return 0;
				}
				check[n0] = 1;
				return dk1(cur, n0, dst, fault);
			}
			pmax = 0.0;
			LinkedList<Integer> sprnode = getSprNode(cur, dst);
			while(sprnode.peek() != null){
				int str = sprnode.poll();
				if(fault[str] != 1 && str != pre){
					if(pmax < str_prob[str][dist+1]){
						pmax = str_prob[str][dist+1];
						n1 = str;
					}
				}
			}
			if(pmax > 0.0){
				if(check[n1] == 1){
					cnt = -1;
					Arrays.fill(check, 0);
					return 0;
				}
				check[n1] = 1;
				return dk1(cur, n1, dst, fault);
			}
		}
		cnt = -1;
		Arrays.fill(check, 0);
		return 0;
	}

}
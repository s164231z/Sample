import java.util.ArrayList;
import java.util.Collections;
import java.util.LinkedList;

class Hypercube{

	/*
	 * Hypercubeを構成するクラス
	 */

	private int dim, size, srcnode, dstnode;
	private double ratio;
	private int[][] neighbors;
	private int[] fault;
	private int[][] rc;
	private int[][] drc;
	private double[][] prob, apr;
	Hypercube(int dim, double ratio){
		this.dim = dim;
		this.size = (int)Math.pow(2, dim);
		this.ratio = ratio;
	}
	public int getDim(){
		return dim;
	}
	public int getSize(){
		return size;
	}
	public int[][] getNeighbors(){
		return neighbors;
	}
	public double getRatio(){
		return ratio;
	}
	public int[] getFault(){
		return fault;
	}
	public int getSrcNode(){
		return srcnode;
	}
	public int getDstNode(){
		return dstnode;
	}
	public int[][] getRC(){
		return rc;
	}
	public int[][] getDRC(){
		return drc;
	}
	public double[][] getPRB(){
		return prob;
	}
	public double[][] getARP(){
		return apr;
	}

	public int combination(int n, int r){
		if(n == r)
			return 1;
		else if(r == 0)
			return 1;
		else if(r == 1)
			return n;
		else
			return(combination(n-1, r-1) + combination(n-1, r));
	}

	public int getDistance(int a, int b){
		ScanHQ val = new ScanHQ(a^b);
		return val.scan();
	}

	public LinkedList<Integer> getPrfNode(int s, int d){
		LinkedList<Integer> prf = new LinkedList<Integer>();
		for(int i=0; i<dim; i++){
			if(getDistance(neighbors[s][i], d) < getDistance(s, d)){
				prf.offer(neighbors[s][i]);
			}
		}
		return prf;
	}
	public LinkedList<Integer> getSprNode(int s, int d){
		LinkedList<Integer> spr = new LinkedList<Integer>();
		for(int i=0; i<dim; i++){
			if(getDistance(neighbors[s][i], d) > getDistance(s, d)){
				spr.offer(neighbors[s][i]);
			}
		}
		return spr;
	}

	public void setSrcDst(){
		int src=0, dst=0, str, flag=0;
		while(flag != 2){
			str = (int)(Math.random()*size);
			if(fault[str]==0){
				src = str;
				flag++;
			}
			else
				flag = 0;
			str = (int)(Math.random()*size);
			if(fault[str] !=1 && str != src){
				dst = str;
				flag++;
			}
			else
				flag = 0;
		}
		srcnode = src;
		dstnode = dst;
	}

	public void setNeighbors(){
		neighbors = new int[size][dim];
		for(int address=0; address<size; address++){
			for(int i=0; i<dim; i++){
				neighbors[address][i] = address ^ (int)Math.pow(2, i) ;
			}
		}
	}

	public void setFault(){
		int i, str;
		fault = new int[size];
		for(i=0; i < (int)Math.floor(size * ratio); i++){
			str = (int)(Math.random()*size);
			if(fault[str] == 1)
				i--;
			else
				fault[str] = 1;
		}
	}

	public void setRC(int size, int dim, int[][] neighbors, int[] fault){//calculate the Routing Capability
		int dist, node, neighbor, str, cnt;
		rc = new int[size][dim+1];
		for(dist=1; dist<=dim; dist++){
			for(node=0; node<size; node++){
				if(dist == 1)
					rc[node][dist] = fault[node] == 1 ? 0 : 1;
				else{
					cnt = 0;
					for(neighbor=0; neighbor<dim; neighbor++){
						str = neighbors[node][neighbor];
						if(rc[str][dist-1] == 1)
							cnt++;
					}
					rc[node][dist] = cnt > (dim - dist) && fault[node] == 0 ? 1 : 0;
				}
			}
		}
	}

	public void setDRC(int size, int dim, int[][] neighbors, int[] fault){//calculate the Directed Routing Capability
		int node, neighbor, str0, cnt, dst;
		drc = getRC();
		dst = getDstNode();
		for(node=0; node<size; node++){
			if(getDistance(node, dst) >= 3){
				LinkedList<Integer> prfnode = getPrfNode(node, dst);
				while(prfnode.peek() != null){
					int str = prfnode.poll();
					drc[node][getDistance(node, dst)] = drc[str][getDistance(node, dst)-1] == 1 ? 1 : 0;
				}
				if(drc[node][getDistance(node, dst)] == 0){
					cnt = 0;
					for(neighbor=0; neighbor<dim; neighbor++){
						str0 = neighbors[node][neighbor];
						if(drc[str0][getDistance(node, dst)] ==1)
							cnt++;
					}
					if(cnt == dim - getDistance(node, dst) -1)
						drc[node][getDistance(node, dst)] = drc[node][getDistance(node, dst)-2] == 1 ? 1 : 0;
				}
			}
		}
	}

	public void setPRB(int size, int dim, int[][] neighbors, int[] fault){//calculate the probability that is not minimally reachable
		int dist, node, neighbor, str, cnt;
		prob = new double[size][dim+1];
		double[][] prob_r = new double[size][dim+1];
		for(dist=1; dist<=dim; dist++){
			for(node=0; node<size; node++){
				if(dist == 1){
					cnt = 0;
					for(neighbor=0; neighbor<dim; neighbor++){
						str = neighbors[node][neighbor];
						if(fault[str] == 1)
							cnt++;
					}
					prob[node][dist] = fault[node] == 1 ? 0.0 : cnt / (double)dim;
				}
				else{
					if(fault[node] == 1)
						prob[node][dist] = 0.0;
					prob[node][dist] = 1.0;
					for(neighbor=0; neighbor<dim; neighbor++){
						str = neighbors[node][neighbor];
						prob_r[str][dist] = fault[str] == 1 ? 0.0 : dist / (double)dim * (1.0 - prob[str][dist-1]);
						prob[node][dist] *= (1 - prob_r[str][dist]);
					}
				}
			}
		}
	}

	public void setARP(int size, int dim, int[][] neighbors, int[] fault){//calculate the Approximate Routable Probability
		int dist, node, neighbor, str;
		double tmp;
		ArrayList<Double> collection = new ArrayList<Double>();
		apr = new double[size][dim+1];
		for(dist=0; dist<=dim; dist++){
			for(node=0; node<size; node++){
				if(dist == 0){
					if(fault[node] != 1)
						apr[node][dist] = 1;
				}
				else{
					tmp = 0.0;
					if(fault[node] == 1)
						apr[node][dist] = 0;
					for(neighbor=0; neighbor<dim; neighbor++){
						str = neighbors[node][neighbor];
						collection.add(Double.valueOf(apr[str][dist-1]));
					}
					Collections.sort(collection);
					for(int k=dist; k<=dim; k++){
						tmp += combination(k-1, dist-1) * collection.get(k-1);
					}
					apr[node][dist] = tmp / combination(getDim(), dist);
				}
				collection.clear();
			}
		}
	}

}
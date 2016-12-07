module DistanceFirstSearch

	def getNextNodeDFS(cur, dst)
		distance, neighbors, prfnodes, sprnodes = getStateDFS(cur, dst)
		p "distance : #{distance}"
		p "neighbors : #{neighbors}"
		p "prfnodes : #{prfnodes}"
		p "sprnodes : #{sprnodes}"
		# 前方/後方隣接節点がどちらも存在しない場合，経路選択失敗
		return -1 if neighbors.empty?
		
		# 現在の節点が目的節点と隣接していたら経路選択成功
		return dst if distance == 1 && @fault[dst] != 1
		
		# 前方隣接節点が存在する場合，前方隣接節点へ
		return prfnodes.sample if !prfnodes.empty?
			
		# 前方隣接節点が存在しない場合，後方隣接節点へ	
		return sprnodes.sample if !sprnodes.empty?
	end			

	def getStateDFS(cur, dst)
		distance = self.getDistance(cur, dst)
		neighbors = @neighbors[cur].reject{|n| @fault[n] == 1}
		prfnodes = self.getPrfNodes(cur, dst).reject{|n| @fault[n] == 1}
		sprnodes = neighbors.reject{|n| prfnodes.include?(n) || @fault[n] ==1}
		[distance, neighbors, prfnodes, sprnodes]
	end

end
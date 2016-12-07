module ApproximateRoutableProbability
	
	# 概算到達確率を算出
	def setARP
		@arp = Hash.new {|hash,key| hash[key] = Hash.new{}}
		tmp_array = Array.new()
	
		(0..@diameter).each do |distance|
			@nodes.each do |node|
				if @fault[node] == 1
					@arp[node][distance] = 0.0
					next
				end
				
				if distance == 0
					if @fault[node] != 1
						@arp[node][distance] = 1.0
					end
				else
					tmp_prob = 0.0
					self.getNeighbors(node).each do |neighbor|
						tmp_array.push @arp[neighbor][distance-1]
					end
					tmp_array.sort!
					if distance % 2 == 0
						h = distance / 2
					else
						h = distance / 2 + 1
					end
					(h..@dim).each do |k|
						tmp_prob += self.hsCombination(k-1, h-1).to_f * tmp_array.at(k-1)
					end
					@arp[node][distance] = tmp_prob / self.hsCombination(@dim, h).to_f
				end
				tmp_array.clear
			end
		end
	end
	
	# 概算到達確率に基づく経路選択
	def getNextNodeARP(cur, dst)
		distance, neighbors, prfnodes, sprnodes = getStateARP(cur, dst)
		
		# 前方/後方隣接節点がどちらも存在しない場合，経路選択失敗
		return -1 if neighbors.empty?
		
		# 現在の節点が目的節点と隣接していたら経路選択成功
		return dst if distance == 1 && @fault[dst] != 1
			
		# 前方隣接節点が存在する場合，前方隣接節点へ
		if !prfnodes.empty?
			next_node = getShortestPathNodeARP(prfnodes, distance)
			
		# 前方隣接節点が存在しない場合，後方隣接節点へ
		else
			next_node = getDetourNodeARP(sprnodes, distance)
		end
		return fault[next_node] == 1 ? -1 : next_node
	end
	
	def getShortestPathNodeARP(prfnodes, distance)
		getHighestProbARP(prfnodes, distance-1)
	end
	
	def getDetourNodeARP(sprnodes, distance)
		getHighestProbARP(sprnodes, distance+1)
	end
	
	def getHighestProbARP(nodes, distance)
		max = 0.0
		key = -1
		nodes.map do |node|
			prob = @arp[node][distance]
			
			if max < prob
				max = prob
				key = node
			end
		end
		key
	end

	def getStateARP(cur, dst)
		distance = self.getDistance(cur, dst)
		neighbors = self.getNeighbors(cur).reject{|n| @fault[n] == 1}
		prfnodes = self.getPrfNodes(cur, dst).reject{|n| @fault[n] == 1}
		sprnodes = neighbors.reject{|n| prfnodes.include?(n) || @fault[n] == 1}
		[distance, neighbors, prfnodes, sprnodes]
	end

end
module ApproximateRoutableProbability
	
	# 概算到達確率を算出
	def setARP
		@arp = Array.new(@size) { Array.new(dim+1) }
		tmp_array = Array.new()
	
		(0..@dim).each do |distance|
			@size.times do |node|
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
					@neighbors[node].each do |neighbor|
						tmp_array.push @arp[neighbor][distance-1].to_f
					end
					tmp_array.sort!
					for k in distance..@dim
						tmp_prob += mycombinationARP(k-1, distance-1).to_f * tmp_array.at(k-1)
					end
					@arp[node][distance] = tmp_prob / mycombinationARP(@dim, distance).to_f
				end
				tmp_array.clear
			end
		end
	end
	
	def mycombinationARP(n, r)
		return 1 if n == r || r == 0
		return n if r == 1
		return mycombinationARP(n-1, r-1) + mycombinationARP(n-1, r)
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
		neighbors = @neighbors[cur].reject{|n| fault[n] == 1}
		prfnodes = self.getPrfNodes(cur, dst).reject{|n| fault[n] == 1}
		sprnodes = neighbors.reject{|n| prfnodes.include?(n) || fault[n] == 1}
		[distance, neighbors, prfnodes, sprnodes]
	end

end
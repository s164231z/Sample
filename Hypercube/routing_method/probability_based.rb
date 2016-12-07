module ProbabilityBased

	# def setProb
	#	@probability = Array.new(@size) { Array.new(dim+1) }
	
	#	(1..@dim).each do |distance|
	#		@size.times do |node|
	#			if distance == 1
	#				cnt = 0
	#				neighbors[node].each do |neighbor|
	#					cnt += 1 if fault[neighbor] == 1
	#				end
	#				@probability[node][distance] = cnt / @dim.to_f
	#			else
	#				if fault[node] == 1
	#					@probability[node][distance] = 0.0
	#				else
	#					neighbors[node].each do |neighbor|
	#					tmp_prob = distance / @dim.to_f * (1.0 - @probability[neighbor][distance-1])
	#					@probability[node][distance] *= (1.0 - tmp_prob)
	#				end
	#			end
	#		end
	#	end
	# end
	
	# 到達確率を算出
	def setProb
		@probability = Array.new(@size) { Array.new(dim+1) }
	
		(1..@dim).each do |distance|
			@size.times do |node|
				if @fault[node] == 1
					@probability[node][distance] = 0.0
					next
				end
			
				if distance == 1
					cnt = 0
					@neighbors[node].each do |neighbor|
						cnt += 1 if @fault[neighbor] == 1
					end
					@probability[node][distance] = (@dim - cnt) / @dim.to_f
				else
					tmp_prob = 1
					@neighbors[node].each do |neighbor|
						next if fault[neighbor] == 1
						tmp_prob *= 1 - @probability[neighbor][distance-1]
					end
					@probability[node][distance] = 1 - tmp_prob
				end
			end
		end
	end
	
	# 到達確率に基づく経路選択
	def getNextNodePB(cur, dst)
		distance, neighbors, prfnodes, sprnodes = getStatePB(cur, dst)
		p "current node : #{cur}"
		p "distance : #{distance}"
		p "neighbors : #{neighbors}"
		p "prfnodes : #{prfnodes}"
		p "sprnodes : #{sprnodes}"
		
		# 前方/後方隣接節点がどちらも存在しない場合，経路選択失敗
		return -1 if neighbors.empty?
		
		# 現在の節点が目的節点と隣接していたら経路選択成功
		return dst if distance == 1 && @fault[dst] != 1
			
		# 前方隣接節点が存在する場合，前方隣接節点へ
		if !prfnodes.empty?
			next_node = getShortestPathNodePB(prfnodes, distance)
			
		# 前方隣接節点が存在しない場合，後方隣接節点へ
		else
			next_node = getDetourNodePB(sprnodes, distance)
		end
		return fault[next_node] == 1 ? -1 : next_node
	end
	
	def getShortestPathNodePB(prfnodes, distance)
		getHighestProbPB(prfnodes, distance-1)
	end
	
	def getDetourNodePB(sprnodes, distance)
		getHighestProbPB(sprnodes, distance+1)
	end
	
	def getHighestProbPB(nodes, distance)
		max = 0.0
		key = -1
		nodes.map do |node|
			prob = @probability[node][distance]
			
			if max < prob
				max = prob
				key = node
			end
		end
		key
	end

	def getStatePB(cur, dst)
		distance = self.getDistance(cur, dst)
		neighbors = @neighbors[cur].reject{|n| fault[n] == 1}
		prfnodes = self.getPrfNodes(cur, dst).reject{|n| fault[n] == 1}
		sprnodes = neighbors.reject{|n| prfnodes.include?(n) || fault[n] == 1}
		[distance, neighbors, prfnodes, sprnodes]
	end

end
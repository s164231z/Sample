module ApproximateDirectedRoutableProbability
	
	# 概算有向到達確率を算出
	def setADRP
		@adrp = Hash.new {|hash,key| hash[key] = Hash.new(&h.default_proc)}
		tmp_hash = Hash.new{}
	
		(0..@diameter).each do |distance|
			@nodes.each do |node|
				if @fault[node] == 1
					@adrp[node][distance] = 0.0
					next
				end
				
				if distance == 0
					if @fault[node] != 1
						self.getNeighbors(node).each do |neighbor|
							j = Math.log2((node ^ neighbor) ^ 2**(@addlen - 1))
							@adrp[node][distance][j] = 1.0
						end
					end
				else
					tmp_prob = 0.0
					self.getNeighbors(node).each do |neighbor|
						j = Math.log2((node ^ neighbor) ^ 2**(@addlen - 1))
						tmp_hash[j] = @adrp[neighbor][distance-1][j]
					end
					tmp_hash.sort!{|(key1, value1),(key2, value2)| value1 <=> value2}
					if distance % 2 == 0
						h = distance / 2
					else
						h = distance / 2 + 1
					end
					(h..@dim).each do |k|
						tmp_prob += self.hsCombination(k-1, h-1).to_f * tmp_array.at(k-1)
					end
					@adrp[node][distance] = tmp_prob / self.hsCombination(@dim, h).to_f
				end
				tmp_array.clear
			end
		end
	end

	# 概算到達確率に基づく経路選択
	def getNextNodeADRP(cur, dst)
		distance, neighbors, prfnodes, sprnodes = getStateADRP(cur, dst)
		puts "distance : #{distance}"
		
		# 前方/後方隣接節点がどちらも存在しない場合，経路選択失敗
		return -1 if neighbors.empty?
		
		# 現在の節点が目的節点と隣接していたら経路選択成功
		return dst if distance == 1 && @fault[dst] != 1
			
		# 前方隣接節点が存在する場合，前方隣接節点へ
		if !prfnodes.empty?
			puts "prf"
			next_node = getShortestPathNodeADRP(prfnodes, distance)
			
		# 前方隣接節点が存在しない場合，後方隣接節点へ
		else
			next_node = getDetourNodeADRP(sprnodes, distance)
		end
		return fault[next_node] == 1 ? -1 : next_node
	end
	
	def getShortestPathNodeADRP(prfnodes, distance)
		getHighestProbADRP(prfnodes, distance-1)
	end
	
	def getDetourNodeADRP(sprnodes, distance)
		getHighestProbADRP(sprnodes, distance+1)
	end
	
	def getHighestProbADRP(nodes, distance)
		max = 0.0
		key = -1
		p nodes
		nodes.map do |node|
			prob = @arp[node][distance]
			
			if max < prob
				max = prob
				key = node
			end
		end
		key
	end

	def getStateADRP(cur, dst)
		distance = self.getDistance(cur, dst)
		neighbors = self.getNeighbors(cur).reject{|n| self.fault[n] == 1}
		prfnodes = self.getPrfNodes(cur, dst).reject{|n| self.fault[n] == 1}
		sprnodes = neighbors.reject{|n| prfnodes.include?(n) || self.fault[n] == 1}
		[distance, neighbors, prfnodes, sprnodes]
	end

end
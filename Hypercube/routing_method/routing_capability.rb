module RoutingCapability

	# 経路選択能力を算出
	def setRC
		@capability = Array.new(@size) { Array.new(dim+1) }

		(1..@dim).each do |round|
			@size.times do |node|
				if round == 1
					@capability[node][round] = fault[node] == 1 ? 0 : 1
				else
					cnt = 0
					@neighbors[node].each do |neighbor|
						cnt += 1 if @capability[neighbor][round-1] == 1
					end
					@capability[node][round] = cnt > (dim-round) && fault[node] == 0 ? 1 : 0
				end
			end
		end
	end

	# 経路選択能力に基づく経路選択
	def getNextNodeRC(cur, dst)
		distance, neighbors, prfnodes, sprnodes, cpbprfs, cpbsprs = getStates(cur, dst)
		p "current node : #{cur}"
		p "distance : #{distance}"
		p "neighbors : #{neighbors}"
		p "prfnodes : #{prfnodes}"
		p "sprnodes : #{sprnodes}"
		p "cpbprfs : #{cpbprfs}"
		p "cpbsprs : #{cpbsprs}"
		
		# 前方/後方隣接節点がどちらも存在しない場合，経路選択失敗
		return -1 if neighbors.empty?
		
		# 現在の節点が目的節点と隣接していたら経路選択成功
		return dst if distance == 1 && @fault[dst] != 1
			
		# 前方隣接節点中に，距離-1の経路選択能力がある場合	
		return cpbprfs.sample if !cpbprfs.empty?
			
		# 後方隣接節点中に，距離+2の経路選択能力がある場合	
		return cpbsprs.sample if !cpbsprs.empty?
			
		# 前方隣接節点が存在する場合，前方隣接節点へ	
		return prfnodes.sample if !prfnodes.empty?
			
		# 前方隣接節点が存在しない場合，後方隣接節点へ	
		return sprnodes.sample if !sprnodes.empty?
	end

	def getStateRC(cur, dst)
		distance = self.getDistance(cur, dst)
		neighbors = @neighbors[cur].reject{|n| fault[n] == 1}
		prfnodes = self.getPrfNodes(cur, dst).reject{|n| fault[n] == 1}
		sprnodes = neighbors.reject{|n| prfnodes.include?(n) || fault[n] == 1}
		cpbprfs = prfnodes.select{|n| @capability[n][distance-1] == 1}
		cpbsprs = sprnodes.select{|n| @capability[n][distance+2] == 1}
		[distance, neighbors, prfnodes, sprnodes, cpbprfs, cpbsprs]
	end

end

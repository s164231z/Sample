module ProbabilityVectors

	# Unsafety setsを見つける
	def setUS
		@unsafety = Array.new(@size) { Array.new(@dim+1) { Array.new() } }
		check = Array.new(@size) { Array.new()}
		tmp_array = Array.new()
		tmp_array2 = Array.new()
		tmp_array3 = Array.new()
		tmp_array4 = Array.new()
		tmp_array5 = Array.new()
		
		
		(1..@dim).each do |distance|
			@size.times do |node|
				next if @fault[node] == 1
				
				if distance == 1
					@neighbors[node].each do |neighbor|
						if fault[neighbor] == 1
							check[node].push neighbor
						end
					end
				else
					@neighbors[node].each do |neighbor|
						next if fault[neighbor] == 1
						tmp_array.push check[node] & check[neighbor]
						tmp_array.flatten!
						tmp_array2.push check[neighbor] - tmp_array
						tmp_array2.flatten!
						if !tmp_array2.empty?
							check[node].push tmp_array2
							check[node].flatten!
						end
						#while !tmp_array2.empty?
						#	tmp = tmp_array2.shift
						#	check[node].push tmp	
						#end
						tmp_array.clear
						tmp_array2.clear
					end
				end
			end
		end
		#p @fault
		#p "-*-*-*-"
		#p check
		#p "-*-*-*-"
		
		@size.times do |node|
			(1..@dim).each do |distance|
				tmp_array4 = self.getNodesByDistance(node, distance)
				tmp_array5 = tmp_array4 & check[node]
				while !tmp_array5.empty?
					tmp = tmp_array5.shift
					@unsafety[node][distance].push tmp
				end
			end
		end
		
		#p @unsafety
	end
	
	# 確率ベクトル(Probability Vectors)を算出
	def setPV
		@pv = Array.new(@size) { Array.new(@dim+1) }
		prob = Array.new(@size) { Array.new(@dim+1) { Array.new() } }
	
		(1..@dim).each do |distance|
			@size.times do |node|
				if @fault[node] == 1
					@pv[node][distance] = 0.0
					next
				end
			
				if distance == 1
					@pv[node][distance] = @unsafety[node][distance].size / @dim.to_f
					
				else
					prob[node][distance].push 0
					(1..distance).each do |j|
						tmp = 0.0
						tmp_array = Array.new()
						tmp_array.push (distance - j + 1)
						tmp_array.push @unsafety[node][j].size
						tmp_array.min.times do |a|
							prob_ja = mycombinationPV(distance - j + 1, a) * ((@unsafety[node][j].size / mycombinationPV(@dim , j).to_f)**a) * ((1-(@unsafety[node][j].size / mycombinationPV(@dim , j).to_f))**(distance - j + 1 -a))
							tmp += (a / (distance - j + 1).to_f) * prob_ja
						end
						#p "~~tmp~~"
						#p "#{tmp}\n"
						prob[node][distance].push tmp
					end
					@pv[node][distance] = 0
					#p "-+-+-+-"
					#p "prob"
					#p "#{prob}\n"
					(1..distance).each do |i|
						flt = 1.0
						if i == 1
							flt = prob[node][distance][i]
						else
							(1...i).each do |k|
								flt *= 1.0 - prob[node][distance][k]
							end
						end
						#p "flt"
						#p "#{flt}\n"
						#p "~~~~~~~"
						#p prob[node][distance][i]
						tmp = flt * prob[node][distance][i]
						@pv[node][distance] += tmp
						#p "-*-*-*-"
					end
				end
			end
		end	
		#p @pv
	end
	
	def mycombinationPV(n, r)
		return 1 if n == r || r == 0
		return n if r == 1
		return mycombinationPV(n-1, r-1) + mycombinationPV(n-1, r)
	end
	
	# 到達確率に基づく経路選択
	def getNextNodePV(cur, dst)
		distance, neighbors, prfnodes, sprnodes = getStatePV(cur, dst)
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
			next_node = getShortestPathNodePV(prfnodes, distance)
			
		# 前方隣接節点が存在しない場合，後方隣接節点へ
		else
			next_node = getDetourNodePV(sprnodes, distance)
		end
		return fault[next_node] == 1 ? -1 : next_node
	end
	
	def getShortestPathNodePV(prfnodes, distance)
		getLowestProbPV(prfnodes, distance-1)
	end
	
	def getDetourNodePV(sprnodes, distance)
		getLowestProbPV(sprnodes, distance+1)
	end
	
	def getLowestProbPV(nodes, distance)
		min = 1.0
		key = -1
		nodes.map do |node|
			prob = @pv[node][distance]
			
			if min > prob
				min = prob
				key = node
			end
		end
		key
	end

	def getStatePV(cur, dst)
		distance = self.getDistance(cur, dst)
		neighbors = @neighbors[cur].reject{|n| fault[n] == 1}
		prfnodes = self.getPrfNodes(cur, dst).reject{|n| fault[n] == 1}
		sprnodes = neighbors.reject{|n| prfnodes.include?(n) || fault[n] == 1}
		[distance, neighbors, prfnodes, sprnodes]
	end

end
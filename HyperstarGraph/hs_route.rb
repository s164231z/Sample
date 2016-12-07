require './hyperstargraph'
require 'yaml'

class Route
	def simulation(dim, ratio, round=100)
		res = []
		@hs = HyperStarGraph.new(dim, ratio)
		
		cnt_dfs = 0
		cnt_arp = 0
		cnt_adrp = 0
		pathlen_dfs = 0
		pathlen_arp = 0
		pathlen_adrp = 0
		round.times do
			@hs.setFault(ratio)
			src, dst = 0, 0
			while !@hs.connect?(src, dst)
				@hs.setFault(ratio)
				i, j = (0...@hs.size).to_a.sample(2)
				src = @hs.nodes[i]
				dst = @hs.nodes[j]
			end
			
			@hs.setARP
			#@hs.setADRP
			
			pathlen = execDFSRouting(src, dst).last
			if pathlen > 0
				cnt_dfs += 1
				pathlen_dfs += pathlen
			end
			
			pathlen = execARPRouting(src, dst).last
			if pathlen > 0
				cnt_arp += 1
				pathlen_arp += pathlen
			end
			
			# pathlen = execADRPRouting(src, dst).last
			# if pathlen > 0
				# cnt_adrp += 1
				# pathlen_adrp += pathlen
			# end
			
		end
		res.push "DFS--> fault=#{ratio}: #{cnt_dfs}/#{round}"
		res.push "ARP--> fault=#{ratio}: #{cnt_arp}/#{round}"
		#res.push "ADRP-> fault=#{ratio}: #{cnt_adrp}/#{round}"
		p res
	end
	
	def execDFSRouting(src, dst)
		cur, next_node, cnt = src, -1, 0
		check = Hash.new {|hash,key| hash[key] = "none"}
		@hs.nodes.each do |node|
			check[node] = 0
		end
		res = [[src, dst]]
		while(true)
			if cur == dst
				res.push true
				res.push cnt
				return res
			end
			
			cnt += 1
			
			next_node = @hs.getNextNodeDFS(cur, dst)
			res.push next_node
			
			if next_node == -1 || check[next_node] == 1
				res.push "error" if check[next_node] == 1
				res.push false
				res.push -1
				return res
			else
				cur = next_node
				check[cur] = 1
			end
		end
	end
		
	def execARPRouting(src, dst)
		cur, next_node, cnt = src, -1, 0
		check = Hash.new {|hash,key| hash[key] = "none"}
		@hs.nodes.each do |node|
			check[node] = 0
		end
		res = [[src, dst]]
		while(true)
			if cur == dst
				res.push true
				res.push cnt
				return res
			end
			
			cnt += 1
			
			next_node = @hs.getNextNodeARP(cur, dst)
			res.push next_node
			
			if next_node == -1 || check[next_node] == 1
				res.push "error" if check[next_node] == 1
				res.push false
				res.push -1
				return res
			else
				cur = next_node
				check[cur] = 1
			end
		end
	end
	
	def execADRPRouting(src, dst)
		cur, next_node, cnt = src, -1, 0
		check = Hash.new {|hash,key| hash[key] = "none"}
		@hs.nodes.each do |node|
			check[node] = 0
		end
		res = [[src, dst]]
		while(true)
			if cur == dst
				res.push true
				res.push cnt
				return res
			end
			
			cnt += 1
			
			next_node = @hs.getNextNodeADRP(cur, dst)
			res.push next_node
			
			if next_node == -1 || check[next_node] == 1
				res.push "error" if check[next_node] == 1
				res.push false
				res.push -1
				return res
			else
				cur = next_node
				check[cur] = 1
			end
		end
	end
	
end
		
route0 = Route.new
route0.simulation(6, 0.1)
# 10.times{|i|
	# route0.simulation(6, i.to_f / 10)
# }
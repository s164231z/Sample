require './hyperstargraph'
require 'yaml'

class Route
	def simulation(dim, ratio, round=10000)
		res = []
		@hs = HyperStarGraph.new(dim, ratio)
		
		cnt = 0
		all = 0
		round.times do
			all += 1
			@hs.setFault(ratio)
			if randomRouting(ratio) == true
				cnt += 1
				puts "Successful Routing!! : #{cnt}"
			end
			puts "--#{all}回終了--"
		end
		res.push "fault=#{ratio}: #{cnt}/#{round}"
		p res
	end
	
	def randomRouting(ratio)
		i, j = (0...@hs.size).to_a.sample(2)
		src = @hs.nodes[i]
		dst = @hs.nodes[j]
		while !@hs.connect?(src, dst)
			@hs.setFault(ratio)
			i, j = (0...@hs.size).to_a.sample(2)
			src = @hs.nodes[i]
			dst = @hs.nodes[j]
		end
		@hs.setARP
		#puts "src : #{src}"
		#puts "dst : #{dst}"
			
		res = exeRouting(src, dst)
		res.last

	end
		
	def exeRouting(src, dst)
		cur, next_node, cnt = src, -1, 0
		check = Hash.new {|hash,key| hash[key] = "none"}
		@hs.nodes.each do |node|
			check[node] = 0
		end
		res = [[src, dst]]
		while(true)
			return res.push true if cur == dst
			cnt += 1
			
			next_node = @hs.getNextNodeARP(cur, dst)
			#next_node = @hq.getNextNodeDFS(cur, dst)
			res.push next_node
			
			if next_node == -1 || check[next_node] == 1
				res.push "error" if check[next_node] == 1
				res.push false
				return res
			#if next_node == -1 || cnt > 100
			#	res.push "loop" if cnt > 100
			#	res.push false
			#	return res
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
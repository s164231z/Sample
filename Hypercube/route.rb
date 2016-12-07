require './hypercube'
require 'yaml'

class Route
	def simulation(dim, ratio=:all, round=10000)
		res = []
		@hq = Hypercube.new(dim, ratio)
		
		cnt = 0
		round.times do
			if randomRouting(ratio) == true
				cnt += 1
				p "Successful Routing!! : #{cnt}"
			else
				puts "miss"
			end
		end
		res.push "fault=#{ratio}: #{cnt}/#{round}"
		p res
	end
	
	def randomRouting(ratio)
		src, dst = (0...@hq.size).to_a.sample(2)
		while !@hq.connect?(src, dst)
			@hq.setFault(ratio)
			src, dst = (0...@hq.size).to_a.sample(2)
		end
		#@hq.setProb
		@hq.setARP
		#@hq.setUS
		#@hq.setPV
		
		res = exeRouting(src, dst)
		res.last

	end
		
	def exeRouting(src, dst)
		cur, next_node, cnt = src, -1, 0
		check = Array.new(@hq.size)
		res = [[src, dst]]
		while(true)
			return res.push true if cur == dst
			cnt += 1
			
			#next_node = @hq.getNextNodePV(cur, dst)
			#next_node = @hq.getNextNodePB(cur, dst)
			next_node = @hq.getNextNodeARP(cur, dst)
			#next_node = @hq.getNextNodeDFS(cur, dst)
			res.push next_node
			
			if next_node == -1 ||check[next_node] == 1
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
route0.simulation(6, 0.3)
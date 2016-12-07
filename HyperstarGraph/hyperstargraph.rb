require './lib/bitcounter'
require './routing_method/breadth_first_search'
require './routing_method/distance_first_search'
require './routing_method/approximate_routable_probability'
require './routing_method/approximate_directed_routable_probability'

class HyperStarGraph
	# HS(2n,n)

	include BreadthFirstSearch
	include DistanceFirstSearch
	include ApproximateRoutableProbability
	include ApproximateDirectedRoutableProbability
	
	attr_reader :dim, :addlen, :size, :nodes, :neighbors, :fault
	
	def initialize(dim, ratio)
		@dim = dim
		@addlen = 2*dim
		@diameter = 2*dim - 1
		@size = hsCombination(2*dim, dim)
		@nodes = setNodes
		@neighbors = setNeighbors
		@ratio = ratio
		@fault = setFault(ratio)
	end
	
	# 故障節点の設定
	def setFault(ratio)
		fault = Hash.new {|hash,key| hash[key] = "none"}
		@nodes.each do |node|
			fault[node] = 0
		end
		(0...@size).to_a.sample((@size * ratio).floor).each{|i| fault[@nodes[i]] = 1}
		fault
	end
	
	def getNeighbors(cur)
		neighbors = Array.new
		@neighbors[cur].each_value{|neighbor|
			neighbors.push neighbor
		}
		neighbors
	end

	# 距離の算出
	def getDistance(a, b)
		distance = Bitcounter::countBit(a ^ b)
		if (a ^ b) > 2**(2*dim-1)
			distance -= 1
		end
		distance
	end

	# 前方節点集合を取得
	def getPrfNodes(c, d)
		getNeighbors(c).select{|n| getDistance(n, d) < getDistance(c, d)}
	end

	# 後方節点集合を取得
	def getSprNodes(c, d)
		getNeighbors(c).select{|n| getDistance(n, d) > getDistance(c, d)}
	end

	# 節点aとbが接続しているか確認
	def connect?(a, b)
		bfs(a, b)
	end
	
	# コンビネーションの計算 nCr
	def hsCombination(n, r)
		return 1 if n == r || r == 0
		return n if r == 1
		return hsCombination(n-1, r-1) + hsCombination(n-1, r)
	end

	private
	# 節点集合を設定(配列に節点を格納)
	def setNodes
		nodes = Array.new
		(0...2**@addlen).each do |node|
			if Bitcounter::countBit(node) == @dim
				nodes.push node
			end
		end
		nodes
	end
	
	# 隣接節点を設定
	def setNeighbors
		neighbors = Hash.new {|hash,key| hash[key] = Hash.new{}}
		@nodes.each do |node|
			i = 0
			(0...@addlen-1).each do |j|
				neighbor = node ^ (2**(@addlen-1) + 2**j)
				if Bitcounter::countBit(neighbor) == @dim && getDistance(node, neighbor) == 1
					neighbors[node][i] = neighbor
					i += 1
				end
			end
		end
		neighbors
	end
	
end
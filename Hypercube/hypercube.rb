require './lib/bitcounter'
require './routing_method/breadth_first_search'
require './routing_method/distance_first_search'
require './routing_method/routing_capability'
require './routing_method/probability_based'
require './routing_method/approximate_routable_probability'
require './routing_method/probability_vectors'

class Hypercube

	include BreadthFirstSearch
	include DistanceFirstSearch
	include RoutingCapability
	include ProbabilityBased
	include ApproximateRoutableProbability
	include ProbabilityVectors

	attr_reader :dim, :size, :neighbors, :fault

	def initialize(dim, ratio)
		@dim = dim
		@size = 2**dim
		@addlen = dim
		@neighbors = setNeighbors
		@ratio = ratio
		@fault = setFault(ratio)
	end

	def setFault(ratio)
		fault = Array.new(@size, 0)
		(0...@size).to_a.sample((@size * ratio).floor).each{|i| fault[i] = 1}
		fault
	end

	def getDistance(a, b)
		Bitcounter::countBit(a ^ b)
	end

	def getPrfNodes(c, d)
		@neighbors[c].select{|n| getDistance(n, d) < getDistance(c, d)}
	end

	def getSprNodes(c, d)
		@neighbors[c].select{|n| getDistance(n, d) > getDistance(c, d)}
	end
	
	def getNodesByDistance(cur, distance)
		Array(0...@size).reject{|node| distance != getDistance(cur, node)}
	end

	def connect?(a, b)
		bfs(a, b)
	end

	private
	def setNeighbors
		neighbors = Array.new
		for address in 0...@size
			for i in 0...@dim
				neighbors[address] ||= Array.new
				neighbors[address].push address^(2**i)
			end
		end
		neighbors
	end
	
end

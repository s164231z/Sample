module BreadthFirstSearch

	def bfs(s, d)
		return false if s <= 0 || d <= 0 || @fault[s] == 1 || @fault[d] == 1

		checked = []
		check = [s]

		while !check.empty?
			c = check.shift
			checked.push c
			self.getNeighbors(c).reject{|n| @fault[n] == 1 || checked.include?(n)}.each do |n|
				check.push n
			end
			
			return true if check.include?(d)
		end
		
		return false
	end

end

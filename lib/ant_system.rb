class AntSystem
  ALPHA = 1
  BETA  = 2
  attr_accessor :trails, :graph, :alpha, :beta
  def initialize(graph)
    @root = graph.shift
    @ends = graph.shift
    @graph = graph
    @trails = initialize_trails
    @constructed_solution = {}
    @alpha = 1
    @beta = 0.9
    @evaporation_rate = 0.1
  end

  def probability(u, v, k = 0, tabu_list = [])
    return 0 if tabu? u, v
    this_path = desirability(u, v)
    all_paths = get_all_paths_from(u, tabu_list)
    suma = all_paths.map{|u, v| desirability(u,v)}.inject(&:+)
    return this_path.to_f / suma
  end

  def trail_level(u, v)
    @trails[[u, v]]
  end

  def tabu?(u, v)
    !@graph.include?([u, v])
  end

  def attractiveness(u, v)
    @graph.include?([u, v]) ? 1 : 0
  end

  def pheromone_update iteration

  end

  # will construct one solution by running an ant and return the ant path.
  def construct_solution
    path = [@root]
    tabu_list = [@root]
    until @ends.include?(last = path.last)
      step = next_step last, tabu_list
      path << step
    end
    path
  end

  # will pick next step with weighted random from position, ignoring tabuized items in tabu_list
  def next_step position, tabu_list
    paths = get_all_paths_from position, tabu_list
    probabilities = paths.map {|path| probability(path.first, path.last, 0, tabu_list)}
    path_probabilities = paths.zip probabilities
    picked_number = rand
	  path_probabilities.each { |pair|
	    path = pair.first
	    prob = pair.last
		  picked_number -= prob
		  return path.last if picked_number <= 0.0
	  }
  end

private
  def get_all_paths_from u, tabu_list = []
    @graph.find_all do |path|
      path.first == u and not tabu_list.include? path.last
    end
  end

  def update_pheromone_for u, v, iteration
    @trails[[u, v]] = evaporation_rate*trails[[u,v]]*(iteration-1) + @constructed_solution[[u,v]]
  end

  def initialize_trails
    @trails = {}
    @graph.each do |u, v|
      @trails[[u, v]] = 0
    end
    @trails
  end

  def modified_trail_level(u, v)
    trail_level(u, v) **  @alpha
  end

  def modified_attractiveness(u, v)
    attractiveness(u, v) ** @beta
  end

  def desirability(u, v)
    modified_trail_level(u, v) + modified_attractiveness(u, v)
  end
end


class AntSystem
  attr_accessor :trails, :graph, :alpha, :beta, :ends, :alpha, :beta, :evaporation_rate, :quality_coefficient
  def initialize(graph)
    @root = graph.shift
    @ends = graph.shift
    @graph = graph
    @trails = initialize_trails
    @constructed_solution = {}
    @alpha = 2 # trail impact
    @beta = 0.9 # heuristics impact
    @evaporation_rate = 0.8
    @quality_coefficient = 1.0
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

  def run!(total_iterations, ants_in_iteration)
    total_iterations.times do |i|
      iteration = construct_iteration(ants_in_iteration)
      pheromone_update(iteration)
    end
    self
  end

  def solution
    sol = [@root]
    current = @root
    until @ends.include? current do
      # find trail with highest pheromone level from current
      max = @trails.max_by {|key, value|
       if key.first == current then
         value
       else
         -1
       end
      }
      current = max.first.last
      sol << current
    end
    sol
  end

  #τιψ (t) = ρ τιψ (t − 1) + ∆τιψ
  #ρ, 0 ≤ ρ ≤ 1, is a user-defined parameter called
  #evaporation coefficient, and ∆τιψ represents the
  #sum of the contributions of all
  #ants that used move (ιψ) to construct their solution.
  def pheromone_update iterations
    sum = sum_iterations(iterations)
    @trails.each do |key, value|
      add = sum[key] || 0.0
      @trails[key] = @evaporation_rate * value + add
    end
  end

  def construct_iteration(n)
    result = []
    n.times do
      result << construct_solution
    end
    result
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

  def sum_iterations(iterations)
    sum = {}
    # vytvorit sumu vsech cest
    iterations.each do |iteration|
      iteration.inject do |first, last|
        sum[[first, last]] ||= 0.0
        sum[[first, last]] += path_quality(iteration)
        last
      end
    end
    sum
  end

  def get_all_paths_from u, tabu_list = []
    @graph.find_all do |path|
      path.first == u and not tabu_list.include? path.last
    end
  end
  # Q / path.length
  def path_quality(path)
    @quality_coefficient / path.length
  end

  def initialize_trails
    @trails = {}
    @graph.each do |u, v|
      @trails[[u, v]] = 0.0
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


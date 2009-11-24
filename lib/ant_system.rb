class AntSystem
  ALPHA = 1
  BETA  = 2
  attr_accessor :trails, :graph, :alpha, :beta
  def initialize(graph)
    @graph = graph
    @trails = initialize_trails
    @alpha = 1
    @beta = 0.9
  end

  def probability(u, v, k)
    return 0 if tabu? u, v
    this_path = desirability(u, v)
    all_paths = get_all_paths_from(u)
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

private
  def get_all_paths_from u
    @graph.find_all do |path|
      path.first == u
    end
  end

  def initialize_trails
    @trails = {}
    @graph.each do |u, v|
      @trails[[u, v]] = 1
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


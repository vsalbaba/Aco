require  File.dirname(__FILE__) + '/spec_helper'

describe AntSystem do

  describe "solution" do
    it 'should return some path for an untraveled graph' do
      ending = 5
      start = 1
      graph = [start, [ending], [1, 2], [2, 3], [3, 4], [4, 5], [2, 4]]
      ant_system = AntSystem.new(graph)
      ant_system.solution.last.should == ending
      ant_system.solution.first.should == start
    end

    it 'should return shortest path for an traveled graph' do
      ending = 4
      start = 1
      graph = [start, [ending], [1, 2], [2, 3], [3, 4], [2, 5], [5, 6], [6, 7], [7, 8], [8, 3]]
      ant_system = AntSystem.new(graph)
      ant_system.run!(20, 5)
      ant_system.solution.should have(4).items
    end

    it 'should return shortest path for medium graph' do
      ending = 11
      start = 1
      graph = [start,
              [ending],
              [1, 3], [1, 4],
              [3, 2], [3, 5], [3, 6], [3, 13],
              [4, 13], [4, 7],
              [2, 5],
              [5, 6], [5, 12],
              [6, 8], [6, 9],
              [13, 7], [13, 6],
              [7, 9],
              [12, 8],
              [9, 8], [9, 10],
              [8, 10], [8, 11],
              [10, 11]]
      ant_system = AntSystem.new(graph)
      ant_system.run!(1, 6)
      solution = ant_system.solution
      puts ant_system.trails.inspect
      puts solution
      solution.should have(5).items
    end
  end


  describe "probability without pheromones" do
    before :each do
      @graph = [1, [5], [1, 2], [2, 3], [3, 4], [4, 5], [2, 4]]
      @ant_system = AntSystem.new(@graph)
    end

    it "should return 0 for tabuized items" do
      @ant_system.probability(1, 3, 1).should eql(0)
    end

    it "should return 1 if there are no other ways" do
      @ant_system.probability(1, 2, 1).should ==(1)
    end

    it "should return 0.5 if there are exactly 2 ways" do
      @ant_system.probability(2, 3, 1).should == 0.5
    end
  end

  describe "probability with pheromones" do
    before :each do
      @graph = [1, [5], [1, 2], [2, 3], [3, 4], [4, 5], [2, 6], [6, 4]]
      @ant_system = AntSystem.new(@graph)
      @ant_system.trails[[2, 6]] += 1
    end

    it "pheromoned trails should have higher probability" do
      unferomoned = @ant_system.probability(2, 3, 1)
      feromoned = @ant_system.probability(2, 6, 1)
      feromoned.should > unferomoned
    end

    it "should have lower probability for unpheromoned" do
      unferomoned = @ant_system.probability(2, 3, 1)
      feromoned = @ant_system.probability(2, 6, 1)
      unferomoned.should < feromoned
    end
  end

  describe 'pheromone_update' do
    before :each do
      @graph = [1, [5], [1, 2], [2, 3], [3, 4], [4, 5], [2, 6], [6, 4]]
      @ant_system = AntSystem.new(@graph)
    end

    describe 'sum_iterations' do
      it 'sum of 2 equal paths should be double of 1 path' do
        iteration = @ant_system.send(:sum_iterations, [[1,2,3,4,5]])
        iteration2 = @ant_system.send(:sum_iterations, [[1,2,3,4,5], [1,2,3,4,5]])
        iteration2.each do |key, value|
          value.should == (2*iteration[key])
        end
      end

      it 'should assign high value on paths which were used more and low value on paths which were used less' do
        iteration = @ant_system.send(:sum_iterations, [[1,2,3,4,5], [1,2,3]])
        iteration[[1,2]].should > iteration[[3,4]]
      end

      it 'should sum all paths which were used in iteration if none paths are intersecting' do
        iteration = @ant_system.send(:sum_iterations, [[1,2], [2,3], [3, 4], [4, 5]])
        iteration.should have_key([1,2])
        iteration.should have_key([2,3])
        iteration.should have_key([3,4])
        iteration.should have_key([4,5])
      end

      it 'should sum all paths which were used in iteration even if paths are intersecting' do
        iteration = @ant_system.send(:sum_iterations, [[1,2,3], [2,3,4], [3, 4, 5], [4, 5]])
        iteration.should have_key([1,2])
        iteration.should have_key([2,3])
        iteration.should have_key([3,4])
        iteration.should have_key([4,5])
      end

      it 'should handle iterations 1,2,3,4,5], [1,2,3]' do
        iteration = @ant_system.send(:sum_iterations, [[1,2,3,4,5], [1,2,3]])
        iteration.should have_key([1,2])
        iteration.should have_key([2,3])
        iteration.should have_key([3,4])
        iteration.should have_key([4,5])
      end
    end

    it 'should change path value if no ant run over it' do
      before = @ant_system.trails[[1,2]]=(1.0)
      @ant_system.pheromone_update([])
      @ant_system.trails[[1,2]].should < before
    end

    it 'should increase the value of path if it was run over by sufficient ants' do
      before = @ant_system.trails[[1,2]]
      @ant_system.pheromone_update([[1, 2, 3, 4, 5], [1,2,3,4,5], [1,2,3,4,5]])
      @ant_system.trails[[1,2]].should > before
    end
  end

  describe "path_quality" do
    before :each do
      @path = Array.new(10)
      @graph = [1, [5], [1, 2], [2, 3], [3, 4], [4, 5], [2, 6], [6, 4]]
      @ant_system = AntSystem.new(@graph)
    end

    it 'should return  1/10 if if path length is 10 and evaporation_rate is 1.0' do
      @ant_system.send(:path_quality, @path).should == 1.0/10
    end
  end

  describe "next_step" do
    before :each do
      @graph = [1, [5], [1, 2], [2, 3], [3, 4], [4, 5], [2, 6], [6, 4]]
      @ant_system = AntSystem.new(@graph)
    end

    it "should from 1 pick 1" do
      @ant_system.next_step(1, []).should == 2
    end

    it "should prefer more desirable items" do
      @ant_system.trails[[2, 6]] += 4
      count = {3 => 0, 6 => 0}
      3000.times do
        count[@ant_system.next_step(2, [])] += 1
      end
      count[6].should > count[3]
    end

    it "should ignore tabuized items" do
      @ant_system.trails[[2, 6]] += 4
      count = {}
      3000.times do
        step = @ant_system.next_step(2, [6])
        count[step] ||= 0
        count[step] += 1
      end
      count[6].should be_nil
      count[3].should == 3000
    end
  end


  describe "run iteration" do
    before :each do
      @graph = [1, [5], [1, 2], [2, 3], [3, 4], [4, 5], [2, 6], [6, 4]]
      @ant_system = AntSystem.new(@graph)
      @ant_system.trails[[2, 6]] += 1
    end

    it 'should depend on construct_solution' do
      @ant_system.should_receive(:construct_solution).exactly(20).times
      @ant_system.construct_iteration(20)
    end
  end

  describe "construct_solution" do
    before :each do
      @graph = [1, [5], [1, 2], [2, 3], [3, 4], [4, 5], [2, 6], [6, 4]]
      @ant_system = AntSystem.new(@graph)
      @ant_system.trails[[2, 6]] += 1
    end

    it 'should find a route 5 nodes long' do
      @ant_system.construct_solution.should have(5).nodes
    end

    it 'should return route through node 6 more times' do
      count = {}
      100.times do
        solution = @ant_system.construct_solution
        if solution.include?(6) then
          count[6] ||= 0
          count[6] += 1
        elsif solution.include?(3) then
          count[3] ||= 0
          count[3] += 1
        end
      end
      count[6].should > count[3]
    end

    it 'should still use the route through node 3 sometimes ' do
      count = {}
      100.times do
        solution = @ant_system.construct_solution
        if solution.include?(3) then
          count[3] ||= 0
          count[3] += 1
        end
      end
      count[3].should_not == 0
      count[3].should_not be_nil
    end
  end
end


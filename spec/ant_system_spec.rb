require  File.dirname(__FILE__) + '/spec_helper'

describe AntSystem do
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

  describe "pheromone update" do
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
      p count
      count[6].should be_nil
      count[3].should == 3000
    end
  end

  describe "construct_solution" do
    before :each do
      @graph = [1, [5], [1, 2], [2, 3], [3, 4], [4, 5], [2, 6], [6, 4]]
      @ant_system = AntSystem.new(@graph)
      @ant_system.trails[[2, 6]] += 1
    end
  end
end


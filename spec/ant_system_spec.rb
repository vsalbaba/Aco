require  File.dirname(__FILE__) + '/spec_helper'

describe AntSystem do
  describe "probability without pheromones" do
    before :each do
      @graph = [[1, 2], [2, 3], [3, 4], [4, 5], [2, 4]]
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
end


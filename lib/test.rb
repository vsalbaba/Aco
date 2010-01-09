require File.dirname(__FILE__) + '/ant_system'
runs = 100
maximum = 50
ending = 11
start = 1
puts "items,avg"
results = {}
maximum.times do |i|
  results[i+1] = 0
  runs.times do
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
    ant_system.run! 1, i+1
    results[i+1] += ant_system.solution.length
  end
  results[i+1] = results[i+1].to_f / runs
  puts "#{i+1},#{results[i+1]}"
end


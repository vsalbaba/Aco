require File.dirname(__FILE__) + '/ant_system'
require 'logger'

@runs = 100
@maximum = 50
@ending = 11
@start = 1
@alphas = [1.0, 1.1, 1.2, 1.3, 1.4, 1.5, 1.6, 1.7, 1.8, 1.9, 2.0, 2.1]
@evaporation_rates = [0.7, 0.8, 0.85, 0.9]
@quality_coeficients = [1.0, 1.1, 1.2, 1.3]
@batches = [10, 11, 12, 13, 14, 15, 16, 17, 18, 19]

@alphas.each do |alpha|
  @evaporation_rates.each do |evaporation_rate|
    @quality_coeficients.each do |quality_coefficient|
      @batches.each do |batch|
        @logger = Logger.new "alpha#{alpha}_evaporation_rate#{evaporation_rate}_quality_coefficients#{quality_coefficient}_batch#{batch}.results"
        @runs.times do
          graph = [@start,
              [@ending],
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
          ant_system.run! 10, batch
          @logger.info ant_system.solution
        end
      end
    end
  end
end


#!/usr/bin/env ruby
# frozen_string_literal: true

require 'optparse'
require_relative 'lib/models/package'
require_relative 'lib/services/delivery_cost_calculator'
require_relative 'lib/services/delivery_time_calculator'

options = {
  capacity: 2
}

OptionParser.new do |opts|
  opts.banner = 'Usage: ruby app.rb [options]'

  opts.on('--packages-file FILE', String, 'Packages input file') { |v| options[:packages_file] = v }
  opts.on('--base-cost COST', Float, 'Base delivery cost')      { |v| options[:base_cost] = v }
  opts.on('--vehicles N', Integer, 'Number of vehicles')        { |v| options[:vehicles] = v }
  opts.on('--speed KMH', Float, 'Vehicle speed')                { |v| options[:vehicle_speed] = v }
  opts.on('--max-load KG', Float, 'Max weight a vehicle can carry') { |v| options[:max_load] = v }
  opts.on('--capacity N', Integer, 'Max # of packages per vehicle (default 2)') { |v| options[:capacity] = v }
end.parse!

lines = File.readlines(options[:packages_file]).map(&:strip).reject(&:empty?)

packages = []

first_line_parts = lines.first.split

if first_line_parts.size == 2 && first_line_parts[0].match?(/^\d+$/)
  # delivery cost calculation
  base_cost = first_line_parts[0].to_f
  count     = first_line_parts[1].to_i

  package_lines = lines[1, count]

  package_lines.each do |ln|
    name, weight, distance, offer = ln.split
    packages << Package.new(name, base_cost, weight.to_f, distance.to_f, offer)
  end

  packages.each do |pkg|
    DeliveryCostCalculator.calculate(pkg)
    puts "#{pkg.name} #{pkg.discount}  #{pkg.total_delivery_cost.to_i}"
  end

  exit
else
  # delivery time calculation
  raise '--base-cost required' unless options[:base_cost]
  raise '--vehicles required' unless options[:vehicles]
  raise '--speed required' unless options[:vehicle_speed]
  raise '--max-load required' unless options[:max_load]

  lines.each do |ln|
    name, weight, distance, offer = ln.split
    packages << Package.new(name, options[:base_cost], weight.to_f, distance.to_f, offer)
  end

  time_calculator = DeliveryTimeCalculator.new(
    packages,
    options[:vehicles],
    options[:vehicle_speed],
    options[:max_load],
    options[:capacity]
  )

  time_calculator.plan_shipments

  packages.each do |pkg|
    puts "#{pkg.name} #{pkg.total_delivery_cost.to_i} #{format('%.2f', pkg.delivery_time)}"
  end
end

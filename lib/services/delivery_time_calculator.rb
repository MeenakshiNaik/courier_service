# frozen_string_literal: true

class DeliveryTimeCalculator
  attr_reader :packages, :vehicles

  def initialize(packages = [], vehicle_count:, vehicle_speed:, max_load:, vehicle_capacity:)
    @packages = packages.dup
    @vehicle_count = vehicle_count
    @vehicle_speed = vehicle_speed.to_f
    @max_load = max_load.to_f
    @vehicle_capacity = vehicle_capacity
    @vehicles = Array.new(vehicle_count, 0.0)
  end

  # Add package dynamically
  def add_package(pkg)
    @packages << pkg
  end

  def plan_shipments
    # Sort packages by weight descending
    sorted_packages = @packages.sort_by(&:weight_in_kg).reverse
    shipments = []

    while sorted_packages.any?
      shipment = build_shipment(sorted_packages)
      next if shipment.packages.empty?

      # Find earliest available vehicle
      vehicle_index = @vehicles.each_with_index.min[1]
      vehicle_available_time = @vehicles[vehicle_index]

      # Delivery time = (vehicle available + max distance / speed)
      max_distance = shipment.packages.map(&:distance_in_km).max.to_f
      shipment.packages.each do |pkg|
        pkg.total_delivery_cost = DeliveryCostCalculator.calculate(pkg)
        pkg.delivery_time = (vehicle_available_time + pkg.distance_in_km / @vehicle_speed).round(2)
      end
      shipment.delivery_time = shipment.packages.map(&:delivery_time).max

      @vehicles[vehicle_index] = (vehicle_available_time + 2 * max_distance / @vehicle_speed).round(2)
      shipments << shipment
    end

    shipments
  end

  private

  # Build a shipment
  def build_shipment(sorted_packages)
    shipment = Shipment.new(@vehicle_capacity)
    current_weight = 0.0

    sorted_packages.dup.each do |pkg|
      break if shipment.packages.size >= @vehicle_capacity
      next if current_weight + pkg.weight_in_kg > @max_load

      shipment.add_package(pkg)
      current_weight += pkg.weight_in_kg
      sorted_packages.delete(pkg)
    end

    shipment
  end
end

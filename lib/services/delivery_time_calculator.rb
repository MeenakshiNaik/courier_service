# frozen_string_literal: true

class DeliveryTimeCalculator
  attr_reader :packages, :vehicles

  def initialize(packages, vehicle_count, vehicle_speed, max_carriable_weight, vehicle_capacity)
    @packages = packages.dup
    @vehicle_count = vehicle_count
    @vehicle_speed = vehicle_speed.to_f
    @max_carriable_weight = max_carriable_weight.to_f
    @vehicle_capacity = vehicle_capacity.to_i
    @vehicles_available_time = Array.new(vehicle_count, 0.0)
  end

  def plan_shipments
    shipment_pachages = @packages.dup
    shipments = []

    until shipment_pachages.empty?
      shipment_pkgs = best_shipment(shipment_pachages)
      raise 'No valid shipment' unless shipment_pkgs

      vehicle_index, start_time = earliest_vehicle

      farthest_distance = shipment_pkgs.map(&:distance_in_km).max.to_f

      shipment_pkgs.each do |pkg|
        DeliveryCostCalculator.calculate(pkg) if defined?(DeliveryCostCalculator)
        pkg.delivery_time = (start_time + pkg.distance_in_km / @vehicle_speed)
      end

      return_time = (start_time + 2 * farthest_distance / @vehicle_speed).round(2)

      is_last_shipment = shipment_pachages.size == shipment_pkgs.size

      # Only update return time if there will be more shipments
      @vehicles_available_time[vehicle_index] = return_time unless is_last_shipment

      shipments << {
        packages: shipment_pkgs,
        vehicle_index: vehicle_index,
        start_time: start_time,
        return_time: is_last_shipment ? nil : return_time
      }

      shipment_pachages -= shipment_pkgs
    end

    shipments
  end

  private

  def best_shipment(packages)
    combos = valid_shipments(packages)
    combos.max_by { |comb| combo_score(comb) }
  end

  def combo_score(comb)
    [
      comb.size,
      comb.sum(&:weight_in_kg),
      -comb.map(&:distance_in_km).max
    ]
  end

  def valid_shipments(list)
    shipments = []

    (1..@vehicle_capacity).each do |count|
      list.combination(count).each do |comb|
        shipments << comb if comb.sum(&:weight_in_kg) <= @max_carriable_weight
      end
    end

    shipments
  end

  def earliest_vehicle
    index = @vehicles_available_time.index(@vehicles_available_time.min)
    [index, @vehicles_available_time[index]]
  end
end

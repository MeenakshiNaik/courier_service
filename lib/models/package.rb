# frozen_string_literal: true

class Package
  attr_accessor :name, :base_delivery_cost, :weight_in_kg, :distance_in_km, :offer_code, :total_delivery_cost,
                :delivery_time, :discount

  def initialize(name, base_delivery_cost, weight_in_kg, distance_in_km, offer_code = nil)
    @name = name
    @base_delivery_cost = base_delivery_cost.to_f
    @weight_in_kg = weight_in_kg.to_f
    @distance_in_km = distance_in_km.to_f
    @offer_code = offer_code
    @total_delivery_cost = 0.0
    @delivery_time = 0.0
    @discount = 0.0
  end
end

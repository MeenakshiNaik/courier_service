# frozen_string_literal: true

class Package
  attr_accessor :name, :base_delivery_cost, :weight_in_kg, :distance_in_km, :offer_code, :total_delivery_cost

  def initialize(name, base_delivery_cost, weight_in_kg, distance_in_km, offer_code = nil)
    @name = name
    @base_delivery_cost = base_delivery_cost
    @weight_in_kg = weight_in_kg
    @distance_in_km = distance_in_km
    @offer_code = offer_code
    @total_delivery_cost = nil
  end
end

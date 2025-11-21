# frozen_string_literal: true

class Shipment
  attr_accessor :packages, :delivery_time

  def initialize(vehicle_capacity)
    @vehicle_capacity = vehicle_capacity
    @packages = []
    @delivery_time = 0.0
  end

  def add_package(pkg)
    return false if @packages.size >= @vehicle_capacity

    @packages << pkg
  end
end

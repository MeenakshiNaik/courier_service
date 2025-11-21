# frozen_string_literal: true

require 'spec_helper'

RSpec.describe DeliveryTimeCalculator do
  let(:base_delivery_cost) { 100 }
  let(:pkg1) { Package.new('PKG1', base_delivery_cost, 50, 30, 'OFR001') }
  let(:pkg2) { Package.new('PKG2', base_delivery_cost, 75, 125, 'OFFR0008') }
  let(:pkg3) { Package.new('PKG3', base_delivery_cost, 175, 100, 'OFFR003') }
  let(:pkg4) { Package.new('PKG4', base_delivery_cost, 110, 60, 'OFFR002') }
  let(:pkg5) { Package.new('PKG5', base_delivery_cost, 155, 95, 'NA') }

  let(:packages) { [pkg1, pkg2, pkg3, pkg4, pkg5] }

  let(:vehicle_params) do
    {
      vehicle_count: 2,
      vehicle_speed: 70,
      max_load: 200,
      vehicle_capacity: 2
    }
  end

  describe "#add_package" do
    it "adds a package dynamically" do
      calculator = DeliveryTimeCalculator.new([pkg1, pkg2], **vehicle_params)
      expect(calculator.packages.size).to eq(2)

      calculator.add_package(pkg3)
      expect(calculator.packages.size).to eq(3)
      expect(calculator.packages).to include(pkg3)
    end
  end

  describe "#plan_shipments" do
    it "creates shipments respecting vehicle capacity and max load" do
      calculator = DeliveryTimeCalculator.new(packages, **vehicle_params)
      shipments = calculator.plan_shipments

      total_packages = shipments.flat_map(&:packages).size
      expect(total_packages).to eq(packages.size)

      shipments.each do |shipment|
        total_weight = shipment.packages.sum(&:weight_in_kg)
        expect(total_weight).to be <= vehicle_params[:max_load]
        expect(shipment.packages.size).to be <= vehicle_params[:vehicle_capacity]
      end
    end

    it "works correctly with dynamic package addition" do
      calculator = DeliveryTimeCalculator.new([pkg1, pkg2], **vehicle_params)
      calculator.add_package(pkg3)
      calculator.add_package(pkg4)
      calculator.add_package(pkg5)

      shipments = calculator.plan_shipments

      all_packages = shipments.flat_map(&:packages)
      expect(all_packages.size).to eq(5)
      expect(all_packages.map(&:name)).to match_array(["PKG1", "PKG2", "PKG3", "PKG4", "PKG5"])
    end
  end
end
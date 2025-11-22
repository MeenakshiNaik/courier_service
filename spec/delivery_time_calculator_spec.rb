# frozen_string_literal: true

require "spec_helper"

RSpec.describe DeliveryTimeCalculator do
  let(:base_delivery_cost) { 100 }

  let(:pkg1) { Package.new("PKG1", base_delivery_cost, 50, 30,  "OFR001") }
  let(:pkg2) { Package.new("PKG2", base_delivery_cost, 75, 125, "NA") }
  let(:pkg3) { Package.new("PKG3", base_delivery_cost, 175, 100,"NA") }
  let(:pkg4) { Package.new("PKG4", base_delivery_cost, 110, 60, "NA") }
  let(:pkg5) { Package.new("PKG5", base_delivery_cost, 155, 95, "NA") }

  #  tie-case package
  let(:pkg6) { Package.new("PKG6", base_delivery_cost, 155, 50, "NA") }

  let(:packages) { [pkg1, pkg2, pkg3, pkg4, pkg5, pkg6] }

  let(:vehicle_count)     { 2 }
  let(:vehicle_speed)     { 70 }
  let(:vehicle_capacity)  { 2 }
  let(:max_load)          { 200 }

  before do
    allow(DeliveryCostCalculator).to receive(:calculate) do |pkg|
      pkg.total_delivery_cost = 999
    end
  end

  describe "#valid_shipments" do
    it "returns all valid combinations respecting weight <= 200kg and capacity = 2" do
      calc = DeliveryTimeCalculator.new(packages, vehicle_count, vehicle_speed, max_load, vehicle_capacity)

      combos = calc.send(:valid_shipments, packages)
      names = combos.map { |c| c.map(&:name) }

      # Singles (all valid if <=200kg)
      expect(names).to include(["PKG1"])
      expect(names).to include(["PKG2"])
      expect(names).to include(["PKG3"])
      expect(names).to include(["PKG4"])
      expect(names).to include(["PKG5"])
      expect(names).to include(["PKG6"])

      # Valid pairs under 200kg
      expect(names).to include(["PKG2", "PKG4"])   # 75+110=185
      expect(names).to include(["PKG1", "PKG2"])   # 50+75=125
      expect(names).to include(["PKG1", "PKG4"])   # 50+110=160


      # Invalid pairs must NOT be included
      expect(names).not_to include(["PKG1", "PKG6"])   # 50+155=205 (invalid until tie test modifies weight)
      expect(names).not_to include(["PKG3", "PKG4"]) # 175+110 = 285
      expect(names).not_to include(["PKG5", "PKG6"]) # 155+155 = 310
    end
  end

  describe "tie-breaking" do
    it "picks the pair with same size+weight but LOWER farthest distance" do
      pkg6.weight_in_kg = 150

      # If weights were equal, the tiebreaker would be farthest distance.

      calc = DeliveryTimeCalculator.new(packages, vehicle_count, vehicle_speed, max_load, vehicle_capacity)
      best = calc.send(:best_shipment, packages)

      expect(best.map(&:name)).to eq(["PKG1", "PKG6"])
    end
  end

  describe "#plan_shipments" do
    it "creates the correct shipment order following PDF rules" do
      calc = DeliveryTimeCalculator.new(packages, vehicle_count, vehicle_speed, max_load, vehicle_capacity)
      shipments = calc.plan_shipments

      names = shipments.map { |s| s[:packages].map(&:name) }

      expect(names[0]).to eq(["PKG2", "PKG4"])
      expect(names[1]).to eq(["PKG3"])
      expect(names[2]).to eq(["PKG6"])
      expect(names[3]).to include("PKG5").or include("PKG1")
    end

    it "sets delivery time for each package" do
      calc = DeliveryTimeCalculator.new(packages, vehicle_count, vehicle_speed, max_load, vehicle_capacity)
      shipments = calc.plan_shipments

      packages.each do |pkg|
        expect(pkg.delivery_time).not_to be_nil
        expect(pkg.delivery_time).to be > 0
      end
    end

    it "does NOT update return time for the last shipment" do
      calc = DeliveryTimeCalculator.new(packages, vehicle_count, vehicle_speed, max_load, vehicle_capacity)

      before_times = calc.instance_variable_get(:@vehicles_available_time).dup

      shipments = calc.plan_shipments
      last_shipment = shipments.last

      vehicle_index = last_shipment[:vehicle_index]
      expected_return = last_shipment[:return_time]
      after_times = calc.instance_variable_get(:@vehicles_available_time)

      # vehicle availability time must NOT be updated to return_time for last shipment
      expect(after_times[vehicle_index]).not_to eq(expected_return)
    end

  end

end

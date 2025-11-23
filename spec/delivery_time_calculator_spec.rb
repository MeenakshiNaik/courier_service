# frozen_string_literal: true

require 'spec_helper'

RSpec.describe DeliveryTimeCalculator do
  let(:base_cost) { 100 }

  let(:pkg1) { Package.new('PKG1', base_cost, 50, 30, 'OFR001') }
  let(:pkg2) { Package.new('PKG2', base_cost, 75, 125, 'OFFR0008') }
  let(:pkg3) { Package.new('PKG3', base_cost, 175, 100, 'OFFR003') }
  let(:pkg4) { Package.new('PKG4', base_cost, 110, 60, 'OFFR002') }
  let(:pkg5) { Package.new('PKG5', base_cost, 155, 95, 'NA') }

  let(:packages) { [pkg1, pkg2, pkg3, pkg4, pkg5] }

  let(:vehicle_count) { 2 }
  let(:vehicle_speed) { 70 }
  let(:max_carriable_weight) { 200 }
  let(:vehicle_capacity) { 2 }

  let(:delivery_time_calculator) do
    DeliveryTimeCalculator.new(
      packages,
      vehicle_count,
      vehicle_speed,
      max_carriable_weight,
      vehicle_capacity
    )
  end

  describe '#valid_shipments' do
    it 'returns only weight-feasible combinations' do
      combos = delivery_time_calculator.send(:valid_shipments, [pkg3, pkg4, pkg5])

      expect(combos).to include([pkg3])
      expect(combos).to include([pkg4])
      expect(combos).to include([pkg5])

      expect(combos).not_to include([pkg3, pkg4])
      expect(combos).not_to include([pkg5, pkg4])
    end

    it 'never returns combos exceeding vehicle capacity' do
      combos = delivery_time_calculator.send(:valid_shipments, packages)
      expect(combos.any? { |c| c.size > 2 }).to eq(false)
    end
  end

  describe '#best_shipment' do
    it 'returns the best feasible shipment based on size, weight, distance' do
      best = delivery_time_calculator.send(:best_shipment, packages)

      expect(best.map(&:name)).to match_array(%w[PKG2 PKG4])
    end

    it 'resolves ties using lowest max-distance' do
      pkg1 = Package.new('PKG1', base_cost, 60, 50)
      pkg2 = Package.new('PKG2', base_cost, 60, 100)
      pkg3 = Package.new('PKG3', base_cost, 120, 20)
      pkg4 = Package.new('PKG4', base_cost, 120, 150)

      calculator = DeliveryTimeCalculator.new([pkg1, pkg2, pkg3, pkg4], 1, 60, 180, 2)

      best_shipment = calculator.send(:best_shipment, [pkg1, pkg2, pkg3, pkg4])
      expect(best_shipment.map(&:name)).to match_array(%w[PKG1 PKG3])
    end
  end

  describe '#assign_delivery_times' do
    it 'assigns correct delivery_time values' do
      delivery_time_calculator.send(:assign_delivery_times, [pkg1], 0.0)
      expect(pkg1.delivery_time).to eq(30.0 / 70.0)
    end
  end

  describe '#calculate_return_time' do
    it 'returns correct round-trip time' do
      return_time = delivery_time_calculator.send(:calculate_return_time, 0.0, 100)
      expect(return_time).to eq((200.0 / 70.0).round(2))
    end
  end

  describe '#earliest_vehicle' do
    it 'returns first available vehicle' do
      delivery_time_calculator.instance_variable_get(:@vehicles_available_time)[0] = 5.0
      delivery_time_calculator.instance_variable_get(:@vehicles_available_time)[1] = 2.0

      idx, time = delivery_time_calculator.send(:earliest_vehicle)
      expect(idx).to eq(1)
      expect(time).to eq(2.0)
    end
  end

  describe '#plan_shipments' do
    it 'delivers all 5 packages across multiple shipments' do
      shipments = delivery_time_calculator.plan_shipments

      delivered = shipments.flat_map { |s| s[:packages].map(&:name) }
      expect(delivered.size).to eq(5)
      expect(delivered).to match_array(%w[PKG1 PKG2 PKG3 PKG4 PKG5])
    end

    it 'assigns delivery_time to every package' do
      delivery_time_calculator.plan_shipments
      packages.each do |pkg|
        expect(pkg.delivery_time).not_to be_nil
      end
    end

    it 'updates return_time except last shipment' do
      shipments = delivery_time_calculator.plan_shipments

      last = shipments.last
      expect(last[:return_time]).to be_nil

      shipments[0..-2].each do |s|
        expect(s[:return_time]).not_to be_nil
      end
    end
  end
end

# frozen_string_literal: true

require 'spec_helper'

RSpec.describe DeliveryCostCalculator do
  context 'calculation of total delivery cost with OFR001' do
    it 'returns a discounted delivery cost for a package eligible for OFR001' do
      pkg = Package.new('PKG1', 100, 80, 190, 'OFR001')
      DeliveryCostCalculator.calculate(pkg)
      expect(pkg.total_delivery_cost).to eq(1665.0)
    end

    it 'returns a delivery cost for a package not eligible for OFR001' do
      pkg = Package.new('PKG1', 100, 5, 5, 'OFR001')
      DeliveryCostCalculator.calculate(pkg)
      expect(pkg.total_delivery_cost).to eq(175.0)
    end
  end

  context 'calculation of total delivery cost with OFR002' do
    it 'returns a discounted delivery cost for a package eligible for OFR002' do
      pkg = Package.new('PKG2', 100, 190, 150, 'OFR002')
      DeliveryCostCalculator.calculate(pkg)
      expect(pkg.total_delivery_cost).to eq(2557.5)
    end

    it 'returns a delivery cost for a package not eligible for OFR002' do
      pkg = Package.new('PKG2', 100, 15, 5, 'OFR002')
      DeliveryCostCalculator.calculate(pkg)
      expect(pkg.total_delivery_cost).to eq(275)
    end
  end

  context 'calculation of total delivery cost with OFR003' do
    it 'returns a discounted delivery cost for a package eligible for OFR003' do
      pkg = Package.new('PKG3', 100, 20, 200, 'OFR003')
      DeliveryCostCalculator.calculate(pkg)
      expect(pkg.total_delivery_cost).to eq(1235.0)
    end

    it 'returns a delivery cost for a package not eligible for OFR003' do
      pkg = Package.new('PKG3', 100, 20, 40, 'OFR003')
      DeliveryCostCalculator.calculate(pkg)
      expect(pkg.total_delivery_cost).to eq(500)
    end
  end
end

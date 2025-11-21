# frozen_string_literal: true

require 'spec_helper'


RSpec.describe Package do

  it 'initializes the package' do
    p = Package.new('PKG1', 100, 10, 50, 'OFR001')
    expect(p.name).to eq('PKG1')
    expect(p.base_delivery_cost).to eq(100)
    expect(p.weight_in_kg).to eq(10)
    expect(p.distance_in_km).to eq(50)
    expect(p.offer_code).to eq('OFR001')
  end
end

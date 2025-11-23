# frozen_string_literal: true

class DeliveryCostCalculator
  def self.calculate(pkg)
    total_delivery_cost = pkg.base_delivery_cost + (pkg.weight_in_kg * 10) + (pkg.distance_in_km * 5)
    discount_rate = discount_rate(pkg)
    discount = total_discount(total_delivery_cost, discount_rate)
    final_cost = (total_delivery_cost - discount).round(2)
    pkg.discount = discount
    pkg.total_delivery_cost = final_cost
  end

  def self.discount_rate(pkg)
    case pkg.offer_code
    when 'OFR001'
      return 0.10 if pkg.distance_in_km < 200 && pkg.weight_in_kg.between?(70, 200)
    when 'OFR002'
      return 0.07 if pkg.distance_in_km.between?(50, 150) && pkg.weight_in_kg.between?(100, 250)
    when 'OFR003'
      return 0.05 if pkg.distance_in_km.between?(50, 250) && pkg.weight_in_kg.between?(10, 150)
    end

    0
  end

  def self.total_discount(total_delivery_cost, discount_rate)
    (total_delivery_cost * discount_rate).round(2)
  end
end

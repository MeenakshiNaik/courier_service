**Ruby CLI Application - Supports delivery cost estimation and delivery time estimation**

This application calculates:

1. Delivery cost of the package
2. Delivery time based on the vehicle availability, capacity, and maximum carriable weight

**Installation:**

Ensure you have Ruby installed:

```
ruby -v
```

Clone or unzip the folder, then run from the project root:
```
bundle install
```

**How to run the application:**

Use:
```
ruby app.rb [OPTIONS]
```

**OPTION 1 - Delivery Cost calculation**

```
Example input file:

delivery_cost_sample.txt
100 3
PKG1 5 5 OFR001
PKG2 15 5 OFR002
PKG3 10 100 OFR003

ruby app.rb --packages-file inputs/delivery_cost_sample.txt
```


**OPTION 2 - Delivery time calculation**

```
Example input file:

delivery_time_sample.txt
PKG1 50 30 OFR001
PKG2 75 125 OFR0008
PKG3 175 100 OFR003
PKG4 110 60 OFR002
PKG5 155 95 NA

**Required CLI Flags:**

--base-cost
--vehicles
--speed
--max-load
--capacity   (optional, default 2)

 ruby app.rb \
  --base-cost 100 \
  --packages-file inputs/delivery_time_sample.txt \
  --vehicles 2 \
  --speed 70 \
  --max-load 200 \
  --capacity 2
```

**Running Tests:**

```
bundle exec rspec
```


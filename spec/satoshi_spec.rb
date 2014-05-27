require_relative '../lib/satoshi'

describe Satoshi do

  it "creates a Bignum representing value in satoshi units" do
    expect(Satoshi.new(1.00).to_i).to eq(100000000)
  end

  it "takes care of the sign before the value" do
    expect(Satoshi.new(-1.00).to_i).to eq(-100000000)
  end

  it "converts satoshi unit back to some more common denomination" do
    expect(Satoshi.new(1.00).to_btc).to eq(1)
    expect(Satoshi.new(1.08763).to_btc).to eq(1.08763)
    expect(Satoshi.new(1.08763).to_mbtc).to eq(1087.63)
    expect(Satoshi.new(-1.08763).to_mbtc).to eq(-1087.63)
    expect(Satoshi.new(0.00000001).to_i).to eq(1)
    expect(Satoshi.new(0.00000001).to_mbtc).to eq(0.00001)
  end
   
  it "converts from various source denominations" do
    expect(Satoshi.new(1, unit: 'mbtc').to_btc).to      eq(0.001)
    expect(Satoshi.new(1, unit: 'mbtc').to_unit).to     eq(1)
    expect(Satoshi.new(10000000, unit: 'mbtc').to_unit).to eq(10000000)
    satoshi = Satoshi.new(10000000, unit: 'mbtc')
    satoshi.satoshi_value = 1
    expect(satoshi.to_unit).to eq(0.00001)
    expect(Satoshi.new(100, unit: 'mbtc').to_i).to eq(10000000)
  end

end
require_relative '../lib/crypto-unit'
require_relative '../lib/satoshi'
require_relative '../lib/litoshi'

describe CryptoUnit do

  it "creates a Bignum representing value in primary units" do
    expect(SatoshiUnit.new(1.00).to_i).to eq(100000000)
  end

  it "takes care of the sign before the value" do
    expect(SatoshiUnit.new(-1.00).to_i).to eq(-100000000)
  end

  it "converts primary unit back to some more common denomination" do
    expect(SatoshiUnit.new(1.00).to_standart).to eq(1)
    expect(SatoshiUnit.new(1.08763).to_standart).to eq(1.08763)
    expect(SatoshiUnit.new(1.08763).to_milli).to eq(1087.63)
    expect(SatoshiUnit.new(-1.08763).to_milli).to eq(-1087.63)
    expect(SatoshiUnit.new(0.00000001).to_i).to eq(1)
    expect(SatoshiUnit.new(0.00000001).to_milli).to eq(0.00001)
  end

  it "converts from various source denominations" do
    expect(SatoshiUnit.new(1, unit: 'milli').to_standart).to      eq(0.001)
    expect(SatoshiUnit.new(1, unit: 'milli').to_unit).to     eq(1)
    expect(SatoshiUnit.new(10000000, unit: 'milli').to_unit).to eq(10000000)
    satoshi = SatoshiUnit.new(10000000, unit: 'milli')
    satoshi.primary_value = 1
    expect(satoshi.to_unit).to eq(0.00001)
    expect(SatoshiUnit.new(100, unit: 'milli').to_i).to eq(10000000)
  end

  it "treats nil in value as 0" do
    expect(SatoshiUnit.new < 1).to be_truthy
    expect(SatoshiUnit.new > 1).to be_falsy
    expect(SatoshiUnit.new == 0).to be_truthy
  end

  it "converts negative values correctly" do
    expect(SatoshiUnit.new(-1.00, unit: :milli).to_standart).to eq(-0.001)
  end

  it "converts zero values correctly" do
    expect(SatoshiUnit.new(0, unit: :milli).to_unit).to eq(0)
  end

  it "converts nil values correctly" do
    s = SatoshiUnit.new(nil, unit: :milli)
    expect(s.value).to eq(0)
    s.value = nil
    expect(s.to_unit).to eq(0)
  end

  it "displays one primary unit in human form, not math form" do
    one_satoshi = SatoshiUnit.new(1, from_unit: :primary, to_unit: :standart)
    expect(one_satoshi.to_unit(as: :string)).not_to eq('1.0e-08')
    expect(one_satoshi.to_unit(as: :string)).to eq('0.00000001')
  end

  it "displays zero units in human form, not math form" do
    zero_satoshi = SatoshiUnit.new(0, from_unit: :primary, to_unit: :standart)
    expect(zero_satoshi.to_unit(as: :string)).to eq('0.0')
  end

  it "raises exception if decimal part contains more digits than allowed by from_value" do
    expect( -> { SatoshiUnit.new(0.001000888888888888888, from_unit: :standart).to_unit }).to raise_exception(CryptoUnit::TooManyDigitsAfterDecimalPoint)
    expect( -> { SatoshiUnit.new("0.001000999999999999999", from_unit: :standart).to_unit }).to raise_exception(CryptoUnit::TooManyDigitsAfterDecimalPoint)
    expect( -> { SatoshiUnit.new(0.001000999, from_unit: :standart).to_unit }).to raise_exception(CryptoUnit::TooManyDigitsAfterDecimalPoint)
    expect( -> { SatoshiUnit.new(0.00100099, from_unit: :standart).to_unit }).not_to raise_exception
    expect( -> { SatoshiUnit.new(0.123456789, from_unit: :standart) }).to raise_exception(CryptoUnit::TooManyDigitsAfterDecimalPoint)
    expect( -> { SatoshiUnit.new(0.12345678, from_unit: :standart).to_unit }).not_to raise_exception
    expect( -> { SatoshiUnit.new(nil, from_unit: :standart).to_unit }).not_to raise_exception
  end

  it "Satoshi dissallows to create values more than 21mil BTC" do
    expect( -> { SatoshiUnit.new(21_000_001) }).to raise_exception(CryptoUnit::TooLarge)
    expect( -> { SatoshiUnit.new(21_000_000) }).not_to raise_exception
  end

  it "Litoshi disallows to create values more than 84mil LTC" do
    expect( -> { LitoshiUnit.new(84_000_001) }).to raise_exception(CryptoUnit::TooLarge)
    expect( -> { LitoshiUnit.new(84_000_000) }).not_to raise_exception
  end

  it "returns CryptoUnit for +,- and * methods if both operands are CryptoUnit" do
    s1 = SatoshiUnit.new(0.001, from_unit: :standart)
    s2 = SatoshiUnit.new(0.002, from_unit: :standart)
    expect(s1+s2).to be_kind_of(SatoshiUnit)
    expect((s1+s2).to_unit).to eq(0.003)
    expect(s2-s1).to be_kind_of(SatoshiUnit)
    expect((s2-s1).to_unit).to eq(0.001)
    expect(s2*s1).to be_kind_of(SatoshiUnit)
    expect((s2*s1).to_unit).to eq(200)
  end
end

Crypto Unit
================
This tiny gem allows you to make easy conversions from one Bitcoin or Litecoin denomination into another.
It provides a class, which objects would essentially represent an amount of litecoins measured
in the smallest possible denomination, which is Satoshi for BTC and Litoshi for LTC. You can then call methods on these objects
to convert it various other denominations.

### Installation

    gem install crypto-unit

### Usage

Here's how it might look:

    s = Satoshi.new(1) # By default, it accepts amounts in BTC denomination
    s.to_i             # => 100000000 (in Satoshis)
    s.to_milli          # => 1000.0
    s.to_standart           # => 1.0
    
When creating a Satoshi / Litoshi object, you can also specify which unit is being used to pass the amount,
for example:

    s = Litoshi.new(1, from_unit: :milli)
    
    s.to_i    # => 100000
    s.to_milli # => 1.0
    s.to_standart  # => 0.001
    
There's also a special method which is called `#to_unit`, it always converts to the denomination
specified in the `:to_unit` option in the constructor. It becomes really handy when you want to
specify your preferred denomination used througout the program in just one place
(to be able to change it later):

    DENOMINATION = :milli
    s = Litoshi.new(1, from_unit: DENOMINATION, to_unit: DENOMINATION)
    s.to_unit # => 1.0 (in mLTC)
    
This can be shortened to just the `:unit` option:

    s = Litoshi.new(1, unit: DENOMINATION)
    
But, of course, if you want your "from" denomination and "to" denomination to be different, then
you'd have to pass them both manually:

    s = Satoshi.new(1, from_unit: :milli, to_unit: :standart)
    s.to_unit # => 0.001



###Comparing units

CryptoUnit objects come with methods and coercions for comparing itself with both other CyptoUnit objects and also numeric values:

    s1 = Litoshi.new(1)
    s2 = Litoshi.new(2)
    
    s1 > s2  # => false
    s1 < s2  # => true
    s1 == s2 # => false
    
    s1 > 1  # => true
    1  > s2 # => false


### Unit tests


Run `rspec spec`. Pull requests with more unit tests are welcome.

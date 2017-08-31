class CryptoUnit
  # Says how many digits after the decimal point
  # a denomination has.
  UNIT_DENOMINATIONS = {
    standart: 8,
    milli: 5,
    primary: 0,
  }

  MAX_VALUE = 0
  NAME = ''

  class TooManyDigitsAfterDecimalPoint < Exception;end
  class TooLarge                       < Exception;end

  attr_reader :value, :from_unit, :to_unit

  def initialize(n=nil, from_unit: 'standart', to_unit: 'standart', unit: nil)
    n = 0 if n.nil?
    if unit
      @from_unit = @to_unit = unit.downcase.to_sym
    else
      @from_unit = from_unit.downcase.to_sym
      @to_unit   = to_unit.downcase.to_sym
    end
    @value = convert_to_primary(n) if n
  end

  def to_standart(as: :number, format_zero: false)
    to_denomination(UNIT_DENOMINATIONS[:standart], as: as, format_zero: format_zero)
  end

  def to_milli(as: :number, format_zero: false)
    to_denomination(UNIT_DENOMINATIONS[:milli], as: as, format_zero: format_zero)
  end

  def to_unit(as: :number, format_zero: false)
    to_denomination(UNIT_DENOMINATIONS[@to_unit], as: as, format_zero: format_zero)
  end

  def to_i
    return 0 if @value.nil?
    @value
  end
  alias :primary_value :to_i

  def to_s
    to_unit.to_s
  end

  def value=(n)
    n = 0 if n.nil?
    @value = convert_to_primary(n)
  end

  def primary_value=(v)
    @value = v
  end

  def >(i)
    self.to_i > i
  end

  def <(i)
    self.to_i < i
  end

  def >=(i)
    self.to_i >= i
  end

  def <=(i)
    self.to_i <= i
  end

  def ==(i)
    self.to_i == i
  end

  def +(i)
    if i.kind_of?(CryptoUnit)
      self.class.new(self.to_i + i, from_unit: :primary)
    else
      self.to_i + i
    end
  end

  def -(i)
    if i.kind_of?(CryptoUnit)
      self.class.new(self.to_i - i, from_unit: :primary)
    else
      self.to_i - i
    end
  end

  # IMPORTANT: multiplication is done on primary units, not standart.
  # 0.01*0.02 will be a larger value.
  def *(i)
    if i.kind_of?(CryptoUnit)
      self.class.new(self.to_i * i, from_unit: :primary)
    else
      self.to_i * i
    end
  end

  def coerce(other)
    if other.kind_of?(Integer)
      [other, self.to_i]
    else
      raise TypeError, message: "CryptoUnit cannot be coerced into anything but Integer"
    end
  end

  protected

    def to_denomination(digits_after_delimiter, as: :number, format_zero: false)
      sign  = @value < 0 ? -1 : 1
      val   = @value.abs
      return val if digits_after_delimiter <= 0
      leading_zeros = "0"*(18-val.to_s.length)
      result = leading_zeros + val.to_s
      result.reverse!
      result = result.slice(0..digits_after_delimiter-1) + '.' + result.slice(digits_after_delimiter..17)
      result.reverse!
      result = result.sub(/\A0*/, '').sub(/0*\Z/, '') # remove zeros on both sides
      if as == :number
        result.to_f*sign
      else
        if result == '.'
          result = format_zero ? '0' : '0.0'
        elsif result =~ /\A\./
          result = "0#{result}"
        end
        sign == -1 ? "-#{result}" : result
      end
    end

    def convert_to_primary(n)
      n = BigDecimal.new(n.to_s)

      decimal_part_length = n.to_s("F").split(".")[1]
      decimal_part_length = if decimal_part_length
        decimal_part_length.sub(/0*\Z/, "").length
      else
        0
      end

      if decimal_part_length > UNIT_DENOMINATIONS[@from_unit]
        raise TooManyDigitsAfterDecimalPoint,
          "Too many digits (#{decimal_part_length}) after decimal point used for #{@from_unit} value, while #{UNIT_DENOMINATIONS[@from_unit]} allowed"
      end

      n = ("%.#{UNIT_DENOMINATIONS[@from_unit]}f" % n) # otherwise we might see a scientific notation
      n = n.split('.')
      n[1] ||= '' # in the case where there's no decimal part
      n[1] += "0"*(UNIT_DENOMINATIONS[@from_unit]-n[1].length) if n[1]

      if(n.join.to_i > self.class::MAX_VALUE)
        raise TooLarge, "Max value for #{self.class::NAME} is #{self.class::MAX_VALUE}"
      end

      n.join.to_i
    end
end

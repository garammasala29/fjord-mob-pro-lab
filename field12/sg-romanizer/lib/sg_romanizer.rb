class SgRomanizer
  MAX_DIGITS = 4

  ROME_NUM = [
    {
      '0' => '',
      '1' => 'I',
      '2' => 'II',
      '3' => 'III',
      '4' => 'IV',
      '5' => 'V',
      '6' => 'VI',
      '7' => 'VII',
      '8' => 'VIII',
      '9' => 'IX',
    },
    {
      '0' => '',
      '1' => 'X',
      '2' => 'XX',
      '3' => 'XXX',
      '4' => 'XL',
      '5' => 'L',
      '6' => 'LX',
      '7' => 'LXX',
      '8' => 'LXXX',
      '9' => 'XC',
    },
    {
      '0' => '',
      '1' => 'C',
      '2' => 'CC',
      '3' => 'CCC',
      '4' => 'CD',
      '5' => 'D',
      '6' => 'DC',
      '7' => 'DCC',
      '8' => 'DCCC',
      '9' => 'CM',
    },
    {
      '1' => 'M',
      '2' => 'MM',
      '3' => 'MMM'
    }
  ]

  def romanize(arabic)
    roman_digits = arabic.digits.map.with_index do |d, i|
      ROME_NUM[i][d.to_s]
    end
    roman_digits.reverse.join
  end

  def deromanize(roman)
    roman_digits = split_romans(roman)

    calc_arabic(roman_digits)
  end

  private

  def split_romans(roman)
    digits_regex = [/(?<!C)M+/, /C[MD]|D?(?<!X)C+|D/, /X[CL]|L?(?<!I)X+|L/, /I[XV]|V?I+|V/]

    rest_roman = roman
    digits_regex.map do |regex|
      rest_roman.match(regex).to_s.tap { |digits_roman|
        rest_roman = rest_roman.delete_prefix(digits_roman)
      }
    end
  end

  def calc_arabic(roman_digits)
    arabic_num = ROME_NUM.map(&:invert)
    roman_digits.each_with_index.sum do |roman,i|
      arabic_num[target_digit(i)][roman].to_i * 10 ** (target_digit(i))
    end
  end

  def target_digit(i)
    MAX_DIGITS-1-i
  end
end

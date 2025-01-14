class SgRomanizer
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

  ARABIC_NUM = {
    "X" => 10,
    "IX" => 9,
    "VIII" => 8,
    "VII" => 7,
    "VI" => 6,
    "V" => 5,
    "IV" => 4,
    "III" => 3,
    "II" => 2,
    "I" => 1
  }

  def romanize(arabic)
    roman_digits = arabic.digits.map.with_index do |d, i|
      ROME_NUM[i][d.to_s]
    end
    roman_digits.reverse.join
  end

  def deromanize(roman)
    # romans = ["X", "IX", "VIII", "VII", "VI", "V", "IV", "III", "II", "I"]
    # romans.sum { |c| roman.include?(c) ? ARABIC_NUM[c] : 0 }
    ARABIC_NUM[roman] || 0
  end
end

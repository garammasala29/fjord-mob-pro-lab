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
      '1' => 'C'
    }
  ]

  def romanize(arabic)
    roman_digits = arabic.digits.map.with_index do |d, i|
      ROME_NUM[i][d.to_s]
    end
    roman_digits.reverse.join
  end

  def deromanize(roman)
    # write your code here
  end
end

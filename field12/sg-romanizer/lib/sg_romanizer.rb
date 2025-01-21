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

  def romanize(arabic)
    roman_digits = arabic.digits.map.with_index do |d, i|
      ROME_NUM[i][d.to_s]
    end
    roman_digits.reverse.join
  end

  def deromanize(roman)
    arabic_num = ROME_NUM.map(&:invert)
    second = roman.match(/X[CL]|L?(?<!I)X+|L/).to_s #2桁目
    roman.delete_prefix!(second)
    first = roman.match(/I[XV]|V?I+|V/).to_s || 0 #1桁目

    arabic_num[1][second].to_i * 10 + arabic_num[0][first].to_i
  end
end

class HomoclaveCalculator
  HOMOCLAVE_DIGITS = '123456789ABCDEFGHIJKLMNPQRSTUVWXYZ'

  FULL_NAME_MAPPING  = {
    ' ' => '00', '0' => '00', '1' => '01', '2' => '02', '3' => '03', '4' => '04',
    '5' => '05', '6' => '06', '7' => '07', '8' => '08', '9' => '09', '&' => '10',
    'A' => '11', 'B' => '12', 'C' => '13', 'D' => '14', 'E' => '15', 'F' => '16',
    'G' => '17', 'H' => '18', 'I' => '19', 'J' => '21', 'K' => '22', 'L' => '23',
    'M' => '24', 'N' => '25', 'O' => '26', 'P' => '27', 'Q' => '28', 'R' => '29',
    'S' => '32', 'T' => '33', 'U' => '34', 'V' => '35', 'W' => '36', 'X' => '37',
    'Y' => '38', 'Z' => '39', 'Ñ' => '40'
  }
  attr_accessor :person, :full_name, :mapped_full_name, :pairs_of_digits_sum, :homoclave

  def initialize(person)
    self.person = person
  end

  def calculate
    normalize_full_name
    map_full_name_to_digits_code
    sum_pairs_of_digits
    build_homoclave

    homoclave
  end

  private

  def build_homoclave
    last_three_digits = (pairs_of_digits_sum % 1000).to_i
    quo = (last_three_digits / 34).to_i
    reminder = (last_three_digits % 34).to_i
    # puts pairs_of_digits_sum
    self.homoclave = "#{HOMOCLAVE_DIGITS[quo]}#{HOMOCLAVE_DIGITS[reminder]}"
  end

  def sum_pairs_of_digits
    self.pairs_of_digits_sum = 0
    (0..mapped_full_name.length - 2).each do |i|
      num1 = mapped_full_name[i..i + 1].to_i
      num2 = mapped_full_name[i + 1..i + 1].to_i
      # puts num1
      # puts num2
      self.pairs_of_digits_sum += num1 * num2
    end
  end

  def map_full_name_to_digits_code
    self.mapped_full_name = '0'
    full_name.each_char do |c|
      # puts "#{c} => #{map_character_to_two_digit_code(c)}"
      self.mapped_full_name += map_character_to_two_digit_code(c)
    end
  end

  def map_character_to_two_digit_code(c)
    if FULL_NAME_MAPPING.key?(c)
      return FULL_NAME_MAPPING[c]
    else
      fail IllegalArgumentException('No two-digit-code mapping for char: ' + c)
    end
  end

  def normalize_full_name
    raw_full_name = "#{person}".upcase
    self.full_name = I18n.transliterate(raw_full_name)
    self.full_name = full_name.gsub(/[-.']/, '') # remove .'-
    self.full_name = add_missing_char_to_full_name(raw_full_name, 'Ñ')
  end

  def add_missing_char_to_full_name(raw_full_name, missing_char)
    index = raw_full_name.index(missing_char)
    return full_name if index.nil?
    new_full_name = full_name
    while (index >= 0)
      new_full_name[index] = missing_char
      index = raw_full_name.index(missing_char, index + 1)
    end
    new_full_name.to_s
  end
end
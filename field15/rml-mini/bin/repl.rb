require_relative '../lib/parser_step1'

puts 'Ruby Mini Language REPL'
puts "Type 'exit' to quit"

parser = ParserStep1

loop do
  print "> "
  input = gets
  break if input.nil? || input.strip == 'exit'

  begin
    result = parser.eval(input)
    puts "=> #{result}"
  rescue => e
    puts "残念! Errorだよ!"
    puts e.message
  end
end

require_relative '../lib/parser_step5'
require_relative '../lib/evaluator'
puts 'Ruby Mini Language REPL'
puts "Type 'exit' to quit"

parser = ParserStep5
evaluator = Evaluator.new

loop do
  print "> "
  input = gets
  break if input.nil? || input.strip == 'exit'

  begin
    ast = parser.parse(input) # parserは ASTを返す
    result = evaluator.evaluate(ast) # Evaluatorが評価し結果を返す
    puts "#=> #{result}"
  rescue => e
    puts "残念! Errorだよ!"
    puts e.message
  end
end

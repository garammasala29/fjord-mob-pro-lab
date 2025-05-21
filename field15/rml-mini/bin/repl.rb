require_relative '../lib/parser_step2'

puts 'Ruby Mini Language REPL'
puts "Type 'exit' to quit"

parser = ParserStep2

loop do
  print "> "
  input = gets
  break if input.nil? || input.strip == 'exit'

  begin
    result = parser.eval(input)
    puts "#=> #{result}"
  rescue => e
    puts "残念! Errorだよ!"
    puts e.message
  end
end

__END__
# STEP4からはこちらを使ってね。
# Evaluatorが評価(eval)するように責務を変更した。

require_relative '../lib/parser_step4'

puts 'Ruby Mini Language REPL'
puts "Type 'exit' to quit"

parser = ParserStep4
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

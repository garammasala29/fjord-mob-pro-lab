require_relative '../lib/parser_step8'
require_relative '../lib/evaluator'

class REPL
  INDENT_SIZE = 2

  def initialize
    @parser = ParserStep8
    @evaluator = Evaluator.new
    @input_buffer = []
    @bracket_stack = []
  end

  def start
    puts 'Ruby Mini Language REPL'
    puts "Type '-h' or '--help' for help"
    puts

    loop do
      begin
        result = read_and_process_input
        break if result == :exit
      rescue Interrupt
        puts "\nUse 'exit to quit"
        reset_state
      end
    end

    puts "Bye!👋"
  end

  private

  def read_and_process_input
    prompt = generate_prompt
    print prompt

    line = gets

    if line.nil?
      puts
      return :exit
    end

    line = line.strip

    case line
    when 'exit', 'quit' then return :exit
    when '-h', '--help' then show_help
    when 'clear'
      reset_state
      puts "Input buffer cleared."
    when 'show' then show_current_input
    when 'vars' then show_variables
    when ''
      return if @input_buffer.empty?

      if @bracket_stack.empty?
        # かっこが全て閉じられている状態で空行が入力されたら実行
        process_input
        reset_state
      end
    else
      # 入力をバッファに追加
      @input_buffer << line
      update_bracket_stack(line)

      # かっこが全て閉じられたら実行する
      if @bracket_stack.empty?
        process_input
        reset_state
      end
    end
  end

  def generate_prompt
    # インデントの計算
    @input_buffer.empty? ? "> " : (" " * INDENT_SIZE) * (@bracket_stack.size + 1)
  end

  def update_bracket_stack(line)
    line.each_char.with_index do |char, i|
      case char
      when '{' then @bracket_stack << '}'
      when '}'
        @bracket_stack.pop if @bracket_stack.last == '}'
      when '<'
        # if文とwhile文のときのみ< > をペアとして扱う
        @bracket_stack << '>' if in_condition_context?(line, i)
      when '>'
        @bracket_stack.pop if @bracket_stack.last == '>'
      end
    end
  end

  def in_condition_context?(line, position)
    before_text = line[0...position]
    after_text = line[position..-1]

    before_text.match?(/\b(if|else-if|while)\s*$/) ||
    (before_text.match?(/\b(if|else-if|while)\b/) && !after_text.include?('{'))
  end

  def process_input
    input_text = @input_buffer.join(' ')

    begin
      ast = @parser.parse(input_text)
      result = @evaluator.evaluate(ast)

      puts result.nil? ? "#=> nil" : "#=> #{result}"

    rescue => e
      puts "Error: #{e.message}"
      puts
      puts "入力内容:"
      @input_buffer.each_with_index do |line, i|
        puts "  #{i+1}: #{line}"
      end
      puts
    end
  end

  def show_help
    puts <<~HELP

      Ruby Mini Language REPL Help
      ========================================

      Commands:
        exit          - Quit the REPL
        clear         - Clear current input buffer
        show          - Show current input buffer
        vars          - Show defined variables
        -h, --help    - Show this help

      Multi-line input:
        - Press Enter to continue input when brackets are open
        - Press Enter twice on empty line to force execution

      Examples:
        # Basic arithmetic
        x = 42
        y = x + 8

        # If statement
        if < x > 40 > {
          result = 1
        } else {
          result = 0
        }

        # While loop
        counter = 0
        while < counter < 5 > {
          counter = counter + 1
        }

        # Factorial calculation
        n = 5
        factorial = 1
        i = 1
        while < i =< n > {
          factorial = factorial * i
          i = i + 1
        }

    HELP
  end

  def show_current_input
    if @input_buffer.empty?
      puts "Input buffer is empty."
      return
    end

    puts "Current input buffer:"
    @input_buffer.each_with_index do |line, i|
      puts "  #{i + 1}: #{line}"
    end
    puts "Bracket stack: #{@bracket_stack.inspect}"
  end

  def show_variables
    vars = @evaluator.variables

    if vars.empty?
      puts "No variables defined"
    else
      puts "Defined variables:"
      puts vars.map { |name, value| "  #{name} = #{value.inspect}" }
    end
  rescue NoMethodError
    puts <<~VARS
      Variable inspection not yet implemented.
      Please add the 'variables' method to your Evaluator class.
    VARS
  end

  def reset_state
    @input_buffer.clear
    @bracket_stack.clear
  end
end

if __FILE__ == $0
  REPL.new.start
end

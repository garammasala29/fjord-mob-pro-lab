require_relative '../lib/parser_step6'
require_relative '../lib/evaluator'
puts 'Ruby Mini Language REPL'
puts "Type 'exit' to quit"

class REPL
  INDENT_SIZE = 2

  def initialize
    @parser = ParserStep6
    @evaluator = Evaluator.new
    @input_buffer = []
    @bracket_stack = []
  end

  def start
    puts 'Ruby Mini Language REPL (Advanced Multi-line)'
    puts "Commands:"
    puts "  exit          - Quit the REPL"
    puts "  clear         - Clear current input buffer"
    puts "  show          - Show current input buffer"
    puts "  vars          - Show defined variables (if implemented)"
    puts
    puts "Multi-line input:"
    puts "  - Press Enter to continue input when brackets are open"
    puts "  - Press Enter twice on empty line to force execution"
    puts

    loop do
      begin
        result = read_and_process_input
        break if result == :exit
      rescue Interrupt
        puts "\nUse 'exit' to quit"
        reset_state
      end
    end
  end

  private

  def read_and_process_input
    prompt = generate_prompt # インデントの計算
    print prompt
    line = gets

    if line.nil?
      puts
      return :exit
    end

    line.strip!

    case line
    when 'exit', 'quit'
      return :exit
    when '-h', '--help'
      show_help
    when 'clear'
      reset_state
      puts "Input buffer cleared."
    when 'show'
      show_current_input
    when 'vars'
      show_variables
    when ''
      return if @input_buffer.empty?
      # 開いたかっこが全て閉じられていたら、それまでの入力を1行として実行したい
      if @bracket_stack.empty?
        process_input
        reset_state
      end
    else
      @input_buffer << line
      update_bracket_stack(line)
      if @bracket_stack.empty?
        process_input
        reset_state
      end
    end
  end

  def update_bracket_stack(line)
    line.each_char.with_index do |char,i|
      case char
      when '{'
        @bracket_stack << '}'
      when '}'
        @bracket_stack.pop if @bracket_stack.last == '}'
      when '<'
        @bracket_stack << '>' if in_condition_context?(line, i)
      when '>'
        @bracket_stack.pop if @bracket_stack.last == '>'
      end
    end
  end


  def in_condition_context?(line, position)
    before_text = line[...position]
    # after_text = line[position..]

    before_text.match?(/\b(if|else-if)\s*\z/)
    # 実装意図がわからないのでコメントアウトした ||(before_text.match?(/\b(if|else-if)\b/) && !after_text.include?('{'))
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

  def generate_prompt
    if @input_buffer.empty?
      print '> '
    else
      print '> ' + ' ' * @bracket_stack.size * INDENT_SIZE
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
    @input_buffer = []
    @bracket_stack = []
  end
end

if __FILE__ == $0
  REPL.new.start
end

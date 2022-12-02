require "./parse"
require "./util"

# TODO: Take filename as input, -o flag for output (default, name with extension of .hack)
# TODO: Symbols

stdin_lines do |line|
  instruction = parse_instruction line
  unless instruction.nil?
    binary = instruction_to_binary instruction
     printf "%016b\n",  binary
  end
end

require "./parse"
require "./util"

stdin_lines do |line|
  instruction = parse_instruction line
  unless instruction.nil?
    binary = instruction_to_binary instruction
     printf "%016b\n",  binary
  end
end

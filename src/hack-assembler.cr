require "./parse"
require "./util"

stdin_lines do |line|
  instruction = parse_instruction line
  binary = instruction_to_binary instruction
  puts binary
end

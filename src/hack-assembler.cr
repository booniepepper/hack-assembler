require "./parse"
require "./util"

stdin_lines do |line|
  puts parse_instruction(line).inspect
end

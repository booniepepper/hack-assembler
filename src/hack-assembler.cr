require "./parse"

def stdin_lines(&f)
  line = gets
  while !line.nil?
    yield line
    line = gets
  end
end

stdin_lines do |line|
  instruction = parse_instruction(line).inspect

  puts instruction
end

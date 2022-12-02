def stdin_lines(&f)
  line = gets
  while !line.nil?
    yield line
    line = gets
  end
end

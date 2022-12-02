def parse_instruction(raw : String)
  raw = raw.strip
  if raw.starts_with? '@'
    addr = /^@(.+)$/.match(raw).try {|match| UInt16.new match[1]}

    {
      type: :a,
      addr: addr,
    }
  else
    dest = /^([DAM][DAM]?[DAM]?)=/.match(raw).try(&.[1])
    comp = /^(.+=)?(.+?)(;.+)?$/.match(raw).try(&.[2])
    jmp = /^.+;(.+)$/.match(raw).try(&.[1])

    {
      type: :c,
      dest: dest,
      comp: comp,
      jmp: jmp,
    }
  end
end

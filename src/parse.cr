alias AInstruction = NamedTuple(addr: UInt16)
alias CInstruction = NamedTuple(dest: String, comp: String, jmp: String)
alias MalformedLine = NamedTuple(raw: String)

def parse_instruction(raw : String) : AInstruction | CInstruction | MalformedLine
  raw = raw.strip
  if raw.starts_with? '@'
    addr = /^@(.+)$/.match(raw).try {|match| UInt16.new match[1]}

    unless addr.nil?
      return { addr: addr }
    end
  else
    dest = /^([DAM][DAM]?[DAM]?)=/.match(raw).try(&.[1])
    comp = /^(.+=)?(.+?)(;.+)?$/.match(raw).try(&.[2])
    jmp = /^.+;(.+)$/.match(raw).try(&.[1])

    unless dest.nil? || comp.nil? || jmp.nil?
      return {
        dest: dest,
        comp: comp,
        jmp: jmp,
      }
    end
  end

  { raw: raw }
end

def instruction_to_binary(inst)
    if inst.is_a? AInstruction
        sprintf "%016b", inst[:addr]
    elsif inst.is_a? CInstruction
        "C what I mean? #{inst.inspect}"
    else
        "unknown instruction: #{inst.inspect}"
    end
end

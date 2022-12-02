alias AInstruction = NamedTuple(addr: UInt16)
alias CInstruction = NamedTuple(dest: UInt16, comp: UInt16, jmp: UInt16)
alias MalformedLine = NamedTuple(raw: String)

def parse_dest(str : String | Nil) : UInt16
  {
    nil => 0b000,
    "M" => 0b001,
    "D" => 0b010,
    "MD" => 0b011,
    "A" => 0b100,
    "AM" => 0b101,
    "AD" => 0b110,
    "AMD" => 0b111,
  }[str].to_u16
end

def parse_comp(str : String) : UInt16
  {
    "0" => 0b0101010,
    "1" => 0b0111111,
    "-1" => 0b0111010,
    "D" => 0b0001100,
    "A" => 0b0110000,
    "M" => 0b1110000,
    "!D" => 0b0001101,
    "!A" => 0b0110001,
    "!M" => 0b1110001,
    "-D" => 0b0001111,
    "-A" => 0b0110011,
    "-M" => 0b1110011,
    "D+1" => 0b0011111,
    "A+1" => 0b0110111,
    "M+1" => 0b1110111,
    "D-1" => 0b0001110,
    "A-1" => 0b0110010,
    "M-1" => 0b1110010,
    "D+A" => 0b0000010,
    "D+M" => 0b1000010,
    "D-A" => 0b0010011,
    "D-M" => 0b1010011,
    "A-D" => 0b0000111,
    "M-D" => 0b1000111,
    "D&A" => 0b0000000,
    "D&M" => 0b1000000,
    "D|A" => 0b0010101,
    "D|M" => 0b1010101,
  }[str].to_u16
end

def parse_jmp(str : String | Nil) : UInt16
  {
    nil => 0b000,
    "JGT" => 0b001,
    "JEQ" => 0b010,
    "JGE" => 0b011,
    "JLT" => 0b100,
    "JNE" => 0b101,
    "JLE" => 0b110,
    "JMP" => 0b111,
  }[str].to_u16
end

def parse_instruction(raw : String) : AInstruction | CInstruction | MalformedLine | Nil
  raw = raw.gsub(/\/\/.+/, "").strip

  return nil if raw == ""

  if raw.starts_with? '@'
    addr = /^@(.+)$/.match(raw).try {|match| UInt16.new match[1]}

    unless addr.nil?
      return { addr: addr }
    end
  else
    dest = /^([DAM][DAM]?[DAM]?)=/.match(raw).try(&.[1])
    comp = /^(.+=)?(.+?)(;.+)?$/.match(raw).try(&.[2])
    jmp = /^.+;(.+)$/.match(raw).try(&.[1])

    unless comp.nil?
      return {
        dest: parse_dest(dest),
        comp: parse_comp(comp),
        jmp: parse_jmp(jmp),
      }
    end
  end

  { raw: raw }
end

def instruction_to_binary(inst) : UInt16
    if inst.is_a? AInstruction
        inst[:addr]
    elsif inst.is_a? CInstruction
        c = 0b111.to_u16 << 13 | inst[:comp] << 6 | inst[:dest] << 3 | inst[:jmp]
    else
        raise "unknown instruction: #{inst.inspect}"
    end
end

alias Label = String
alias LabelAs = NamedTuple(label_as: Label)
alias AssemblySymbol = NamedTuple(symbol: Label)
alias Address = NamedTuple(addr: UInt16)
alias AInstruction = Address | AssemblySymbol
alias CInstruction = NamedTuple(dest: UInt16, comp: UInt16, jmp: UInt16)
alias MalformedLine = NamedTuple(raw: String)

# TODO: Different file?

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

def parse_label(label : Label) : UInt16 | Label
  {
    "SP" => 0x000,
    "LCL" => 0x0001,
    "ARG" => 0x0002,
    "THIS" => 0x0003,
    "THAT" => 0x0004,
    "R0" => 0x0000,
    "R1" => 0x0001,
    "R2" => 0x0002,
    "R3" => 0x0003,
    "R4" => 0x0004,
    "R5" => 0x0005,
    "R6" => 0x0006,
    "R7" => 0x0007,
    "R8" => 0x0008,
    "R9" => 0x0009,
    "R10" => 0x000a,
    "R11" => 0x000b,
    "R12" => 0x000c,
    "R13" => 0x000d,
    "R14" => 0x000e,
    "R15" => 0x000f,
    "SCREEN" => 0x4000,
    "KBD" => 0x6000,
  }[label]?.try { |n| n.to_u16 } || label
end

def parse_instruction(raw : String) : AInstruction | CInstruction | LabelAs | MalformedLine | Nil
  raw = raw.gsub(/\/\/.+/, "").strip

  return nil if raw == ""

  if raw.starts_with? '@'
    addr = raw[1, raw.size - 1]

    if addr =~ /^[0-9]+$/
      return { addr: UInt16.new addr }
    end

    dest = parse_label addr

    if dest.is_a? UInt16
      return { addr: dest }
    else
      return { symbol: dest }
    end
  elsif raw.starts_with?('(') && raw.ends_with?(')')
    return { label_as: raw[1, raw.size - 2] }
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

def instruction_to_intermediate(inst) : UInt16 | AssemblySymbol | LabelAs
  if inst.is_a? Address
    inst[:addr]
  elsif inst.is_a? CInstruction
    c = 0b111.to_u16 << 13 | inst[:comp] << 6 | inst[:dest] << 3 | inst[:jmp]
  elsif inst.is_a? AssemblySymbol
    inst
  elsif inst.is_a? LabelAs
    inst
  else
    raise "unknown instruction: #{inst.inspect}"
  end
end

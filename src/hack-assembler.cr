require "option_parser"
require "./parse"

infile_input : String | Nil = nil
outfile_input : String | Nil = nil

option_parser = OptionParser.parse do |parser|
  parser.banner = "Usage: hasm [-o OUTFILE] INFILE"

  parser.on "-v", "--version", "Show version" do
    puts "hasm 1.0"
    exit
  end

  out_desc = "Specify output file (default is infile with .hack extension)"

  parser.on "-o OUTFILE", "--outfile OUTFILE", out_desc do |filename|
    outfile_input = filename
  end

  parser.on "-h", "--help", "Show help" do
    puts parser
    exit
  end

  parser.unknown_args do |args, _|
    if args.size > 0
      infile_input = args.first
    end
  end
end

if infile_input.nil?
  STDERR.puts "Missing input file."
  exit 1
end

infile : String = infile_input.not_nil!

if ! File.readable? infile
  STDERR.puts "Not a readable file: #{infile.inspect}"
  exit 1
end

outfile : String

if outfile_input.nil?
  outfile = infile.gsub(/\.[^\.]+$/, "") + ".hack"
else
  outfile = outfile_input.not_nil!
end

if File.exists? outfile
  File.delete outfile
end

File.touch outfile

if ! File.writable? outfile
  STDERR.puts "Not allowed to write to file: #{outfile.inspect}"
  exit 1
end

puts "Assembling #{infile.inspect} to #{outfile.inspect}"

first_pass : Array(UInt16 | AssemblySymbol | LabelAs) = File.read_lines(infile)
  .map { |raw| parse_instruction raw }
  .select { |instr| ! instr.nil? }
  .map { |instr| instruction_to_intermediate instr }

directory = {} of String => UInt16
i : UInt16 = 0
next_variable : UInt16 = 0x0010

first_pass.select do |instr| # Capture the lines that labels should reference
    if instr.is_a? LabelAs
      label = instr[:label_as]
      directory[label] = i
      false
    else
      i += 1
      instr
    end
  end
  .map do |instr| # Dereference symbols that point to labels
    if instr.is_a? AssemblySymbol
      label = instr[:symbol]
      directory[label]? || instr
    else
      instr
    end
  end
  .map do |instr| # Dereference remaining symbols to RAM addresses
    if instr.is_a? AssemblySymbol
      label = instr[:symbol]
      if ! directory.has_key? label
        directory[label] = next_variable
        next_variable += 1
      end
      directory[label]
    else
      instr
    end
  end
  .each do |u16|
    # Of course, in a real assembler, we'd output binary directly. The
    # specification of the Hack machine, though, expects ascii-encoded lines
    # of binary.
    binstring = sprintf "%016b\n", u16

    File.write outfile, binstring, mode: "a"
  end

puts "DONE"

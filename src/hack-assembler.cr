require "option_parser"
require "./parse"

# TODO: Take filename as input, -o flag for output (default, name with extension of .hack)
# TODO: Symbols

infile_input : String | Nil = nil
outfile_input : String | Nil = nil

option_parser = OptionParser.parse do |parser|
  parser.banner = "Usage: hasm [-o OUTFILE] INFILE"

  parser.on "-v", "--version", "Show version" do
    puts "hasm 0.1"
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

puts "Assembling #{infile.inspect} to #{outfile.inspect}"

File.each_line infile do |line|
  instruction = parse_instruction line
  unless instruction.nil?
    binary = instruction_to_binary instruction

    # Of course, in a real assembler, we'd output binary directly. The
    # specification of the Hack machine, though, expects ascii-encoded lines
    # of binary.
    printf "%016b\n",  binary
  end
end

puts "DONE"

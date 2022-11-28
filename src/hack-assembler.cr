module Hack::Assembler
  VERSION = "0.1.0"


  patterns = {
    addr: /^@(.+)$/,
    dest: /^([DAM][DAM]?[DAM]?)=/,
    comp: /^(.+=)?(.+?)(;.+)?$/,
    jmp: /^.+;(.+)$/
  }

  puts "yo"
end

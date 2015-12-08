#!/usr/bin/env ruby
# {!} info Command line interface made by Felipe Vieira for Escriba
# {!} info It reads an filename from arguments , parse the lines and print them.
require './core/borotoPrinter.rb'
require './core/borotoParser.rb'
# {!} function functions displayHelp, a simple function to display an usage mesage
def displayHelp
  puts "Usage: boroto.rb <name-of-document-to-parse>"
  puts "Boroto: PHP Class generator from SQL"
  puts "Made by Felipe Vieira"
end

if ARGV.length == 0
  puts "too few arguments"
  displayHelp
end

if ARGV.length > 1
  puts "too much arguments"
  displayHelp
end
puts "Boroto, Version 1.0. Reading file #{ARGV[0]}"
puts "Initializing..."
parser = BorotoParser.new

puts "Parsing..."
counterlines = 0
parsedlines = 0
begin
  input = File.open(ARGV[0],"r")
  while (buffer = input.gets)

    if parser.parse buffer
      parsedlines = parsedlines + 1
    end
    counterlines = counterlines + 1

  end
  input.close
rescue IOError => err
  puts "Error reading file"
  puts err
end
puts "Parsed"
puts "#{counterlines} processed"
puts "#{parsedlines} parsed"
puts "Processing..."
if parser.bcArray.empty?
  puts "no classes have been found"
  exit
end

parser.bcArray.each do |borotoclass|
  newPrinter = BorotoPrinter.new borotoclass
  newPrinter.printClass
  newPrinter.save
end
puts "Processed"

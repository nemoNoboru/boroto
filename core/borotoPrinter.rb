require './core/borotoClass.rb'

class BorotoPrinter
  # {!} class BorotoPrinter, gets an BorotoClass and print it out to a php class
  # {!} info created by felipe Vieira, for BorotoClass
  attr_reader :buffer
  #{!} method initialize(BorotoClass) creates a string buffer and gets handle of a borotoclass. Returns nil if borotoclass is nil
  def initialize borotoclass
    if ! borotoclass
      raise "error: trying to create a class with no name"
    end
    # {!} atribute borotoclass a handle of borotoclass passed in the initialize function
    @borotoClass = borotoclass
    # {!} atribute buffer, the string to be printed.
    @buffer = ""
  end

  # {!} method put changes buffer, a helper function to insert in buffer
  def put string
    @buffer = @buffer + "#{string}\n"
  end

  # {!} method phpize : string , a helper function to parse a variable to a phpvariable
  def phpize variable
    variable = "$#{variable}"
  end

  # {!} method printClass a function to print the header of the class and invoke printAtributes, printGetters and printSetters
  def printClass
    put "<?php"
    put "/* class generated automaticaly with Boroto */"
    put "/* Felipe Vieira, 2015 */"
    put ""
    put "class #{@borotoClass.name.capitalize}"
    printAtributes
    printGetters
    printSetters
    put ""
    put "?>"
  end

  # {!} method checkAtributes a helper method to check if the borotoclass have 0 atributes. if so print a error
  def checkAtributes
    if @borotoClass.atributes.empty?
      put " /* ALERT this class doesn't have atributes. this is almost absurd */"
      return false
    end
    return true
  end

  #{!} method printAtributes print each atribute of the class. invokes checkAtributes
  def printAtributes
    if checkAtributes
      @borotoClass.atributes.each do |atribute|
        put " private #{phpize(atribute)};"
      end
    end
  end

  # {!} method print a getter function (getX():X) for each atribute
  def printGetters
    if checkAtributes
      @borotoClass.atributes.each do |atribute|
        put " public function get#{atribute.capitalize}(){"
        put "   return $this->#{atribute};"
        put " }"
      end
    end
  end
  #{!} method print a setter function for each atribute
  def printSetters
    if checkAtributes
      @borotoClass.atributes.each do |atribute|
        put " public function set#{atribute.capitalize}(value){"
        put "   $this->#{atribute} = value;"
        put " }"
      end
    end
  end

  def save
    output = File.open("#{@borotoClass.name}.php","w")
    output.puts @buffer
    output.close
  rescue IOError => err
    puts "error printing to file #{@borotoClass.name}.php"
    puts err
  end
end

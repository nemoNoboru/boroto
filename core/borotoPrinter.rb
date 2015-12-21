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
    put "/* the ORM and activeRecord needs a driver. it should be named driver.php */"
    put "/* class generated automaticaly with Boroto */"
    put "/* Felipe Vieira, 2015 */"
    put ""
    put "class #{@borotoClass.name.capitalize}{"
    put ""
    put " public $driver;"
    printAtributes
    put ""
    put " public function #{@borotoClass.name.capitalize}($driver) {"
    put " /* BE CARE the ORM and activeRecord functionality of boroto generted classes needs an Drive Class with a function exec that executes SQL queries and returns arrayassoc or arrays of arrayassoc */"
    @borotoClass.atributes.each do |atribute|
      put "   $this->#{atribute} = null;"
    end
    put "   $this->driver = $driver;"
    put " }"
    put ""
    put "/* get an array_fetch from driver and fill the atributes of $this */"
    put " public function fill($arrayassoc) {"
    @borotoClass.atributes.each do |atribute|
      put "  $this->set#{atribute.capitalize}($arrayassoc['#{atribute}']);"
    end
    put " }"
    put ""
    put "/* Getters... */"
    printGetters
    put ""
    put "/* Setters... */"
    printSetters
    put ""
    #checkIfExist
    put ""
    factory
    put ""
    findBy
    put ""
    put "/* deletes from db */"
    destroyRecord
    put ""
    put "/* saves to db */"
    saveRecord
    put ""
    put "}"
    put "?>"
  end

  def factory
    put "/* factory method, takes an array of mysqli::array_fetch and returns a array of #{@borotoClass.name} */"
    put " public function factory($arrayfetch){"
    put "   $arraytoret = Array();"
    put "   if($arrayfetch){"
    put "     foreach($arrayfetch as $fetch){"
    put "       $newObject = new #{@borotoClass.name}($this->driver);"
    put "       $newObject->fill($fetch);"
    put "       array_push($arraytoret,$newObject);"
    put "     }"
    put "   }"
    put " return $arraytoret;"
    put " }"
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
        put " public function set#{atribute.capitalize}($value){"
        put "   $this->#{atribute} = $value;"
        put " }"
      end
    end
  end

  def checkIfExist
    put " /* check the existance of a value */"
    put " public function checkExistence($key,$value){ "
    put "   $query='select '.$key.'from #{@borotoClass.name} where '.$key.'='.$value;"
    put "   $result = $this->driver->exec();"
    put "   return $result->num_rows == 0;"
    put " }"
  end

  def findBy
    if checkAtributes
      put " /* return an array containing all #{@borotoClass.name} that key = value */"
      put " public function findBy($key,$value){ "
      put "   $arraytoret = array();"
      put "   $query='select *"
      #@borotoClass.atributes.each do |atribute|
      #  put "   #{atribute}"
      #end
      put "     from #{@borotoClass.name}"
      put "     where '.$key.'=\"'.$value.'\"';"
      put "   $results = $this->driver->exec($query);"
      put "   return $this->factory($results);"
      put "}"
      put ""
      put "/* returns an array of #{@borotoClass.name} containing all rows from db */"
      put " public function all(){ "
      put "   $arraytoret = array();"
      put "   $query='select *"
      #@borotoClass.atributes.each do |atribute|
      #  put "   #{atribute}"
      #end
      put "     from #{@borotoClass.name}';"
      put "   $results = $this->driver->exec($query);"
      put "   return $this->factory($results);"
      put "}"
    end
  end



  def destroyRecord
    put " public function destroy(){"
    put "   $query = 'delete from #{@borotoClass.name} where"
    put "   #{@borotoClass.atributes.first} = \"'.$this->get#{@borotoClass.atributes.first.capitalize}().'\"';"
    put "   $this->driver->exec($query);"
    put " }"
  end

  def saveRecord
    buffer = Array.new
    @borotoClass.atributes.each do |atribute|
      buffer <<  "\"'.$this->get#{atribute.capitalize}().'\""
    end
    put " public function save() {"
    put "    $this->destroy();"
    put "   $query = 'insert into #{@borotoClass.name} (#{@borotoClass.atributes.join(",")}) values (#{buffer.join(",")})';"
    put "   $this->driver->exec($query);"
    put "}"
    buffer.shift
    @borotoClass.atributes.shift
    put " public function create() {"
    put "   $query = 'insert into #{@borotoClass.name} (#{@borotoClass.atributes.join(",")}) values (#{buffer.join(",")})';"
    put "   $this->driver->exec($query);"
    put "}"
  end

  def save
    output = File.open("output/#{@borotoClass.name}.php","w")
    output.puts @buffer
    output.close
  rescue IOError => err
    puts "error printing to file #{@borotoClass.name}.php"
    puts err
  end
end

class BorotoClass
  # {!} class BorotoClass, a class to contain class name and atributes to pass to Printer
  # {!} info created by Felipe Vieira, to boroto: a php class generator from sql
  attr_reader :name, :atributes
  # {!} method initialize(name) sets name of borotoclass and creates a new array to contain atributes
  def initialize boroto_name
    # {!} atribute name boroto's class name
    @name = boroto_name
    # {!} atribute atributes, an array with all the atributes of the future class
    @atributes = Array.new
  end

  # {!} method pushAtribute(atribute) : bool pushes into array atributes an atribute. returns false if atribute is nil
  def pushAtribute atribute
    if atribute
      @atributes.push atribute
      return true
    end
    return false
  end
end

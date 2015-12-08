require './core/borotoClass.rb'
# {!} class BorotoParser, reads a raw line of sql and creates the adecuate borotoClass
# {!} info made by Felipe Vieira, for roboto, 2015
class BorotoParser
  attr_reader :bcArray
  def initialize
    @bcArray = Array.new
    @patternInit = /create table +[^`]+`(.+)`/i
    @patternAtr = /`(.+)`/
    @patternEnd = /;/
    @actualNode = nil
    @flag = false
  end

  def parse raw
    if @flag
      if result = @patternAtr.match(raw)
        pushAtr result[1]
        return true
      end
      if result = @patternEnd.match(raw)
        @flag = false
        return true
      end
      return false
    end

    if result = @patternInit.match(raw)
      pushCls result[1]
      @flag = true
      return true
    end
    return false
  end

  def pushAtr atribute
    if @actualNode
      @actualNode.pushAtribute atribute
    else
      raise "trying to create a atribute outside of a class"
    end
  end

  def pushCls classname
    newClass = BorotoClass.new classname
    @actualNode = newClass
    @bcArray.push newClass
  end
end

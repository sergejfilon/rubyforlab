# Principal class
class Principal
  def initialize(first_name, last_name, position, password)
    @first_name = first_name
    @last_name = last_name
    @position = position
    @password = password
  end

  def ==(other)
    other.first_name == @first_name && other.last_name == @last_name
  end

  attr_reader :first_name, :last_name, :position, :password
end

# Authentication class
class Authentication
  def initialize
    @logged = false
  end

  def login(principal)
    @logged = true
    @logged_principal = principal
  end

  def logout
    @logged = false
  end

  attr_reader :logged_principal, :logged
end

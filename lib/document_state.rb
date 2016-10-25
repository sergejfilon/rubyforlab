# Document state
class DocumentState
  def initialize
    @registered_status = false
    @modified = nil
  end

  def update_modified
    @modified = Time.new
  end

  def register
    @registered_status = true
  end

  def registered?
    @registered_status
  end

  attr_reader :registered_status, :modified
end

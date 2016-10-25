# Document state
class DocumentState
  def initialize
    @comments_allowed = true
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

  def comments_on
    @comments_allowed = true
  end

  def comments_off
    @comments_allowed = false
  end

  attr_reader :comments_allowed, :registered_status, :modified
end

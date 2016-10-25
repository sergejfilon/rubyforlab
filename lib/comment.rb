# Comment class
class Comment
  def initialize(message, author)
    @message = message
    @author = author
    @date = Time.new
  end
  attr_reader :message, :author, :date
end

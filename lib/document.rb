require_relative 'metadata.rb'
require_relative 'principal.rb'
require_relative 'document_state.rb'

# Document class
class Document
  def initialize(metadata)
    @metadata = metadata
    @document_version = 1
    @comments = []
    @document_state = DocumentState.new
  end

  def rename(new_title)
    metadata.rename(new_title) &&
      @document_state.update_modified unless w_reg?
  end

  def register
    @document_state.register unless metadata.signers.empty?
  end

  def w_reg?
    @document_state.registered_status
  end

  def modified
    @document_state.modified
  end

  def add_signer(principal)
    metadata.add_signer(principal) unless @document_state.registered?
  end

  def remove_signer(principal)
    metadata.remove_signer(principal) unless @document_state.registered_status
  end

  def clear_signers
    metadata.clear_signers unless @document_state.registered_status
  end

  def update_version
    @document_version += 1 unless w_reg?
  end

  def add_comment(commentt)
    comm_len = commentt.message.length
    return unless @document_state.comments_allowed && comm_len.between?(1, 50)
    comments.push(commentt)
  end

  def remove_comment(index)
    comments.delete_at(index)
  end

  def clear_comments
    comments.clear
  end

  def comment_allowed?
    @document_state.comments_allowed
  end

  def turn_comments_off
    @document_state.comments_off
  end

  def turn_comments_on
    @document_state.comments_on
  end

  attr_reader :metadata, :document_version, :comments, :document_status
end

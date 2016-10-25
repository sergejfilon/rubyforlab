require_relative 'metadata.rb'
require_relative 'principal.rb'
require_relative 'document_state.rb'

# Document class
class Document
  def initialize(metadata)
    @metadata = metadata
    @document_version = 1
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

  attr_reader :metadata, :document_version, :document_status
end

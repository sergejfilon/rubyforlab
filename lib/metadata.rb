# Metadata class
class MetaData
  def initialize(title, type, signers, author)
    @title = title.gsub(/[^a-zA-Z1-9_]/, '')
    @type = type
    @signers = signers
    @author = author
  end

  def rename(new_title)
    @title = new_title.gsub(/[^a-zA-Z1-9_]/, '')
  end

  def add_signer(principal)
    index = @signers.index { |princ| princ == principal }
    @signers.push(principal) unless index
  end

  def remove_signer(principal)
    index = @signers.index { |princ| princ == principal }
    @signers.delete_at(index) if index
  end

  def clear_signers
    @signers.clear
  end

  attr_reader :title, :signers, :document_version,
              :registered_status, :author
end

require_relative 'principal.rb'
# Document Filter
class DocumentFilter
  def self.filter_author_signer(documents, principal)
    indexes = []
    documents.each_index do |index|
      doc_md = documents.at(index).metadata
      if doc_md.author == principal ||
         doc_md.signers.include?(principal)
        indexes.push(index)
      end
    end
    indexes
  end

  def self.filter_author(documents, principal)
    indexes = []
    documents.each_index do |index|
      next unless author?(documents.at(index), principal)
      indexes.push(index)
    end
    indexes
  end

  def self.author?(document, principal)
    !document.w_reg? && principal == document.metadata.author
  end
end

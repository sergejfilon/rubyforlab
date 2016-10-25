# Document Factory
require_relative 'document.rb'
require_relative 'principal.rb'
require_relative 'metadata.rb'
# Document Factory
class DocumentFactory
  @prin_a = Principal.new('Sergio', 'Ramos', 'Administrator', 'aaa')
  @prin_b = Principal.new('Alejandro', 'Dominguez', 'Architect', 'bbb')

  def self.standart_document
    principals = [@prin_a, @prin_b]
    m_data = MetaData.new('document_1', 'Holiday', principals, principals.at(0))
    Document.new(m_data)
  end

  def self.document_without_principals
    principal = Principal.new('Sergio', 'Ramos', 'Administrator', 'aaa')
    m_data = MetaData.new('document_1', 'Holiday', [], principal)
    Document.new(m_data)
  end

  def self.all_documents
    doc_a = Document.new(MetaData.new('doc_1',
                                      'Holiday', [@prin_a], @prin_a))
    doc_b = Document.new(MetaData.new('doc_2', 'ParentDay', [@prin_b], @prin_b))
    doc_c = Document.new(MetaData.new('doc_3',
                                      'Holiday', [@prin_a, @prin_b], @prin_a))
    [doc_a, doc_b, doc_c]
  end
end

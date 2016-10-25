require './lib/document_factory.rb'
# Repository class
class Repository
  def initialize
    @documents = DocumentFactory.all_documents
    @principals = [Principal.new('Alejandro', 'Dominguez', 'Architect', 'aaa'),
                   Principal.new('Sergio', 'Ramos', 'Administrator', 'bbb')]
  end

  def load_principals(principals)
    @principals = principals
  end

  def load_documents(documents)
    @documents = documents
  end

  attr_reader :documents, :principals
end

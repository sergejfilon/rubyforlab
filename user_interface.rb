require './repository.rb'
require './lib/authentication.rb'
require './lib/document_filter.rb'
require './lib/comment.rb'
require './lib/metadata.rb'
require 'yaml'

# User interface
class UserInterface
  def initialize
    @choice = 0
    @repository = Repository.new
    @authentication = Authentication.new
  end

  def login
    logged = 0
    while logged.zero?
      puts 'Enter Principal ID '
      user_id = gets.chomp.to_i
      puts 'Enter Principal password'
      user_pw = gets.chomp.to_s
      principal = @repository.principals.find do |x|
        @repository.principals.index(x) == (user_id - 1) &&
          x.password == user_pw
      end
      if principal.nil?
        puts 'Login failed'
      else
        logged = 1
        @authentication.login(principal)
      end
    end
  end

  def logout
    @authentication.logout
  end

  def show_start_menu
    login unless @authentication.logged
    puts 'Welcome, ' + @authentication.logged_principal.first_name.to_s
    puts ' << Main menu >>'
    puts ' '
    puts ' * Create Document --------- 1'
    puts ' * View Documents ---------- 2'
    puts ' * Manage Documents -------- 3'
    puts ' * View Principals --------- 4'
    puts ' * Load Data --------------- 5'
    puts ' * Save Data --------------- 6'
    puts ' * Logout ------------------ 7'
    puts ' * Exit -------------------- 8'
    @choice = gets.chomp.to_i
  end

  def show_document_creation
    signers_id = []
    puts ' Type document title'
    title = gets.chomp
    puts ' Type document type'
    type = gets.chomp
    new_signer = 1
    while new_signer == 1
      puts ' Type signer ID (-1 to end)'
      data = gets.chomp.to_i
      if data != -1
        signers_id.push(data)
        puts 'pushed'
      else
        new_signer = 0
        puts 'ended'
      end
    end
    principals = []
    signers_id.each { |x| principals.push(@repository.principals.at(x - 1)) }
    document = Document.new(MetaData.new(title, type, principals,
                                         @authentication.logged_principal))
    @repository.documents.push(document)
    puts 'end of doc creation'
  end

  def show_principals
    i = 0
    @repository.principals.each do |x|
      i += 1
      puts '<*> ID [' + i.to_s +
           '] FIRTNAME: [' + x.first_name +
           '] LASTNAME: [' + x.last_name +
           '] POSITION: [' + x.position + ']'
    end
  end

  def show_view_document
    i = 0
    if @authentication.logged_principal.position == 'Administrator'
      filtered_indexes = []
    else
      filtered_indexes = DocumentFilter
                         .filter_author_signer(@repository.documents,
                                               @authentication.logged_principal)
    end
    @repository.documents.each do |x|
      i += 1
      next unless filtered_indexes.include?(i - 1)
      puts ' #  UNIQUE_ID [' + i.to_s + ']'
      puts ' -  DOCUMENENT TITLE [' + x.metadata.title.to_s + ']'
      puts ' -  AUTHOR [' + x.metadata.author.first_name.to_s + ']'
      puts ' -  VERSION [' + x.document_version.to_s + ']'
      puts ' -  REGISTERED [' + x.w_reg?.to_s + ']'
      x.metadata.signers.each { |y| puts ' -  SIGNER [' + y.first_name + ']' }
      puts ' '
    end
  end

  def show_document_management
    puts ' * Rename document --------- 1'
    puts ' * Delete document --------- 2'
    puts ' * Register document ------- 3'
    puts ' * Update document version - 4'
    puts ' * Add document signer ----- 5'
    puts ' * Remove document signer -- 6'
    puts ' * Read comments ----------- 7'
    puts ' * Write comment ----------- 8'
    puts ' * Delete comment ---------- 9'
    puts ' * Main menu --------------- 0'
    choice = gets.chomp.to_i
    if @authentication.logged_principal.position == 'Administrator'
      filtered_indexes = @repository.documents
    else
      filtered_indexes = DocumentFilter
                         .filter_author(@repository.documents,
                                        @authentication.logged_principal)
    end
    case choice
    when 0
    when 1
      rename_document(filtered_indexes)
    when 2
      delete_document(filtered_indexes)
    when 3
      register_document(filtered_indexes)
    when 4
      update_doc_version(filtered_indexes)
    when 5
      add_document_signer(filtered_indexes)
    when 6
      remove_document_signer(filtered_indexes)
    when 7
      read_comments(filtered_indexes)
    when 8
      add_comment(filtered_indexes)
    when 9
      remove_comment(filtered_indexes)
    else
      puts 'error'
    end
  end

  def rename_document(filtered_indexes)
    puts 'Enter document unique_id'
    doc_id = gets.chomp.to_i
    puts 'Enter new title'
    new_title = gets.chomp.to_s
    if filtered_indexes.include?(doc_id - 1)
      if !@repository.documents.at(doc_id - 1).w_reg?
        @repository.documents.at(doc_id - 1).rename(new_title)
        puts 'Success'
      else
        puts 'Error'
      end
    else
      puts 'cannot find document'
    end
  end

  def delete_document(filtered_indexes)
    puts 'Enter document unique_id'
    doc_id = gets.chomp.to_i
    if filtered_indexes.include?(doc_id - 1)
      @repository.documents.delete_at(doc_id - 1)
      puts 'Success'
    else
      puts 'cannot find document'
    end
  end

  def register_document(filtered_indexes)
    puts 'Enter document unique_id'
    doc_id = gets.chomp.to_i
    if filtered_indexes.include?(doc_id - 1)
      if !@repository.documents.at(doc_id - 1).w_reg?
        @repository.documents.at(doc_id - 1).register
        puts 'Success'
      else
        puts 'Error'
      end
    else
      puts 'cannot find document'
    end
  end

  def update_doc_version(filtered_indexes)
    puts 'Enter document unique_id'
    doc_id = gets.chomp.to_i
    if filtered_indexes.include?(doc_id - 1)
      if !@repository.documents.at(doc_id - 1).w_reg?
        @repository.documents.at(doc_id - 1).update_version
        puts 'Success'
      else
        puts 'Error'
      end
    else
      puts 'cannot find document'
    end
  end

  def add_document_signer(filtered_indexes)
    puts 'Enter document unique_id'
    doc_id = gets.chomp.to_i
    puts 'Enter signer principal id'
    pr_id = gets.chomp.to_i
    principal = @repository.principals.at(pr_id - 1)
    if !principal.nil? && filtered_indexes.include?(doc_id - 1)
      if !@repository.documents.at(doc_id - 1).w_reg?
        @repository.documents.at(doc_id - 1).add_signer(principal)
        puts 'Success'
      else
        puts 'Error'
      end
    else
      puts 'cannot find document'
    end
  end

  def remove_document_signer(filtered_indexes)
    puts 'Enter document unique_id'
    doc_id = gets.chomp.to_i
    puts 'Enter signer principal id'
    pr_id = gets.chomp.to_i
    principal = @repository.principals.at(pr_id - 1)
    if !principal.nil? && filtered_indexes.include?(doc_id - 1)
      if !@repository.documents.at(doc_id - 1).w_reg?
        @repository.documents.at(doc_id - 1).remove_signer(principal)
        puts 'Success'
      else
        puts 'Error'
      end
    else
      puts 'cannot find document'
    end
  end

  def read_comments(filtered_indexes)
    puts 'Enter document unique_id'
    doc_id = gets.chomp.to_i
    if filtered_indexes.include?(doc_id - 1)
      i = 0
      @repository.documents.at(doc_id - 1).comments.each do |x|
        i += 1
        puts ' #  Comment ID [' + i.to_s + ']'
        puts ' -  Author ID [' + x.author.first_name + ']'
        puts ' -  Date [' + x.date.to_s + ']'
        puts ' -  Text [' + x.message + ']'
        puts ' '
      end
    else
      puts 'cannot find document'
    end
  end

  def add_comment(filtered_indexes)
    puts 'Enter document unique_id'
    doc_id = gets.chomp.to_i
    puts 'Enter message'
    message = gets.chomp.to_s
    comment = Comment.new(message, @authentication.logged_principal)
    if filtered_indexes.include?(doc_id - 1)
      if @repository.documents.at(doc_id - 1).comment_allowed?
        @repository.documents.at(doc_id - 1).add_comment(comment)
        puts 'Success'
      else
        puts 'Error'
      end
    else
      puts 'cannot find document'
    end
  end

  def remove_comment(filtered_indexes)
    puts 'Enter document unique_id'
    doc_id = gets.chomp.to_i
    puts 'Enter comment unique_id'
    com_id = gets.chomp.to_i
    if filtered_indexes.include?(doc_id - 1)
      if @repository.documents.at(doc_id - 1).comment_allowed?
        @repository.documents.at(doc_id - 1).remove_comment(com_id - 1)
        puts 'Success'
      else
        puts 'Error'
      end
    else
      puts 'cannot find document'
    end
  end

  def save_data
    puts 'Type filename'
    filename = gets.chomp
    serialized = { 'Principals' => @repository.principals,
                   'Documents' => @repository.documents }
    File.open(filename, 'w') { |f| f.write(serialized.to_yaml) }
  end

  def load_data
    puts 'Type filename'
    filename = gets.chomp
    parsed = YAML.load(File.open(filename))
    @repository.load_principals(parsed['Principals'])
    @repository.load_documents(parsed['Documents'])
  end

  def process_selection
    case @choice
    when 1
      show_document_creation
    when 2
      show_view_document
    when 3
      show_document_management
    when 4
      show_principals
    when 5
      load_data
    when 6
      save_data
    when 7
      logout
    when 8
      abort('Program closed')
    else
      puts "You gave me #{@choice} -- I have no idea what to do with that."
    end
  end
end

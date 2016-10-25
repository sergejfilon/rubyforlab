require_relative './spec_helper.rb'

RSpec.describe Document do
  let(:doc) { DocumentFactory.standart_document }

  let(:document_title) { 'document_1' }

  let(:document_invalid_title) { 'do$c!ument_1' }

  let(:renamed_document_title) { 'document_2' }

  let(:cust_principal) { Principal.new('Juan', 'Maria', 'Specialist', 'pw1') }

  let(:dup_principal) { Principal.new('Sergio', 'Ramos', 'Director', 'pw2') }

  it 'can rename document' do
    doc.rename(renamed_document_title)
    expect(doc.metadata.title).to eq(renamed_document_title)
  end

  it 'can add document signer' do
    doc.add_signer(cust_principal)
    expect(doc.metadata.signers).to include(cust_principal)
  end

  it 'can clear all signers' do
    doc.add_signer(cust_principal)
    doc.clear_signers
    expect(doc.metadata.signers).to be_empty
  end

  it 'cannot clear all signers if registered' do
    doc.register
    doc.clear_signers
    expect(doc.metadata.signers).not_to be_empty
  end

  it 'cannot add document signer duplicate' do
    doc.add_signer(dup_principal)
    expect(doc.metadata.signers.size).to eq(2)
  end

  it 'after changing document, modified attr contains datetime of change' do
    doc.rename(renamed_document_title)
    expect(doc.modified.to_date).to eq(Time.new.to_date)
  end

  it 'can remove document signer' do
    doc.remove_signer(dup_principal)
    expect(doc.metadata.signers).not_to include(dup_principal)
  end

  it 'cannot use invalid symbols in document title' do
    doc.rename(document_invalid_title)
    expect(doc.metadata.title).not_to match(/[^a-zA-Z1-9_]/)
  end

  it 'can update document version' do
    doc.update_version
    expect(doc.document_version).to eq(2)
  end

  it 'cannot rename registered document' do
    doc.register
    doc.rename(renamed_document_title)
    expect(doc.metadata.title).to eq(document_title)
  end

  it 'remove signer from empty list' do
    doc.remove_signer(cust_principal)
    expect(doc.metadata.signers.size).to satisfy { |s| s == 2 }
  end

  context 'document containing no signers' do
    let(:empty_doc) { DocumentFactory.document_without_principals }

    it 'cannot register if signers dont exist' do
      empty_doc.register
      expect(empty_doc.w_reg?).to be false
    end
  end

  it 'cannot update version if registered' do
    doc.register
    doc.update_version
    expect(doc.document_version).to eq(1)
  end

  it 'cannot add signer if registered' do
    doc.register
    doc.add_signer(cust_principal)
    expect(doc.metadata.signers).not_to include(cust_principal)
  end

  it 'cannot remove signer if registered' do
    doc.register
    doc.remove_signer(dup_principal)
    expect(doc.metadata.signers).to include(dup_principal)
  end

  it 'after filtering user can see documents where he is signer or author' do
    docs = DocumentFactory.all_documents
    principal = Principal.new('Alejandro', 'Dominguez', 'Architect', 'bbb')
    filtered_indexes = DocumentFilter.filter_author_signer(docs, principal)
    expect(filtered_indexes).to include(1, 2)
  end

  it 'after filtering user can see documents where he is author' do
    docs = DocumentFactory.all_documents
    principal = Principal.new('Alejandro', 'Dominguez', 'Architect', 'bbb')
    filtered_indexes = DocumentFilter.filter_author(docs, principal)
    expect(filtered_indexes).to include(1)
  end

  it 'use cant see document if he is not author or signer' do
    dcs = DocumentFactory.all_documents
    p = Principal.new('Alejandro', 'Dominguez', 'Architect', 'bbb')
    filtered_indexes = DocumentFilter.filter_author_signer(dcs, p)
    bad_indexes = filtered_indexes.find do |x|
      dcs.at(x).metadata.author != p && !dcs.at(x).metadata.signers.include?(p)
    end
    expect(bad_indexes).to be_nil
  end

  it 'user cant see document if he is not author' do
    docs = DocumentFactory.all_documents
    principal = Principal.new('Alejandro', 'Dominguez', 'Architect', 'bbb')
    filtered_indexes = DocumentFilter.filter_author(docs, principal)
    bad_indexes = filtered_indexes.find do |x|
      docs.at(x).metadata.author != principal
    end
    expect(bad_indexes).to be_nil
  end
end

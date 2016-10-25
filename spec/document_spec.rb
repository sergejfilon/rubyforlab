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
end

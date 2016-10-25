require 'simplecov'
SimpleCov.start
require_relative '../lib/authentication.rb'
require_relative '../lib/principal.rb'

RSpec.describe Authentication do
  it 'can logout' do
    a = Authentication.new
    a.login(Principal.new('Sergio', 'Ramos', 'Director', 'pw2'))
    a.logout
    expect(a.logged).to be false
  end

  it 'can login' do
    a = Authentication.new
    pr = Principal.new('Sergio', 'Ramos', 'Director', 'pw2')
    a.login(pr)
    expect(a.logged).to be true
    expect(a.logged_principal).to eq(pr)
  end

  it 'before login where is no user' do
    a = Authentication.new
    expect(a.logged).to be false
  end
end

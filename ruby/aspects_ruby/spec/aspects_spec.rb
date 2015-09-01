require 'rspec'
require_relative '../src/aspects'

describe 'Aspect tests' do

  it 'chequear parametros pasados' do
    aspect = Aspects.new
    expect(aspect.on('hola', 'tarolas', '0')).to eq('Me pasaste hola, tarolas y 0')
  end

  it 'falla por falta de parametros' do
    aspect = Aspects.new
    expect { aspect.on('hola') }.to raise_error(ArgumentError) #, 'wrong number of arguments (0 for +1)')
  end


end
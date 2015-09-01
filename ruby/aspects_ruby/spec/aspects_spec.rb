require 'rspec'
require_relative '../src/aspects'

describe 'Aspect tests' do

  it 'chequear parametros pasados' do
    class MiClase

    end
    module MiModulo

    end
    miObjeto =  MiClase.new

    aspect = Aspects.new
    expect(aspect.on(MiClase, miObjeto, MiModulo)).to eq("Me pasaste MiClase, #{miObjeto} y MiModulo")
  end

  it 'falla por falta de parametros' do
    aspect = Aspects.new
    expect { aspect.on('hola') }.to raise_error(ArgumentError) #, 'wrong number of arguments (0 for +1)')
  end


end
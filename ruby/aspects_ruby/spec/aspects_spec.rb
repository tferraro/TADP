require 'rspec'
require_relative '../src/aspects'

describe 'Aspect tests' do

  it 'chequear parametros pasados' do
    class MiClase

    end
    module MiModulo

    end
    miObjeto = MiClase.new

    aspect = Aspects.new
    expect(aspect.on(MiClase, miObjeto, MiModulo) { 'hola!' }).to eq("Me pasaste MiClase, #{miObjeto}, MiModulo y hola!")
  end

  it 'falla por no pasarle un bloque' do
    class MiClase

    end
    aspect = Aspects.new
    expect { aspect.on(MiClase) }.to raise_error(ArgumentError, 'wrong number of arguments (0 for +1)')
  end

  it 'falla por no pasarle orgien' do
    aspect = Aspects.new
    expect { aspect.on { 'hola' } }.to raise_error(ArgumentError, 'origen vacio')
  end

  it 'acepta regex de una clase que existe' do
    class MiClase

    end
    aspect = Aspects.new
    expect(aspect.on(/MiClase/) { 'hola' }).to eq ('Me pasaste (?-mix:MiClase) y hola')
  end

  it 'falla regex de una clase que no existe' do
    aspect = Aspects.new
    #expect{aspect.on(/Saraza/) { 'hola' }}.to raise_error(ArgumentError, 'origen vacio')
  end

end
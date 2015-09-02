require 'rspec'
require_relative '../src/aspects'

describe 'Aspect origenes' do

  before(:each) do
    class MiClase

    end
    module MiModulo

    end
  end

  it 'chequear parametros pasados' do

    miObjeto = MiClase.new

    aspect = Aspects.new
    expect(aspect.on(MiClase, miObjeto, MiModulo) { 'hola!' }).to eq("Me pasaste MiClase, #{miObjeto}, MiModulo y hola!")
  end

  it 'falla por no pasarle un bloque' do
    aspect = Aspects.new
    expect { aspect.on(MiClase) }.to raise_error(ArgumentError, 'wrong number of arguments (0 for +1)')
  end

  it 'falla por no pasarle orgien' do
    aspect = Aspects.new
    expect { aspect.on { 'hola' } }.to raise_error(ArgumentError, 'origen vacio')
  end

  it 'acepta regex de una clase que existe' do
    aspect = Aspects.new
    expect(aspect.on(/MiClase/) { 'hola' }).to eq ('Me pasaste MiClase y hola')
  end

  it 'falla regex de una clase que no existe' do
    aspect = Aspects.new
    expect { aspect.on(/Saraza/) { 'hola' } }.to raise_error(ArgumentError, 'origen vacio')
  end

  it 'acepta regex parcial de una clase que existe' do
    aspect = Aspects.new
    expect(aspect.on(/^Mi.*/) { 'hola' }).to eq ('Me pasaste MiClase, MiModulo y hola')
  end
end


describe 'Aspect parseo de regex y demaces' do

  it 'obtener origen de varias regex' do
    expect(Module.get_origin_by_multiple_regex([/Class/, /Object/])).to eq([Class, NilClass, TrueClass, FalseClass, Object, BasicObject, ObjectSpace])
  end
  it 'obtener nada con regex que no matchea' do
    expect(Module.get_origin_by_multiple_regex([/CACA/])).to eq([])
  end

  it 'obtener origen de varias regex repetidas' do
    expect(Module.get_origin_by_multiple_regex([/Class/, /Class/])).to eq([Class, NilClass, TrueClass, FalseClass])
  end

  it 'obtener origen de una regex' do
    expect(Module.get_origin_by_regex(/Class/)).to eq([Class, NilClass, TrueClass, FalseClass])
  end

  it 'obtener origen de una regex' do
    expect(Module.get_origin_by_regex(/Class/)).to eq([Class, NilClass, TrueClass, FalseClass])
  end

  it 'obtener simbolos de una regex' do
    expect(Module._get_symbol_by_regex(/Class/)).to eq([:Class, :NilClass, :TrueClass, :FalseClass])
  end

  it 'obtener ningun simbolo porque no matcheo la regex' do
    expect(Module._get_symbol_by_regex(/Saraza/)).to eq([])
  end

  it 'matcheo con nombres de clases' do
    class MiClase

    end
    expect(Aspects.new.class_exists?('MiClase')).to eq(true)
    expect(Aspects.new.class_exists?('MiClase2')).to eq(false)
  end

  it 'matcheo con nombres de modulos' do
    module MiModulo

    end
    expect(Aspects.new.module_exists?('MiModulo')).to eq(true)
    expect(Aspects.new.module_exists?('MiModulo2')).to eq(false)
  end
end

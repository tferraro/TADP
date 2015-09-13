require 'rspec'
require_relative '../src/aspects_origin'

describe 'Usar Conversor a Origenes' do

  class MiClaseLoca

  end

  it 'probar la conversion a MiClaseLoca con Clase y Regex' do
    expect(Aspects_Origin_Converter.create_origins([MiClaseLoca, /MiClase/])).to eq([MiClaseLoca])
  end

  it 'probar la conversion a MiClaseLoca con Regex' do
    expect(Aspects_Origin_Converter.create_origins([/MiClase/])).to eq([MiClaseLoca])
  end

  it 'al no matchear con nada devuelve un array vacio' do
    expect(Aspects_Origin_Converter.create_origins([/BLABLABLABLA/])).to eq([])
  end

  it 'multiples regexp matchean' do
    expect(Aspects_Origin_Converter.create_origins([/^Class/, /^Object$/])).to eq([Class, Object])
  end
end

describe 'Usar Aspects para conseguir un Origenes' do

  class MiClaseLoca
  end

  it 'probar la conversion a MiClaseLoca con Clase y Regex' do
    source = Aspects_Origin_Converter.create_origins([/MiClase/])
    origins = source.map { |s| Aspect_Origin.create_origin(s) }
    expect(origins.first.base).to eq(MiClaseLoca)
  end

  it 'probar ver el metodo foo publico de MiClaseLoca' do
    claseLoca = Class.new do
      def foo

      end
    end
    origins = Aspects_Origin_Converter
                  .create_origins([claseLoca.new])
                  .map { |s| Aspect_Origin.create_origin(s) }
    expect(origins.first.sym_publicos(false)).to eq([:foo])
  end

  it 'probar ver el metodo foo publico de una instancia' do
    claseLoca = Class.new do
      private
      def bar

      end
    end
    origins = Aspects_Origin_Converter
                  .create_origins([claseLoca.new])
                  .map { |s| Aspect_Origin.create_origin(s) }
    expect(origins.first.sym_privados(false)).to eq([:bar])
  end
end

describe 'Aspect origenes' do

  before(:each) do
    @mi_clase = Class.new do

    end

    @mi_modulo = Module.new do

    end

    @mi_objeto = @mi_clase.new
  end

  it 'chequear parametros pasados' do
    expect(Aspects.on(@mi_clase, @mi_objeto, @mi_modulo) { @origins.map { |o| o.base } }).to eq([@mi_clase, @mi_objeto, @mi_modulo])
  end

  it 'falla por no pasarle un bloque' do
    expect { Aspects.on @mi_clase }.to raise_error(ArgumentError, 'wrong number of arguments (0 for +1)')
  end

  it 'falla por no pasarle orgien' do
    expect { Aspects.on { 'hola' } }.to raise_error(ArgumentError, 'wrong number of arguments (0 for +1)')
  end

  it 'no falla porque encontro algo con esa regexp' do
    Aspects.on(/^Cl.*/) {}
  end

  it 'falla regex de una clase que no existe' do
    expect { Aspects.on(/Saraza/) { [Aspects_Mutagen.new(MiClase, MiClase.instance_method(:class))] } }.to raise_error(ArgumentError, 'origen vacio')
  end
end

describe 'Aspect condiciones' do

  it 'Probamos el where' do
    class KlaseLoca
      def holis

      end
    end
    expect(Aspects.on(KlaseLoca) { where(proc { |metodo| metodo.symbol == :holis }) }.first.metodo).to eq(KlaseLoca.instance_method(:holis))
  end

  it 'Probamos el where-name-is_public' do
    klaseLoca = Class.new do
      def holis

      end

      private
      def holis2

      end
    end
    expect(Aspects.on(klaseLoca) { where name(/holis/), is_public }.first.metodo).to eq(klaseLoca.instance_method(:holis))
  end

  it 'Probamos el where-is_private' do
    klaseLoca = Class.new do
      def holis

      end

      private
      def holis2

      end
    end
    expect(Aspects.on(klaseLoca) { where name(/holis/), is_private }.first.metodo).to eq(klaseLoca.instance_method(:holis2))
  end

  it 'Probamos el where-neg' do
    klaseLoca = Class.new do
      def holis

      end

      private
      def holis2

      end
    end
    expect(Aspects.on(klaseLoca) { where name(/holis/), neg(is_private) }.first.metodo).to eq(klaseLoca.instance_method(:holis))
  end

  it 'Probamos el where-has_parameters' do
    klaseLoca = Class.new do
      def pepita(param1, param2, param3, param4 = 3, param5 = 1, param6)
        param1 + param2 + param3 + param4 + param5 + param6
      end

      def pepita2(param1, param2 = 2, param3 = 3, param4 = 4, param5 = 3)
        param1 + param2 + param3 + param4 + param5

      end

      def pepita3(nananananannabatman)
        nananananannabatman
      end
    end
    expect(
        Aspects.on(klaseLoca) do
          where has_parameters(6)
        end.first.metodo).to eq(klaseLoca.instance_method(:pepita))
    expect(
        Aspects.on(klaseLoca) do
          where has_parameters(4, optional)
        end.first.metodo).to eq(klaseLoca.instance_method(:pepita2))
    expect(
        Aspects.on(klaseLoca) do
          where has_parameters(4, mandatory)
        end.first.metodo).to eq(klaseLoca.instance_method(:pepita))
    expect(
        Aspects.on(klaseLoca) do
          where has_parameters(1, /nananananannabatman/)
        end.first.metodo).to eq(klaseLoca.instance_method(:pepita3))
    expect(
        Aspects.on(klaseLoca) do
          where has_parameters(1, /^nana.*/)
        end.first.metodo).to eq(klaseLoca.instance_method(:pepita3))
  end
end

describe 'Aspect transformaciones con redirec_to' do
  it 'probar transformacion redirect_to instancia a instancia/instanciaS' do
    clase_transformaciones = Class.new do
      def hace_algo(p1, p2)
        p1 + '-' + p2
      end
    end
    tarola = Class.new do
      def hace_algo(p1, p2)
      end
    end

    a = tarola.new
    b = tarola.new

    Aspects.on(a) do
      transform(where name(/hace_algo/)) do
        redirect_to(clase_transformaciones.new)
      end
    end
    expect(a.hace_algo('hola', 'tarola')).to eq('hola-tarola')
    expect(b.hace_algo('hola', 'tarola')).to eq(nil)
  end
end
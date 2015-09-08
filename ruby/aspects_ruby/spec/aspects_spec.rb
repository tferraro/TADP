require 'rspec'
require_relative '../src/aspects'

describe 'Aspect transformaciones' do
  it 'probar transformacion base' do
    class MiClase
      def self.hace_algo(p1, p2)
        p1 + '-' + p2
      end

      def self.hace_otra_cosa(p2, ppp)
        p2 + ':' + ppp
      end
    end
    expect(
        Aspects.on(/^Mi.*/) do
          transform(where has_parameters(1, /p2/)) do
            inject(p2: 'bar')
          end
        end).to eq('Me pasaste MiClase y [:hace_algo, :hace_otra_cosa]')
  end

end


describe 'Aspect condiciones' do

  before(:all) do
    class MiClase

    end
    module MiModulo

    end
  end

  it 'probar condiciones de visibilidad is_public y name' do
    class MiClase
      def self.bar
      end

      def self.foo
      end
    end
    module MiModulo
      def self.bario
      end
    end
    expect(
        Aspects.on(MiClase, MiModulo) do
          where name(/bar/), is_public
        end).to eq('Me pasaste MiClase, MiModulo y [:bar, :bario]')
    expect(
        Aspects.on(/^Mi.*/) do
          where name(/bar/), is_public

        end).to eq('Me pasaste MiClase, MiModulo y [:bar, :bario]')
  end

  it 'probamos el filtro de privados' do
    class MiClase
      def self.bar
      end

      def self.foo
      end

      private_class_method :foo
    end
    expect(
        Aspects.on(MiClase) do
          where name(/foo/), is_private

        end).to eq('Me pasaste MiClase y [:foo]')
  end

  it 'probamos que no matchee nada' do
    class MiClase
      def self.bar
      end
    end
    expect(
        Aspects.on(MiClase) do
          where name(/metodo_inexitente/), is_private

        end).to eq('Me pasaste MiClase y []')
  end

  it 'probar condiciones de visibilidad is_public sin name' do
    expect(
        Aspects.on(MiClase) do
          where is_public

        end).to eq("Me pasaste MiClase y #{MiClase.public_methods}")

  end

  it 'probar si tiene parametros determinados' do
    class MiClase
      def self.pepita(param1, param2, param3, param4 = 3, param5 = 1, param6)
        param1 + param2 + param3 + param4 + param5 + param6
      end

      def self.pepita2(param1, param2 = 2, param3 = 3, param4 = 4, param5 = 3)
        param1 + param2 + param3 + param4 + param5

      end

      def self.pepita3(nananananannabatman)
        nananananannabatman
      end
    end
    expect(
        Aspects.on(MiClase) do
          where has_parameters(6)
        end).to eq('Me pasaste MiClase y [:pepita]')
    expect(
        Aspects.on(MiClase) do
          where has_parameters(4, opcional)
        end).to eq('Me pasaste MiClase y [:pepita2]')
    expect(
        Aspects.on(MiClase) do
          where has_parameters(4, requerido)
        end).to eq('Me pasaste MiClase y [:pepita]')
    expect(
        Aspects.on(MiClase) do
          where has_parameters(1, /nananananannabatman/)
        end).to eq('Me pasaste MiClase y [:pepita3]')
    expect(
        Aspects.on(MiClase) do
          where has_parameters(1, /^nana.*/)
        end).to eq('Me pasaste MiClase y [:pepita3]')
  end

  it 'probar la negacion de has_parameters' do

    class MiClase
      def self.pepita(param1, param2, param3, param4 = 3, param5 = 1, param6)
        param1 + param2 + param3 + param4 + param5 + param6
      end

      def self.pepita25

      end
    end

    expect(
        Aspects.on(MiClase) do
          where neg(has_parameters(6))
        end).to eq("Me pasaste MiClase y #{MiClase.all_methods - [:pepita]}")

    expect(
        Aspects.on(MiClase) do
          where neg(has_parameters(6)), name(/pepita/)
        end).to eq("Me pasaste MiClase y #{Aspects.name(/pepita/) - [:pepita]}")
  end

  it 'probar la negacion de name' do
    class MiClase
      def self.bar
      end

      def self.foo
      end
    end
    module MiModulo
      def self.bario
      end
    end
    expect(
        Aspects.on(MiClase, MiModulo) do
          where neg(name(/bar/))
        end).to eq("Me pasaste MiClase, MiModulo y #{Aspects.name(/.*/) - [:bar, :bario]}")
  end

  it 'probar la negacion de is_public' do
    expect(
        Aspects.on(MiClase) do
          where neg(is_public)
        end).to eq("Me pasaste MiClase y #{MiClase.private_methods}")
  end

  it 'probar la negacion de is_private' do
    expect(
        Aspects.on(MiClase) do
          where neg(is_private)
        end).to eq("Me pasaste MiClase y #{MiClase.public_methods}")
  end
end


describe 'Aspect origenes' do

  it 'chequear parametros pasados' do
    mi_objeto = MiClase.new
    expect(Aspects.on(MiClase, mi_objeto, MiModulo) { :class }).to eq("Me pasaste MiClase, #{mi_objeto}, MiModulo y class")
  end

  it 'falla por no pasarle un bloque' do
    expect { Aspects.on MiClase }.to raise_error(ArgumentError, 'wrong number of arguments (0 for +1)')
  end

  it 'falla por no pasarle orgien' do
    expect { Aspects.on { 'hola' } }.to raise_error(ArgumentError, 'origen vacio')
  end

  it 'acepta regex de una clase que existe' do
    expect(Aspects.on(/MiClase/) { :class }).to eq ('Me pasaste MiClase y class')
  end

  it 'falla regex de una clase que no existe' do
    expect { Aspects.on(/Saraza/) { :class } }.to raise_error(ArgumentError, 'origen vacio')
  end

  it 'acepta regex parcial de una clase que existe' do
    expect(Aspects.on(/^Mi.*/) { :class }).to eq ('Me pasaste MiClase, MiModulo y class')
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
    expect(Module._get_class_symbol_by_regex(/Class/)).to eq([:Class, :NilClass, :TrueClass, :FalseClass])
  end

  it 'obtener ningun simbolo porque no matcheo la regex' do
    expect(Module._get_class_symbol_by_regex(/Saraza/)).to eq([])
  end
end
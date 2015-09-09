require 'rspec'
require_relative '../src/aspects'

describe 'Aspect transformaciones con ...' do
  it 'probar transformacion ....' do
    class Clase_Transformaciones
      def hace_algo2(p1, p2)
        p1 + '-' + p2
      end
    end

    Aspects.on(Clase_Transformaciones) do
      transform(where name(/hace_algo2/)) do
        inject(p2: 'bar')
      end
    end
    expect(Clase_Transformaciones.new.hace_algo2('hola', 'tarola')).to eq('hola-bar')
  end

  it 'probar transformacion ....' do
    class Clase_Transformaciones
      def hace_algo2(p1, p2)
        p1 + '-' + p2
      end
    end

    Aspects.on(Clase_Transformaciones) do
      transform(where name(/hace_algo2/)) do
        inject(p2: proc { |_, mensaje, arg_anterior|
                 "bar(#{mensaje}->#{arg_anterior})"
               })
      end
    end
    expect(Clase_Transformaciones.new.hace_algo2('foo', 'foo')).to eq('foo-bar(hace_algo2->foo)')
  end
end

describe 'Aspect transformaciones con redirec_to' do
  it 'probar transformacion redirect_to instancia a instancia/instanciaS' do
    class Clase_Transformaciones
      def hace_algo(p1, p2)
        p1 + '-' + p2
      end
    end
    class Tarola
    end

    a = Tarola.new
    b = Tarola.new

    Aspects.on(Clase_Transformaciones.new) do
      transform(where name(/hace_algo/)) do
        redirect_to(a)
      end
    end
    expect(a.hace_algo('hola', 'tarola')).to eq('hola-tarola')
    begin
      b.hace_algo('hola', 'tarola')
      fail 'no exception raised'
    rescue NoMethodError
      'Funco!'
    end
  end

  it 'probar transformacion redirect_to instanciaS a instancia' do
    a = Tarola.new
    b = Tarola.new

    Aspects.on(Clase_Transformaciones) do
      transform(where name(/hace_algo/)) do
        redirect_to(a)
      end
    end
    expect(a.hace_algo('hola', 'tarola')).to eq('hola-tarola')
    begin
      b.hace_algo('hola', 'tarola')
      fail 'no exception raised'
    rescue NoMethodError
      'Funco!'
    end
  end

  it 'probar transformacion redirect_to instanciaS a instanciaS' do

    Aspects.on(Clase_Transformaciones) do
      transform(where name(/hace_algo/)) do
        redirect_to(Tarola)
      end
    end
    #expect(Tarola.hace_algo('hola', 'tarola')).to eq('hola-tarola')
    expect(Tarola.new.hace_algo('hola', 'tarola')).to eq('hola-tarola')
  end
end


describe 'Aspect condiciones' do

  before(:all) do
    class MiClase

    end
    module MiModulo

    end
    # Estos metodos no impota lo que haga, si hago el mismo algoritmo adentro de Aspect::Aspect_Converter no aparecen, pero lo hago aca y saltan siempre. CON EL MISMO CODIGO
    @array_loco = [:is_a?, :enum_for, :==, :equal?, :__send__, :__id__, :initialize_clone, :format, :fail, :block_given?, :gem_original_require, :singleton_method_removed, :singleton_method_undefined]
    #@aray_loco << :fork
  end

  it 'probar condiciones de visibilidad is_public y name' do
    class MiClase
      def bar
      end

      def foo
      end
    end
    module MiModulo
      def bario
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
      def bar
      end

      private
      def foo
      end
    end
    expect(
        Aspects.on(MiClase) do
          where name(/foo/), is_private

        end).to eq('Me pasaste MiClase y [:foo]')
  end

  it 'probamos que no matchee nada' do
    class MiClase
      def bar
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

        end).to eq("Me pasaste MiClase y #{MiClase.public_instance_methods - @array_loco}")
  end

  it 'probar si tiene parametros determinados' do
    class MiClase
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
      def pepita(param1, param2, param3, param4 = 3, param5 = 1, param6)
        param1 + param2 + param3 + param4 + param5 + param6
      end

      def pepita25

      end
    end

    expect(
        Aspects.on(MiClase) do
          where neg(has_parameters(6))
        end).to eq("Me pasaste MiClase y #{ MiClase.private_instance_methods(true) + MiClase.public_instance_methods(true) - [:pepita] - @array_loco}")
  end

  it 'probar name y public con un objeto' do
    class A
      def holis
        'holis'
      end
    end
    a = A.new

    def a.holas(param1, param2)
      'holas'
    end

    expect(
        Aspects.on(a) do
          where name(/hol/), is_public
        end).to eq("Me pasaste #{a} y [:holas, :holis]")

    expect(
        Aspects.on(a) do
          where name(/hol/), is_public, has_parameters(2)
        end).to eq("Me pasaste #{a} y [:holas]")
  end

  it 'probar la negacion de name' do
    class MiClase
      def bar
      end

      def foo
      end
    end
    module MiModulo
      def bario
      end
    end
    expected_methods = MiClase.private_instance_methods(true) + MiClase.public_instance_methods(true)
    expected_methods += MiModulo.private_instance_methods(true) + MiModulo.public_instance_methods(true)
    expect(
        Aspects.on(MiClase, MiModulo) do
          where neg(name(/bar/))
        end).to eq("Me pasaste MiClase, MiModulo y #{expected_methods - [:bar, :bario] - @array_loco}")
  end

  it 'probar la negacion de is_public' do
    class Two
      def holis

      end

      private
      def holas

      end

    end
    expect(
        Aspects.on(Two) do
          where neg(is_public)
        end).to eq("Me pasaste Two y #{Two.private_instance_methods - @array_loco}")
  end

  it 'probar la negacion de is_private' do
    expect(
        Aspects.on(Two) do
          where neg(is_private)
        end).to eq("Me pasaste Two y #{Two.public_instance_methods - @array_loco}")
  end
end


describe 'Aspect origenes' do

  it 'chequear parametros pasados' do
    mi_objeto = MiClase.new
    expect(Aspects.on(MiClase, mi_objeto, MiModulo) { [MiClase.instance_method(:class)] }).to eq("Me pasaste MiClase, #{mi_objeto}, MiModulo y [:class]")
  end

  it 'falla por no pasarle un bloque' do
    expect { Aspects.on MiClase }.to raise_error(ArgumentError, 'wrong number of arguments (0 for +1)')
  end

  it 'falla por no pasarle orgien' do
    expect { Aspects.on { 'hola' } }.to raise_error(ArgumentError, 'origen vacio')
  end

  it 'acepta regex de una clase que existe' do
    expect(Aspects.on(/MiClase/) { [MiClase.instance_method(:class)] }).to eq ('Me pasaste MiClase y [:class]')
  end

  it 'falla regex de una clase que no existe' do
    expect { Aspects.on(/Saraza/) { [MiClase.instance_method(:class)] } }.to raise_error(ArgumentError, 'origen vacio')
  end

  it 'acepta regex parcial de una clase que existe' do
    expect(Aspects.on(/^Mi.*/) { [MiClase.instance_method(:class)] }).to eq ('Me pasaste MiClase, MiModulo y [:class]')
  end
end


describe 'Aspect parseo de regex y demaces' do

  it 'obtener origen de varias regex' do
    expect(Aspects.send(:_get_origin_by_multiple_regex, ([/Class/, /Object/]))).to eq([Class, NilClass, TrueClass, FalseClass, Object, BasicObject, ObjectSpace])
  end
  it 'obtener nada con regex que no matchea' do
    expect(Aspects.send(:_get_origin_by_multiple_regex, ([/CACA/]))).to eq([])
  end

  it 'obtener origen de varias regex repetidas' do
    expect(Aspects.send(:_get_origin_by_multiple_regex, ([/Class/, /Class/]))).to eq([Class, NilClass, TrueClass, FalseClass])
  end

  it 'obtener origen de una regex' do
    expect(Aspects.send(:_get_origin_by_regex, (/Class/))).to eq([Class, NilClass, TrueClass, FalseClass])
  end

  it 'obtener origen de una regex' do
    expect(Aspects.send(:_get_origin_by_regex, (/Class/))).to eq([Class, NilClass, TrueClass, FalseClass])
  end

  it 'obtener simbolos de una regex' do
    expect(Aspects.send(:_get_class_symbol_by_regex, (/Class/))).to eq([:Class, :NilClass, :TrueClass, :FalseClass])
  end

  it 'obtener ningun simbolo porque no matcheo la regex' do
    expect(Aspects.send(:_get_class_symbol_by_regex, (/Saraza/))).to eq([])
  end
end
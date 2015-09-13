require 'rspec'
require_relative '../src/aspects'

describe 'Aspect transformaciones con before, after e instead_of' do

  it 'probar before en UNA instancia' do
    clase_Transformaciones = Class.new do
      def hace_algo_x(p2)
        p2
      end
    end
    trans = clase_Transformaciones.new
    Aspects.on(trans) do
      transform(where name(/hace_algo_x/)) do
        before do |_, _, *args|
          args[0] += '!'
        end
      end
    end
    expect(trans.hace_algo_x('hola')).to eq('hola!')
    expect(clase_Transformaciones.new.hace_algo_x('hola')).to eq('hola')
  end

  it 'probar before en todas las instancias' do
    class Clase_Transformaciones
      def hace_algo_x(p2)
        p2
      end
    end
    Aspects.on(Clase_Transformaciones) do
      transform(where name(/hace_algo_x/)) do
        before do |_, _, *args|
          args[0] += '!'
        end
      end
    end
    expect(Clase_Transformaciones.new.hace_algo_x('hola')).to eq('hola!')
  end

  it 'probar after en todas las instancias' do
    class Clase_Transformaciones
      def hace_algo_x(p2)
        p2
      end
    end
    Aspects.on(Clase_Transformaciones) do
      transform(where name(/hace_algo_x/)) do
        after do |_, *args|
          "Agregue algo mas a: #{args[0]}"
        end
      end
    end
    expect(Clase_Transformaciones.new.hace_algo_x('hola')).to eq('Agregue algo mas a: hola')
  end

  it 'probar after en UNa instancia' do
    class Clase_Transformaciones
      def hace_algo_x(p2)
        p2
      end
    end
    trans = Clase_Transformaciones.new
    Aspects.on(trans) do
      transform(where name(/hace_algo_x/)) do
        after do |_, *args|
          "Agregue algo mas a: #{args[0]}"
        end
      end
    end
    expect(trans.hace_algo_x('hola')).to eq('Agregue algo mas a: hola')
    expect(Clase_Transformaciones.new.hace_algo_x('hola')).to eq('hola')
  end

  it 'probar instead_of en UNA instancia' do
    class Clase_Transformaciones
      def hace_algo_x(p2)
        p2
      end
    end
    trans = Clase_Transformaciones.new
    Aspects.on(trans) do
      transform(where name(/hace_algo_x/)) do
        instead_of do |_, _|
          123
        end
      end
    end
    expect(trans.hace_algo_x('hola')).to eq(123)
    expect(Clase_Transformaciones.new.hace_algo_x('hola')).to eq('hola')
  end

  it 'probar instead_of en todas las instancias' do
    class Clase_Transformaciones
      def hace_algo_x(p2)
        p2
      end
    end
    Aspects.on(Clase_Transformaciones) do
      transform(where name(/hace_algo_x/)) do
        instead_of do |_, _|
          123
        end
      end
    end
    expect(Clase_Transformaciones.new.hace_algo_x('hola')).to eq(123)
  end
end

describe 'Aspect transformaciones con inject' do
  it 'probar transformacion inject con reemplazo simple en todas las instancias' do
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

  it 'probar transformacion inject con reemplazo simple en UNA instancia' do
    class Clase_Transformaciones
      def hace_algo2(p1, p2)
        p1 + '-' + p2
      end
    end
    trans = Clase_Transformaciones.new
    Aspects.on(trans) do
      transform(where name(/hace_algo2/)) do
        inject(p2: 'bar')
      end
    end
    expect(trans.hace_algo2('hola', 'tarola')).to eq('hola-bar')
    expect(Clase_Transformaciones.new.hace_algo2('foo', 'foo')).to eq('foo-foo')
  end

  it 'probar transformacion inject con reemplazo proc en todas las instancias' do
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

  it 'probar transformacion inject con reemplazo proc en UNA instancia' do
    class Clase_Transformaciones
      def hace_algo2(p1, p2)
        p1 + '-' + p2
      end
    end
    trans = Clase_Transformaciones.new
    Aspects.on(trans) do
      transform(where name(/hace_algo2/)) do
        inject(p2: proc { |_, mensaje, arg_anterior|
                 "bar(#{mensaje}->#{arg_anterior})"
               })
      end
    end
    expect(trans.hace_algo2('foo', 'foo')).to eq('foo-bar(hace_algo2->foo)')
    expect(Clase_Transformaciones.new.hace_algo2('foo', 'foo')).to eq('foo-foo')
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
      def hace_algo(p1, p2)

      end
    end

    a = Tarola.new
    b = Tarola.new

    Aspects.on(a) do
      transform(where name(/hace_algo/)) do
        redirect_to(Clase_Transformaciones.new)
      end
    end
    expect(a.hace_algo('hola', 'tarola')).to eq('hola-tarola')
    expect(b.hace_algo('hola', 'tarola')).to eq(nil)
  end

  it 'probar transformacion redirect_to instanciaS a instancia' do
    a = Tarola.new
    b = Tarola.new


    Aspects.on(a) do
      transform(where name(/hace_algo/)) do
        redirect_to(Clase_Transformaciones)
      end
    end
    expect(a.hace_algo('hola', 'tarola')).to eq('hola-tarola')
    expect(b.hace_algo('hola', 'tarola')).to eq(nil)
  end

  it 'probar transformacion redirect_to instanciaS a instanciaS' do

    Aspects.on(Tarola) do
      transform(where name(/hace_algo/)) do
        redirect_to(Clase_Transformaciones)
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
    #@array_loco << :fork
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
          where has_parameters(4, optional)
        end).to eq('Me pasaste MiClase y [:pepita2]')
    expect(
        Aspects.on(MiClase) do
          where has_parameters(4, mandatory)
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
    class Aaaaa
      def holis
        'holis'
      end
    end
    a = Aaaaa.new

    def a.holas(param1, param2)
      "holas #{param1} #{param2}"
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
    class M2iClase
      def bar
      end

      def foo
      end
    end
    module M2iModulo
      def bario
      end
    end
    expected_methods = M2iClase.private_instance_methods(true) + M2iClase.public_instance_methods(true)
    expected_methods += M2iModulo.private_instance_methods(true) + M2iModulo.public_instance_methods(true)
    expect(
        Aspects.on(M2iClase, M2iModulo) do
          where neg(name(/bar/))
        end).to eq("Me pasaste M2iClase, M2iModulo y #{expected_methods - [:bar, :bario] - @array_loco}")
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
    expect(Aspects.on(MiClase, mi_objeto, MiModulo) { [Aspects_Mutagen.new(MiClase, MiClase.instance_method(:class))] }).to eq("Me pasaste MiClase, #{mi_objeto}, MiModulo y [:class]")
  end

  it 'falla por no pasarle un bloque' do
    expect { Aspects.on MiClase }.to raise_error(ArgumentError, 'wrong number of arguments (0 for +1)')
  end

  it 'falla por no pasarle orgien' do
    expect { Aspects.on { 'hola' } }.to raise_error(ArgumentError, 'wrong number of arguments (0 for +1)')
  end

  it 'acepta regex de una clase que existe' do
    expect(Aspects.on(/MiClase/) { [Aspects_Mutagen.new(MiClase, MiClase.instance_method(:class))] }).to eq ('Me pasaste MiClase y [:class]')
  end

  it 'falla regex de una clase que no existe' do
    expect { Aspects.on(/Saraza/) { [Aspects_Mutagen.new(MiClase, MiClase.instance_method(:class))] } }.to raise_error(ArgumentError, 'origen vacio')
  end

  it 'acepta regex parcial de una clase que existe' do
    expect(Aspects.on(/^Mi.*/) { [Aspects_Mutagen.new(MiClase, MiClase.instance_method(:class))] }).to eq ('Me pasaste MiClase, MiModulo y [:class]')
  end
end
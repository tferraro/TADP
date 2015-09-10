require 'rspec'
require_relative '../src/aspects'

describe 'Tests sobre Origenes' do

  it 'origines validos' do
    class MiClase

    end
    module MiModulo

    end
    mi_objeto = MiClase.new

    Aspects.on MiClase do
      # Definicion de aspectos para las instancias de MiClase
    end
    Aspects.on mi_objeto do
      # Definicion de aspectos para mi_objeto
    end
    Aspects.on MiModulo do
      # Definicion de aspectos para las instancias de MiModulo
    end
    Aspects.on MiClase, MiModulo do
      # Definicion de aspectos para las instancias de MiClase o MiModulo
    end
  end

  it 'origines validos con regexp' do
    Aspects.on MiClase, /^Foo.*/, /.*bar/ do
      # Definicion de aspectos para las instancias de MiClase y cualquier clase o
      # modulo que empieze con Foo o termine con bar
    end
  end

  it 'sin origenes y lanza error' do
    expect do
      Aspects.on do
        # ...
      end
    end.to raise_error(ArgumentError, 'wrong number of arguments (0 for +1)')
  end

  it 'origenes inexistentes y lanza error' do
    expect do
      Aspects.on /NombreDeClaseQueNoExiste/ do
        # ...
      end
    end.to raise_error(ArgumentError, 'origen vacio')
  end

  it 'un origen existente y el resto basura' do
    Aspects.on /NombreDeClaseQueNoExiste/, MiClase do
      # ...
    end
  end
end

describe 'Tests sobre Condiciones' do

  it 'condicion selector' do
    class MiClase
      def foo
      end

      def bar
      end
    end
    expect(Aspects.on(MiClase) {
             where name(/fo{2}/)
             # array con el metodo foo
           }).to eq ("Me pasaste #{MiClase} y #{[:foo]}")
    expect(Aspects.on(MiClase) {
             where name(/fo{2}/), name(/foo/)
             # array con el metodo foo matcheando ambas regex
           }).to eq ("Me pasaste #{MiClase} y #{[:foo]}")
    expect(Aspects.on(MiClase) {
             where name(/^fi+/)
             # array vacio, ninguno matchea
           }).to eq ("Me pasaste #{MiClase} y #{[]}")
    expect(Aspects.on(MiClase) {
             where name(/foo/), name(/bar/)
             # array vacio, ninguno matchea ambas regex
           }).to eq ("Me pasaste #{MiClase} y #{[]}")
  end

  it 'condicion visibilidad' do
    class MiClase
      def foo
      end

      private
      def bar
      end
    end
    expect(Aspects.on(MiClase) {
             where name(/bar/), is_private
             # array con el metodo bar
           }).to eq ("Me pasaste #{MiClase} y #{[:bar]}")
    expect(Aspects.on(MiClase) {
             where name(/bar/), is_public
             # array vacio
           }).to eq ("Me pasaste #{MiClase} y #{[]}")
  end

  it 'condicion cantidad de parametros' do
    class MiClase
      def foo(p1, p2, p3, p4='a', p5='b', p6='c')
      end

      def bar(p1, p2='a', p3='b', p4='c')
      end
    end
    expect(Aspects.on(MiClase) {
             where has_parameters(3, mandatory)
             # array con el metodo foo
           }).to eq ("Me pasaste #{MiClase} y #{[:foo]}")
    expect(Aspects.on(MiClase) {
             where has_parameters(6)
             # array con el metodo foo
           }).to eq ("Me pasaste #{MiClase} y #{[:foo]}")
    expect(Aspects.on(MiClase) {
             where has_parameters(3, optional)
             # array con el metodo foo y bar
           }).to eq ("Me pasaste #{MiClase} y #{[:foo, :bar]}")

  end

  it 'condicion nombre de parametros' do
    class MiClase
      def foo(param1, param2)
      end

      def bar(param1)
      end
    end
    expect(Aspects.on(MiClase) {
             where has_parameters(1, /param.*/)
             # array con el metodo bar
           }).to eq ("Me pasaste #{MiClase} y #{[:bar]}")
    expect(Aspects.on(MiClase) {
             where has_parameters(2, /param.*/)
             # array con el metodo foo
           }).to eq ("Me pasaste #{MiClase} y #{[:foo]}")
    expect(Aspects.on(MiClase) {
             where has_parameters(3, /param.*/)
             # array con el metodo foo
           }).to eq ("Me pasaste #{MiClase} y #{[]}")
  end

  it 'condicion negacion' do
    class MiClase
      def foo1(p1)
      end

      def foo2(p1, p2)
      end

      def foo3(p1, p2, p3)
      end
    end
    expect(Aspects.on(MiClase) {
             where name(/foo\d/), neg(has_parameters(1))
             # array con los metodos foo2 y foo3
           }).to eq ("Me pasaste #{MiClase} y #{[:foo2, :foo3]}")
  end
end

describe 'Tests sobre Transformaciones' do

  it 'Inyeccion de parametro' do
    class MiClase
      def hace_algo(p1, p2)
        p1 + '-' + p2
      end

      def hace_otra_cosa(p2, ppp)
        p2 + ':' + ppp
      end
    end

    Aspects.on MiClase do
      transform(where has_parameters(1, /p2/)) do
        inject(p2: 'bar')
      end
    end

    instancia = MiClase.new
    expect(instancia.hace_algo('foo')).to eq('foo-bar')
    expect(instancia.hace_algo('foo', 'foo')).to eq('foo-bar')
    expect(instancia.hace_otra_cosa('foo', 'foo')).to eq('bar:foo')
  end

  it 'Inyeccion de parametro con Proc' do
    class MiClase
      def hace_algo(p1, p2)
        p1 + '-' + p2
      end
    end

    Aspects.on MiClase do
      transform(where has_parameters(1, /p2/)) do
        inject(p2: proc { |receptor, mensaje, arg_anterior|
                 "bar(#{mensaje}->#{arg_anterior})"
               })
      end
    end
    expect(MiClase.new.hace_algo('foo', 'foo')).to eq('foo-bar(hace_algo->foo)')
  end

end
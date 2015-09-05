require 'rspec'
require_relative '../src/aspects'

describe 'Aspect condiciones' do

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
        Aspects.on(MiClase, MiModulo) do |hey|
          where name(/bar/), is_public, hey

        end).to eq('Me pasaste MiClase, MiModulo y [:bar, :bario]')
    expect(
        Aspects.on(/^Mi.*/) do |hey|
          where name(/bar/), is_public, hey

        end).to eq('Me pasaste MiClase, MiModulo y [:bar, :bario]')
  end

  it 'prueba' do
    class MiClase
      def bar
      end

      private def foo
      end
    end
    miObjetito = MiClase.new
    expect(
        Aspects.on(miObjetito) do |hey|
          where name(/foo/), is_private, hey

        end).to eq("Me pasaste #{miObjetito} y [:foo]")
  end
  it ' pruba2' do
    expect(
        Aspects.on(MiClase) do |hey|
          where is_public, hey

        end).to eq('Me pasaste MiClase y [:bar, :foo, :allocate, :new, :superclass, :any_instance, :freeze, :===, :==, :<=>, :<, :<=, :>, :>=, :to_s, :inspect, :included_modules, :include?, :name, :ancestors, :instance_methods, :public_instance_methods, :protected_instance_methods, :private_instance_methods, :constants, :const_get, :const_set, :const_defined?, :const_missing, :class_variables, :remove_class_variable, :class_variable_get, :class_variable_set, :class_variable_defined?, :public_constant, :private_constant, :singleton_class?, :include, :prepend, :module_exec, :class_exec, :module_eval, :class_eval, :method_defined?, :public_method_defined?, :private_method_defined?, :protected_method_defined?, :public_class_method, :private_class_method, :autoload, :autoload?, :instance_method, :public_instance_method, :example_group, :describe, :context, :xdescribe, :xcontext, :fdescribe, :fcontext, :shared_examples, :shared_context, :shared_examples_for, :_get_symbol_by_regex, :get_origin_by_regex, :get_origin_by_multiple_regex, :where, :is_private, :is_public, :nil?, :=~, :!~, :eql?, :hash, :class, :singleton_class, :clone, :dup, :taint, :tainted?, :untaint, :untrust, :untrusted?, :trust, :frozen?, :methods, :singleton_methods, :protected_methods, :private_methods, :public_methods, :instance_variables, :instance_variable_get, :instance_variable_set, :instance_variable_defined?, :remove_instance_variable, :instance_of?, :kind_of?, :is_a?, :tap, :send, :public_send, :respond_to?, :extend, :display, :method, :public_method, :singleton_method, :define_singleton_method, :object_id, :to_enum, :enum_for, :gem, :equal?, :!, :!=, :instance_eval, :instance_exec, :__send__, :__id__, :should_receive, :should_not_receive, :stub, :unstub, :stub_chain, :as_null_object, :null_object?, :received_message?, :should, :should_not]')

  end
end


describe 'Aspect origenes' do

  before(:all) do
    class MiClase

    end
    module MiModulo

    end
  end

  it 'chequear parametros pasados' do
    miObjeto = MiClase.new
    expect(Aspects.on(MiClase, miObjeto, MiModulo) { 'hola!' }).to eq("Me pasaste MiClase, #{miObjeto}, MiModulo y hola!")
  end

  it 'falla por no pasarle un bloque' do
    expect { Aspects.on MiClase }.to raise_error(ArgumentError, 'wrong number of arguments (0 for +1)')
  end

  it 'falla por no pasarle orgien' do
    expect { Aspects.on { 'hola' } }.to raise_error(ArgumentError, 'origen vacio')
  end

  it 'acepta regex de una clase que existe' do
    expect(Aspects.on(/MiClase/) { 'hola' }).to eq ('Me pasaste MiClase y hola')
  end

  it 'falla regex de una clase que no existe' do
    expect { Aspects.on(/Saraza/) { 'hola' } }.to raise_error(ArgumentError, 'origen vacio')
  end

  it 'acepta regex parcial de una clase que existe' do
    expect(Aspects.on(/^Mi.*/) { 'hola' }).to eq ('Me pasaste MiClase, MiModulo y hola')
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

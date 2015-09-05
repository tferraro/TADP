#Temas
#	self-modification
#	introspection


class Metabuilder

	attr_accessor :klass, :properties, :validations

	def initialize
		@properties = []
	end

	def set_class(klass)
		@klass = klass
		@properties = []
		@validations = []
	end

	def create_class(sym, &accesors)
		klass = Class.new
		Object.const_set sym, klass
		klass.instance_eval &validation	
		set_class klass
	end

	def set_propieties(*args)
		@properties += args
	end

	def validate(&block)
		#Append - Esta agregando otra validacion mas
		@validations << block
	end

	def build
		Builder.new @klass, @properties, @validations
	end
end

class Builder

	attr_reader :properties, :validations

	def initialize(klass, properties, validations)
		@klass = klass
		@properties = {}
		@validations = validations
		#Crea una tabla de hash
		properties.each do |property|
			@properties[property] = nil #Le meto la key y seteo el valor con nil
			#self.singleton_class.send :attr_accessor, property
			send :define_singleton_method, "#{property}=" do |value| 
			#Se lo manda al singleton porque ejecuta initialize el objeto
				set_property property, value
			end
		end
	end

	def set_property(sym, value)
		@properties[sym] = value
	end

	def method_missing(symbol, *args)
		#Para sacar el = al final :P
		property_symbol = symbol.to_s[0..-2].to_sym

		super unless @properties.has_key? property_symbol
		set_property property_symbol, args[0] 
	end

	def build
		instancia = @klass.new
		@properties.each do |property, value| 
			instancia.send "#{property}=".to_sym, value
		end
		raise ValidationError unless @validations.all? do |validation|
			#validation.bind(instancia).call <- Da el comportamiento asociado al target y le pido que se ejecute
			instancia.instance_eval &validation #<- Agarro un comportamiento y le digo a la instanciay  le pido que lo ejecute
		end
		instancia
	end
end

class Perro

	attr_accessor :raza, :edad, :duenio

	def initialize
		@duenio = 'Cesar Millan'
	end
end

# MetaBuilder -> Builder -> Perro :D
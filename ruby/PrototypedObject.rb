class Object
	def clone_object
		PrototypedObject.new self #Podemos usar CUALQUIER OBJETO, como prototipo gorda!
	end
end

class PrototypedObject
	attr_accessor :protoptype

	def initialize(protoptype= Object.new)
		self.protoptype = protoptype
	end

	def set_property(sym, value)
		self.singleton_class.send :attr_accessor, sym
		self.send "#{sym}=", value
	end

	def set_method(sym, behavour)
		self.define_singleton_method sym, behavour
	end

	def respond_to?(sym)
		super or self.protoptype.respond_to? sym
	end

	def method
		begin
			super 
		rescue NameError
			self.protoptype.method sym
		end
	end

	def method_missing(sym, *args)
		super unless respond_to? sym #Ya me asegure que alguien tiene el metodo
		
		metodo = self.protoptype.method(sym).unbind
		metodo.bind(self).call *args #Esto no funca, porque como es un metodo de otra autoclass, ruby te rompe todo, por ruby no por la idea.
	end
end
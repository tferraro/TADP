Clase 10/10/15

¿Porque chequear tipos?
	Chequeo de la correctitud de la programacion.
	Informacion de la forma del programa, que sirve para IDEs, por ejemplo.
---------------------------------------------------------------------------
Errores en el chequeo
	Errores Tipo 1
	Errores Tipo 2
---------------------
Contratos fuertes vs Contratos débiles
	Fuertes --> En principio, insalvable.
		Tipado Estático -> Me decis que algo tiene una forma, pero si lo queres usar de otra no te deja
			var animal = new Vaca() y animal.ordeñar() (!!)
------------------------------------------------------------			
Sobrecargar mensajes :P
	Si bien se pueden definir varios mensajes a lo funcional para matchear, son mensajes completamente diferentes.
	No es polimorfismo parametrico, no se chequea el objeto que le estas pasando, sino las definiciones de los tipos a la hora de compilar
	Esta definido de forma estática
-----------------------------------
Tipo parametrico	Set[Animal] | Set[Vaca]
-->Casteo!!
	Se hace al momento del compilador, por ende nos "estamos cagando en el tipado :D"
...me canse de escribir
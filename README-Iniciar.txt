Instrucciones de ejecucion:
- Correr el comando . AFINI

Post-instalacion:
- Para verificar la correcta instalacion, se puede volver a correr el comando ./AFINSTAL.sh. 
Si se desea reinstalar es necesario eliminar la carpeta conf/ y volver a correr el comando ./AFINSTAL.sh.
- Una vez descomprimido se puede eliminar el archivo .tar o se puede guardar para re-instalar en caso de problemas 
con el instalador o cualquier otro archivo.

Utilización de funciones:
-Arrancar arg1 arg2
	Objetivo: disparar procesos background por nombre
	Parametros: arg1= funcion a arrancar en BACKGROUND.
		    arg2= opcional: funcion que llamo a Arrancar (si es que graba en Log).
	Ejemplo: Arrancar "AFINI" "AFREC"

-Detener arg1 arg2		
	Objetivo: detener procesos, complementaria al Arrancar
	Parametros: arg1=funcion a detener.
		    arg2=opcional: funcion que llamo a Detener (si es que graba en Log).
	Ejemplo: Detener "AFREC"

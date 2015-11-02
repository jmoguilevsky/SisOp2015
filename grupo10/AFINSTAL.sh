#!/bin/bash
GRUPO=$PWD
CONFDIR=$GRUPO/conf


function log(){ #si no se quiere imprimierlo por pantalla pasar S como segundo argumento
if [ ! "$2" = "S" ]; then
    echo "$1"
fi
if [ -f ./archivos_instalacion/bin/GraLog ]
then
	if [ ! -x ./archivos_instalacion/bin/GraLog ]
	then
		chmod +x ./archivos_instalacion/bin/GraLog
	fi
	./archivos_instalacion/bin/GraLog "AFINSTAL" "$1" "INFO"
fi
}

function logError(){
if [ ! "$2" = "S" ]; then
    echo "$1"
fi
if [ -f ./archivos_instalacion/bin/GraLog ]
then
	if [ ! -x ./archivos_instalacion/bin/GraLog ]
	then
		chmod +x ./archivos_instalacion/bin/GraLog
	fi
	./archivos_instalacion/bin/GraLog "AFINSTAL" "$1" "ERR"
fi
}

############################# PUNTO 1,2,3 ############################# 

function leerConf(){ #lee las variables que se encuentren en el archivo conf y les asigna sus valores
	local archivo="$CONFDIR/AFINSTAL.cnfg"
	local sep='='
	local nombreVar
	local valor
	while read line
	do
		nombreVar=$(echo $line | cut -f1 -d"$sep")
		valor=$(echo $line | cut -f2 -d"$sep")
		eval $nombreVar=\"$valor\"
	done < "$archivo"
}

function existeArchivo(){
	if [ -f "$1" ]
	then
		return 0
	else
		return 1
	fi
}

function mover(){
if [ ! -f "$2" ]
then
    if [ "$3" == "TODOS" ]
    then
        cp -r "$1"/* "$2"
    else
        cp "$1" "$2"
    fi
fi
}

function verificarConf(){
	local completa=true
	local aux
	local j=0
	local faltantes
	############################ CONFDIR #############################
	if [ -d "$CONFDIR" ]; then
		log "Directorio de Configuración: $CONFDIR"
		log "Archivos existentes:"
		if [ -f "$CONFDIR/AFINSTAL.cnfg" ];then
			for i in "$CONFDIR"/*;do
				if existeArchivo "$i"; then		
					log "$i"
				fi
			done
		else
			completa=false
		fi
	else
		completa=false
	fi
	
	############################ BINDIR #############################
	if [ -d "$BINDIR" ]; then
		log "Directorio de Ejecutables: $BINDIR"
		log "Archivos existentes"
		for i in "$GRUPO/archivos_instalacion/bin"/*;do
			aux="$BINDIR/$(quitarRaizDir "$i")"
			if existeArchivo "$aux"; then
				log "$aux"
			else
				completa=false
				faltantes[$j]="$aux"
				j=$((j+1))
			fi
		done
	else
		faltantes[$j]="$BINDIR"
		j=$((j+1))
		completa=false
		for i in "$GRUPO/archivos_instalacion/bin"/*;do
		aux="$BINDIR/$(quitarRaizDir "$i")"
		faltantes[$j]="$aux"
		j=$((j+1))
		done
	fi


	############################ MAEDIR #############################

	if [ -d "$MAEDIR" ]; then
		log "Directorio de Maestros y Tablas: $MAEDIR"
		log "Archivos existentes:"
		for i in "$GRUPO/archivos_instalacion/mae"/*.{mae,tab};do
			aux="$MAEDIR/$(quitarRaizDir "$i")"
			if existeArchivo "$aux"; then
				log "$aux"
			else
				completa=false
				faltantes[$j]="$aux"
				j=$((j+1))
			fi
		done
	else
		completa=false
		faltantes[$j]="$MAEDIR"
		j=$((j+1))
		for i in "$GRUPO/archivos_instalacion/mae"/*.{mae,tab};do
			aux="$MAEDIR/$(quitarRaizDir "$i")"
				faltantes[$j]="$aux"
				j=$((j+1))
		done
	fi

	############################ ACEPDIR #############################

	if [ -d "$ACEPDIR" ]; then
		log "Directorio de Archivos de llamadas Aceptados: $ACEPDIR"
	else
		completa=false
		faltantes[$j]="$ACEPDIR"
		j=$((j+1))
	fi

	############################ PROCDIR  #############################

	if [ -d "$PROCDIR" ]; then
		log "Directorio de Archivos de llamadas Sospechosas: $PROCDIR"
	else
		completa=false
		faltantes[$j]="$PROCDIR"
		j=$((j+1))
	fi

	############################ REPODIR #############################

	if [ -d "$REPODIR" ]; then
		log "Directorio de Archivos de Reportes de llamadas: $REPODIR"
	else
		completa=false
		faltantes[$j]="$REPODIR"
		j=$((j+1))
	fi
	############################ LOGDIR #############################

	if [ -d "$LOGDIR" ]; then
        	log "Directorio de Archivos de Log: $LOGDIR"
                for i in "$LOGDIR"/*;do
			if existeArchivo "$i";then
	                	log "archivo existente: $i"
			fi
                done
        else
                completa=false
		faltantes[$j]="$LOGDIR"
		j=$((j+1))
        fi

	############################ RECHDIR #############################

	if [ -d "$RECHDIR" ]; then
		log "Directorio de Archivos Rechazados: $RECHDIR"
	else
		completa=false
		faltantes[$j]="$RECHDIR"
		j=$((j+1))
	fi

	if [ "$completa" = true ] ; then
		log "Estado de la instalación: COMPLETA"
                log "Proceso de Instalación Finalizado"
		return 0
	else
		log 'Estado de la instalación: INCOMPLETA'
		log 'Componentes faltantes:'
		
		local cant=${#faltantes[@]}
		for (( i=0;i<$cant;i++)); do
    			echo "${faltantes[${i}]}"
		done
		return 1
	fi
	
}

function finalizarConf(){
	if verificarConf;then
                exit 0
	else
		log 'Desea completar la instalación? (Si – No)'
	        while true; do
	                read aux
        	        case $aux in
                	        "Si" ) log "Si" "S"; completarConf; verificarConf;break;;
                        	"No" ) log "No" "S"; finalizarInstalacion; break;;
	                        * ) logError "Debe ingrear Si o No";;
        	        esac
	        done
	fi
}

function completarConf(){
	local aux

	############################ BINDIR #############################
	if [ -d "$BINDIR" ]; then
		for i in "$GRUPO/archivos_instalacion/bin"/*;do
			aux="$BINDIR/$(quitarRaizDir "$i")"
			if ! existeArchivo "$aux"; then
				mover "$i" "$BINDIR"
			fi
		done
	else
		mkdir "$BINDIR"
		mover "$GRUPO/archivos_instalacion/bin" "$BINDIR" "TODOS"
	fi


	############################ MAEDIR #############################

	if [ -d "$MAEDIR" ]; then
		for i in "$GRUPO/archivos_instalacion/mae"/*.{mae,tab};do
			aux="$MAEDIR/$(quitarRaizDir "$i")"
			if ! existeArchivo "$aux"; then
				mover "$i" "$MAEDIR"
			fi
		done
	else
		mkdir "$MAEDIR"
		copiarConExtension "$GRUPO/archivos_instalacion/mae" "mae" "$MAEDIR"
		copiarConExtension "$GRUPO/archivos_instalacion/mae" "tab" "$MAEDIR"
	fi

	############################ ACEPDIR #############################

	if [ ! -d "$ACEPDIR" ]; then
		mkdir "$ACEPDIR"
	fi

	############################ PROCDIR  #############################

	if [ ! -d "$PROCDIR" ]; then
		mkdir "$PROCDIR"
		mkdir "$PROCDIR/proc"
	fi

	############################ REPODIR #############################

	if [ ! -d "$REPODIR" ]; then
		mkdir "$REPODIR"
	fi
	############################ LOGDIR #############################

	if [ ! -d "$LOGDIR" ]; then
                mkdir "$LOGDIR"
        fi

	############################ RECHDIR #############################

	if [ ! -d "$RECHDIR" ]; then
		mkdir "$RECHDIR"
		mkdir "$RECHDIR/llamadas"
	fi

}
############################# PUNTO 4 ############################# 

function verificarPerl()	
{
local perlInstalado=true
local version=$(perl -v)
if [ $? -ne 0 ] ; then	#codigo de retorno != 0
	perlInstalado=false
fi

echo $version | grep [v][5-9] > /dev/null

if [ $? -ne 0 ];then
	perlInstalado=false
fi

if [ "$perlInstalado" = true ] ; then	
	log "Perl Version: $version"
else
	log "Para ejecutar el sistema AFRA-J es necesario contar con Perl 5 o superior."
	log "Efectúe su instalación e inténtelo nuevamente."
	log "Proceso de Instalación Cancelado"
	finalizarInstalacion
fi
}

############################# PUNTO 5 #############################

function mostrarTerminos()
{
	echo '***********************************************************'
	echo '* Proceso de Instalación de "AFRA-J"                      *'
	echo '* Tema J Copyright © Grupo xx - Segundo Cuatrimestre 2015 *'
	echo '***********************************************************'
	log 'A T E N C I O N: Al instalar UD. expresa aceptar los términos y condiciones'
	log 'del "ACUERDO DE LICENCIA DE SOFTWARE" incluido en este paquete.'
	log 'Acepta? Si – No'
	while true; do
		read aux
		case $aux in
			"Si" ) log "Si" "S"; break;;
			"No" ) log "NO" "S"; exit 0; break;;
			* ) logError "Debe ingrear Si o No";;
		esac
	done
}

############################# PUNTOS 6-17 #############################

function esDirSimple(){

if [[ "$1" =~ ^/ ]];
  then
    return 1
  else
    return 0
  fi
}

function esValido(){
	if [[ "$1" =~ ^/?conf/ ]] || [[ "$1" =~ ^/?conf$ ]];
	then
		return 1
	fi
	return 0
}

function quitarRaizDir(){ #quita toda la raiz del directorio y se queda con el ultino nombre, ej: home/hola/casa -> casa
	echo "$1" | sed 's:.*/::'
}

function esNumero(){
	if [[ "$1" =~ ^[0-9]+$ ]]; then
		return 0
	fi
	return 1
}

function dividir(){
  echo $((($1 + $2/2) / $2))
}

function getEspacioLibre(){
  local bytesLibres
  bytesLibres=`df "$GRUPO" | tail -n 1 | tr -s ' ' | cut -d' ' -f 4`
  echo $(dividir $bytesLibres 1024)
}

function leerDirectorio() #$1 variable, $3 valor variables, $2 = texto a mostrar con el valor default entre parentisis, setea en la variable la direccion (direccion relativas a la carpeta grupo10)
{
	local _arg=$1
	local dirDefault
	if [ -z "$3" ]; then #varible sin asignar
		dirDefault=$( echo "$2" | cut -d "(" -f2 | cut -d ")" -f1) #texto entre parentisis
		log "$( echo "$2" | cut -f1 -d"(")""($dirDefault):"
	else
		dirDefault=$3
		log "$( echo "$2" | cut -f1 -d"(")""("'$grupo'"$dirDefault):"
	fi
	local aux
	local res
	while true; do
	read aux
    log "$aux" "S"
	if [ "$aux" = "" ]; then
		res=$(quitarRaizDir "$dirDefault")
		res="/$res"
		break
	fi
	if esValido $aux; then
		if esDirSimple $aux; then
			res="/$aux"
		else
			res="$aux"
		fi 
		break
	else
		logError "Directorio invalido, ingrese otro"
	fi
	done
	eval $_arg=\"$res\"
}

function leerEspacioMinimo(){ #$1 = variable, $2 = texto con tamaño default entre parentesis, $3 = valor variable
	local _arg=$1
        local numDefault
	if [ "$3" = "" ]; then
		numDefault=$( echo "$2" | cut -d "(" -f2 | cut -d ")" -f1)
	else
		numDefault=$3
	fi
	log "$( echo "$2" | cut -f1 -d"(")""($numDefault):"
	local aux
	local res
	while true; do
		read aux
        log "$aux" "S"
		if [ "$aux" = "" ]; then
			res=$numDefault
			break
		fi
		if esNumero $aux; then
			local espacioLibre=$(getEspacioLibre)
			if [ $espacioLibre -le $aux ]; then
				logError "Insuficiente espacio en disco."
				logError "Espacio disponible: $espacioLibre Mb."
				logError "Espacio requerido: $aux Mb."
				logError "Inténtelo nuevamente."
			else
				res="$aux"
				break
			fi
		else
			logError "Debe insertar un número"
		fi
	done
	eval $_arg="$res"
}

function leerExtension()
{
        local _arg=$1
        local extDefault
	if [ "$3" = "" ]; then
		extDefault=$( echo "$2" | cut -d "(" -f2 | cut -d ")" -f1)
	else
		extDefault=$3
	fi
	log "$( echo "$2" | cut -f1 -d"(")""($extDefault):"
        local aux
        local res
        while true; do
        read aux
        log "$aux" "S"
        if [ "$aux" = "" ]; then
                res=$extDefault
                break
        fi
        if [ ${#aux} -le 5 ]; then
                        res=$aux
                break
        else
                logError "La extension debe contener 5 o menos caracteres"
        fi
        done
        eval $_arg="$res"
}

function leerTamanioMaximo()
{
        local _arg=$1
        local tamDefault
	if [ "$3" = "" ]; then
		tamDefault=$( echo "$2" | cut -d "(" -f2 | cut -d ")" -f1) 
	else
		tamDefault=$3
	fi
	log "$( echo "$2" | cut -f1 -d"(")""($tamDefault):"
        local aux
        local res
        while true; do
        read aux
        log "$aux" "S"
        if [ "$aux" = "" ]; then
                res=$tamDefault
                break
        fi
        if esNumero $aux; then
                res=$aux
                break
        else
                logError "Debe ingresar un número"
        fi
        done
        eval $_arg="$res"
}


function cargarDirectorios(){
	leerDirectorio BINDIR 'Defina el directorio de instalación de los ejecutables ($grupo/bin):' $BINDIR
	leerDirectorio MAEDIR 'Defina directorio para maestros y tablas ($grupo/mae):' $MAEDIR
	leerDirectorio NOVEDIR 'Defina el Directorio de recepción de archivos de llamadas ($grupo/novedades):' $NOVEDIR
	leerEspacioMinimo DATASIZE 'Defina espacio mínimo libre para la recepción de archivos de llamadas en Mbytes (100):' $DATASIZE
	leerDirectorio ACEPDIR 'Defina el directorio de grabación de los archivos de llamadas aceptadas ($grupo/aceptadas):' $ACEPDIR
	leerDirectorio PROCDIR 'Defina el directorio de grabación de los registros de llamadas sospechosas ($grupo/sospechosas):' $PROCDIR
	leerDirectorio REPODIR 'Defina el directorio de grabación de los reportes ($grupo/reportes):' $REPODIR
	leerDirectorio LOGDIR 'Defina el directorio para los archivos de log ($grupo/log):' $LOGDIR
	leerExtension LOGEXT 'Defina el nombre para la extensión de los archivos de log (lg):' $LOGEXT
	leerTamanioMaximo LOGSIZE 'Defina el tamaño máximo para cada archivo de log en Kbytes (400):' $LOGSIZE
 	leerDirectorio RECHDIR 'Defina el directorio de grabación de Archivos rechazados ($grupo/rechazadas):' $RECHDIR
}


############################# PUNTO 18 #############################

function confirmarDirectorios()
{
	log "Directorio de Ejecutables: "'$grupo'"$BINDIR"
	log "Directorio de Maestros y Tablas: "'$grupo'"$MAEDIR"
	log "Directorio de recepción de archivos de llamadas: "'$grupo'"$NOVEDIR"
	log "Espacio mínimo libre para arribos: $DATASIZE Mb"
	log "Directorio de Archivos de llamadas Aceptados: "'$grupo'"$ACEPDIR"
	log "Directorio de Archivos de llamadas Sospechosas: "'$grupo'"$PROCDIR"
	log "Directorio de Archivos de Reportes de llamadas: "'$grupo'"$REPODIR"
	log "Directorio de Archivos de Log: "'$grupo'"$LOGDIR"
	log "Extensión para los archivos de log: $LOGEXT"
	log "Tamaño máximo para los archivos de log: $LOGSIZE Kb"
	log "Directorio de Archivos Rechazados: "'$grupo'"$RECHDIR"
	log "Estado de la instalación: LISTA"
	log "Desea continuar con la instalación? (Si – No)"
	while true; do
		read aux
		case $aux in
			"Si" ) log "Si" "S"; return 0; break;;
			"No" ) log "No" "S"; return 1; break;;
			* ) logError "Debe ingrear Si o No";;
		esac
	done
}

############################# PUNTO 19 #############################

function confirmarInicioInstalacion(){
	log "Iniciando Instalación. Esta Ud. seguro? (Si - No)"
	while true; do
                read aux
                case $aux in
                        "Si" ) log "Si" "S"; break;;
                        "No" ) log "No" "S"; finalizarInstalacion; break;;
                        * ) logError "Debe ingrear Si o No";;
                esac
        done
}

############################# PUNTO 20 #############################
function crearDirectorio(){
	if [ ! -d "$GRUPO$1" ]; then
		mkdir "$GRUPO$1"
	fi
}

function copiarConExtension(){ # 1: nombre dir origen 2: extension 3: destrino
	find "$1" -maxdepth 1 -name \*."$2" -exec cp {} "$3" \;
}


function crearDirectorios(){
	log "Creando Estructuras de directorio. . . ."
	crearDirectorio "$BINDIR"
	crearDirectorio "$MAEDIR"
	crearDirectorio "$NOVEDIR"
	crearDirectorio "$ACEPDIR"
	crearDirectorio	"$PROCDIR"
	crearDirectorio "$PROCDIR/proc"
	crearDirectorio "$REPODIR"
	crearDirectorio	"$LOGDIR"
	crearDirectorio "$RECHDIR"
	crearDirectorio "$RECHDIR/llamadas"
}

function moverArchivos(){
	log "Instalando Programas y Funciones"
    if [ ! "$GRUPO/archivos_instalacion/bin"  == "$GRUPO$BINDIR" ]; then
        mover "$GRUPO/archivos_instalacion/bin" "$GRUPO$BINDIR" "TODOS"
    fi
	log "Instalando Archivos Maestros y Tablas"
    if [ ! "$GRUPO/archivos_instalacion/mae" == "$GRUPO$MAEDIR" ]; then
        copiarConExtension "$GRUPO/archivos_instalacion/mae" "mae" "$GRUPO$MAEDIR"
        copiarConExtension "$GRUPO/archivos_instalacion/mae" "tab" "$GRUPO$MAEDIR"
    fi
}

function escribirVariable(){
	local fecha=$(date +%d-%m-%Y" "%H:%M:%S);
	echo "$1=$2=$USER=$fecha" >> "$3"
}

function escribirConfiguracion(){
	log "Actualizando la configuración del sistema"
	local archivo="$CONFDIR/AFINSTAL.cnfg"
	
	escribirVariable "BINDIR" "$GRUPO$BINDIR" "$archivo"
	escribirVariable "MAEDIR" "$GRUPO$MAEDIR" "$archivo"
	escribirVariable "NOVEDIR" "$GRUPO$NOVEDIR" "$archivo"
	escribirVariable "DATASIZE" "$DATASIZE" "$archivo"
	escribirVariable "ACEPDIR" "$GRUPO$ACEPDIR" "$archivo"
	escribirVariable "PROCDIR" "$GRUPO$PROCDIR" "$archivo"
	escribirVariable "REPODIR" "$GRUPO$REPODIR" "$archivo"
	escribirVariable "LOGDIR" "$GRUPO$LOGDIR" "$archivo"
	escribirVariable "LOGEXT" "$LOGEXT" "$archivo"
	escribirVariable "LOGSIZE" "$LOGSIZE" "$archivo"
	escribirVariable "RECHDIR" "$GRUPO$RECHDIR" "$archivo"
}

function finalizarInstalacion()
{
  #cerrar AFINSTAL.lg
  exit 0
}

############################# MAIN #############################

if [ -f "$CONFDIR/AFINSTAL.cnfg" ]; then
	leerConf
	finalizarConf
else
	verificarPerl
	mostrarTerminos
	cargarDirectorios
	confirmarDirectorios
	while [ $? -ne 0 ]; do
		clear
		cargarDirectorios
		confirmarDirectorios
	done
	confirmarInicioInstalacion
        crearDirectorios
	moverArchivos
	escribirConfiguracion
	log "Instalación CONCLUIDA"
	finalizarInstalacion
fi

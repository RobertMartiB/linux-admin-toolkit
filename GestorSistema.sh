#!/bin/bash

# ─────────────────────────────────────────────
#   Texto descriptivo:
#   Choose an option  → texto del menú
#   25                → altura del diálogo
#   78                → ancho del diálogo
#   16                → altura visible de la lista
# ─────────────────────────────────────────────


# ══════════════════════════════════════════════
#   USUARIOS
# ══════════════════════════════════════════════

PedirNombreUsuario(){
    Username=$(whiptail --inputbox "Escoge un nombre para el nuevo usuario" 8 39 "" \
        --title "Creacion usuario" 3>&1 1>&2 2>&3)
}

PedirContrasenyaNombre(){
    Password=$(whiptail --passwordbox "Introduce la contraseña para '$Username':\n\n(Mínimo 8 caracteres)" 10 60 \
        --title "Creacion usuario" 3>&1 1>&2 2>&3)
}

PedirUsuarioExistente(){
    #Pide el nombre de un usuario i comprueba que exista en el sistema
    #Recibe el titulo de la ventana como parametro i devuelve 1 si se cancela o no existe
    Usuario=$(whiptail --title "$1" \
        --inputbox "Ingrese el nombre del usuario" 8 39 "" \
        3>&1 1>&2 2>&3)

    exitstatus=$?

    if [ $exitstatus -ne 0 ] || [ -z "$Usuario" ]; then
        whiptail --title "$1" --msgbox "Operación cancelada." 8 50
        return 1
    fi

    if ! id "$Usuario" &>/dev/null; then
        whiptail --title "$1" \
            --msgbox "El usuario '$Usuario' no existe, por favor prueba con otro." 8 60
        return 1
    fi
}

CrearUsuario(){
    PedirNombreUsuario

    exitstatus=$?

    if [ $exitstatus -ne 0 ] || [ -z "$Username" ]; then
        whiptail --title "Error" --msgbox "Operación cancelada." 8 50
        return
    fi

    if id "$Username" &>/dev/null; then
        whiptail --title "Error" --msgbox "El usuario '$Username' ya existe." 8 50
        return
    fi

    while true; do
        PedirContrasenyaNombre

        exitstatus=$?

        if [ $exitstatus -ne 0 ]; then
            whiptail --title "Error" --msgbox "Operación cancelada." 8 50
            return
        fi

        if [ ${#Password} -lt 8 ]; then
            whiptail --title "Error" \
                --msgbox "Contraseña incorrecta.\nDebe tener al menos 8 caracteres.\n\nInténtalo de nuevo." 10 60
        else
            if ! sudo useradd -m -s /bin/bash "$Username"; then
                whiptail --title "Error" \
                    --msgbox "No se ha podido crear el usuario '$Username'.\nRevisa que el nombre sea valido." 8 60
                return
            fi
            echo "${Username}:${Password}" | sudo chpasswd
            whiptail --title "Creacion usuario" \
                --msgbox "Contraseña correcta.\nUsuario '$Username' creado exitosamente." 8 60
            break
        fi
    done

}

ListarUsuariosReales(){
	#Este comando lista los usuarios reales i quita el usuarios nobody i los guarda en una varable
	usuarios=$(awk -F: '$3 >= 1000 && $1 != "nobody" {print $1}' /etc/passwd)

	whiptail --title "Listado de usuarios" \
        --scrolltext --msgbox "$usuarios" 20 60
}

ListarUsuariosSistema(){
	#Este comando lista los usuarios creados por el sistema operativo con el fin de hacer  funciones sin ningu tipo de recursos
	usuarios=$(awk -F: '$3 < 1000 {print $1}' /etc/passwd)

	whiptail --title "Listado usuarios" \
	--scrolltext --msgbox "$usuarios" 20 60
}

ListarTodosLosUsuarios(){
	#Este comando lista todos los usuarios del sistema ya sean reales o creados por el OS
	usuarios=$(awk -F: '{ print $1}' /etc/passwd)

	whiptail --title "Listado de usuarios" \
	--scrolltext --msgbox "$usuarios" 20 60
}

MenuListarUsuarios(){
   Opcion=$(whiptail --title "Listar usuarios" \
	--menu "Escoge una de las opciones siguientes" 25 78 16 \
	"Usuarios reales" 		"Cuentas creadas para el usuario" \
	"Usuarios del sistema" 		"Cuentas de servicios del SO" \
	"Todos los usuarios"		"Listado de todos los usuarios" \
	"Salir" "Salir" \
	3>&1 1>&2 2>&3)

       case $Opcion in
	  "Usuarios reales") ListarUsuariosReales ;;
		#comando para mostrar los usuarios reales
	  "Usuarios del sistema") ListarUsuariosSistema ;;
		#comando para mostrar los usuarios creados por el sistema operativo
	  "Todos los usuarios") ListarTodosLosUsuarios ;;
		#comando para mostrar toods los usuarios del sistema ya sean reales o parte del SO
	  "Salir") return ;;
		#salir al menu principal
       esac
}

EliminarUsuario(){
    PedirUsuarioExistente "Eliminar usuario" || return

    if [ "$Usuario" = "root" ]; then
        whiptail --title "Error" --msgbox "No se puede eliminar el usuario root." 8 50
        return
    fi

    if ! whiptail --title "Eliminar usuario" \
        --yesno "¿Seguro que quieres eliminar '$Usuario' y su carpeta personal?" 8 60; then
        whiptail --title "Eliminar usuario" --msgbox "Operación cancelada." 8 50
        return
    fi

    if sudo userdel -r "$Usuario"; then
        whiptail --title "Eliminar usuario" \
            --msgbox "Usuario eliminado correctamente, pulsa enter para volver al menu." 8 60
    else
        whiptail --title "Error" \
            --msgbox "No se ha podido eliminar '$Usuario'.\nPuede que tenga procesos en marcha." 8 60
    fi

}

# ─────────────────────────────────────────────
#   BLOQUEO Y DESBLOQUEO
#   Bloquear   → usermod -L -e 1  (bloquea la contraseña i caduca la cuenta, asi tampoco entra por ssh)
#   Desbloquear→ usermod -U -e "" (desbloquea la contraseña i quita la caducidad)
#   Temporal   → systemd-run deja un temporizador que deshace el cambio pasados X dias
# ─────────────────────────────────────────────

PedirDias(){
    #Pide el numero de dias que durara el bloqueo o desbloqueo temporal
    while true; do
        Dias=$(whiptail --title "$1" \
            --inputbox "¿Durante cuantos dias?" 8 39 "" \
            3>&1 1>&2 2>&3)

        exitstatus=$?

        if [ $exitstatus -ne 0 ]; then
            whiptail --title "$1" --msgbox "Operación cancelada." 8 50
            return 1
        fi

        if [[ "$Dias" =~ ^[0-9]+$ ]] && [ "$Dias" -gt 0 ]; then
            break
        else
            whiptail --title "Error" \
                --msgbox "Numero incorrecto.\nDebe ser un numero entero mayor que 0.\n\nInténtalo de nuevo." 10 60
        fi
    done
}

ComprobarUsuarioBloqueable(){
    #Evita bloquear root o al propio administrador que esta usando el script
    if [ "$Usuario" = "root" ] || [ "$Usuario" = "${SUDO_USER:-$USER}" ]; then
        whiptail --title "Error" \
            --msgbox "No puedes bloquear ni desbloquear a '$Usuario' desde aqui." 8 60
        return 1
    fi
}

CancelarTemporizador(){
    #Si el usuario tenia un bloqueo o desbloqueo temporal pendiente lo quitamos
    sudo systemctl stop "estado-usuario-$Usuario.timer" &>/dev/null
    sudo systemctl stop "estado-usuario-$Usuario.service" &>/dev/null
    sudo systemctl reset-failed "estado-usuario-$Usuario.service" &>/dev/null
}

ProgramarTemporizador(){
    #Programa el comando que se le pase para que se ejecute pasados X dias
    sudo systemd-run --quiet --unit="estado-usuario-$Usuario" \
        --on-active="${Dias}d" --timer-property=AccuracySec=1min \
        /usr/sbin/usermod "$@" "$Usuario"
}

BloqueoTemporal(){
    PedirUsuarioExistente "Bloqueo temporal" || return
    ComprobarUsuarioBloqueable || return
    PedirDias "Bloqueo temporal" || return

    CancelarTemporizador

    if sudo usermod -L -e 1 "$Usuario" && ProgramarTemporizador -U -e ""; then
        fecha=$(date -d "+$Dias days" "+%d/%m/%Y %H:%M")
        whiptail --title "Bloqueo temporal" \
            --msgbox "Usuario '$Usuario' bloqueado durante $Dias dias.\nSe desbloqueara el $fecha." 8 60
    else
        whiptail --title "Error" --msgbox "No se ha podido bloquear a '$Usuario'." 8 50
    fi
}

BloqueoPermanente(){
    PedirUsuarioExistente "Bloqueo permanente" || return
    ComprobarUsuarioBloqueable || return

    CancelarTemporizador

    if sudo usermod -L -e 1 "$Usuario"; then
        whiptail --title "Bloqueo permanente" \
            --msgbox "Usuario '$Usuario' bloqueado hasta que lo desbloquees manualmente." 8 60
    else
        whiptail --title "Error" --msgbox "No se ha podido bloquear a '$Usuario'." 8 50
    fi
}

DesbloqueoTemporal(){
    PedirUsuarioExistente "Desbloqueo temporal" || return
    ComprobarUsuarioBloqueable || return
    PedirDias "Desbloqueo temporal" || return

    CancelarTemporizador

    if sudo usermod -U -e "" "$Usuario" && ProgramarTemporizador -L -e 1; then
        fecha=$(date -d "+$Dias days" "+%d/%m/%Y %H:%M")
        whiptail --title "Desbloqueo temporal" \
            --msgbox "Usuario '$Usuario' desbloqueado durante $Dias dias.\nSe volvera a bloquear el $fecha." 8 60
    else
        whiptail --title "Error" \
            --msgbox "No se ha podido desbloquear a '$Usuario'.\nSi no tiene contraseña ponle una primero." 8 60
    fi
}

DesbloqueoPermanente(){
    PedirUsuarioExistente "Desbloqueo permanente" || return
    ComprobarUsuarioBloqueable || return

    CancelarTemporizador

    if sudo usermod -U -e "" "$Usuario"; then
        whiptail --title "Desbloqueo permanente" \
            --msgbox "Usuario '$Usuario' desbloqueado." 8 60
    else
        whiptail --title "Error" \
            --msgbox "No se ha podido desbloquear a '$Usuario'.\nSi no tiene contraseña ponle una primero." 8 60
    fi
}

MenuBloqueoUsuario(){
    #Esto lo usaremos para poner un menu donde podremos poner bloqueo temporal o total
    opcionBloqueo=$(whiptail --title "Opcion de bloqueo" \
        --menu "Escoge el tipo de bloqueo" 25 78 16 \
        "Bloqueo temporal"      "Bloquear durante unos dias" \
        "Bloqueo permanente"    "Bloquear hasta desbloquearlo a mano" \
        "Salir"                 "Volver atras" \
        3>&1 1>&2 2>&3)

    case $opcionBloqueo in
        "Bloqueo temporal")     BloqueoTemporal ;;
            #bloquea al usuario i lo desbloquea solo pasados X dias
        "Bloqueo permanente")   BloqueoPermanente ;;
            #bloquea al usuario hasta que el administrador lo desbloquee
        "Salir")                return ;;
    esac
}

MenuDesbloqueoUsuario(){
    #Esto lo usaremos para poner un menu donde podremos poner desbloqueo temporal o total
    opcionDesbloqueo=$(whiptail --title "Opcion de desbloqueo" \
        --menu "Escoge el tipo de desbloqueo" 25 78 16 \
        "Desbloqueo temporal"   "Desbloquear durante unos dias" \
        "Desbloqueo permanente" "Desbloquear definitivamente" \
        "Salir"                 "Volver atras" \
        3>&1 1>&2 2>&3)

    case $opcionDesbloqueo in
        "Desbloqueo temporal")   DesbloqueoTemporal ;;
            #desbloquea al usuario i lo vuelve a bloquear pasados X dias
        "Desbloqueo permanente") DesbloqueoPermanente ;;
            #desbloquea al usuario i quita cualquier temporizador pendiente
        "Salir")                 return ;;
    esac
}

MenuEstadoUsuarios(){
    #Esta funcion nos sirve para saber si el usuario quiere bloquear o desbloquear un usuario
    #a parte podremos llamar a la funcion pertinente
    opcionEstado=$(whiptail --title "Opciones Estado" \
        --menu "Escoge una de las opciones" 25 78 16 \
        "Bloquear usuario"      "Bloqueo temporal o permanente" \
        "Desbloquear usuario"   "Desbloqueo temporal o permanente" \
        "Salir"                 "Volver al menu de usuarios" \
        3>&1 1>&2 2>&3)

    case $opcionEstado in
        "Bloquear usuario")     MenuBloqueoUsuario ;;
        "Desbloquear usuario")  MenuDesbloqueoUsuario ;;
        "Salir")                return ;;
    esac
}

MenuUsuarios() {
    while true; do
        opcion=$(whiptail --title "Menu administrar usuarios" \
            --menu "Escoge una de las opciones" 25 78 16 \
            "Crear usuario"       "Crear un nuevo usuario" \
            "Eliminar usuario"    "Eliminar un usuario existente" \
            "Editar permisos"     "Editar permisos de un usuario" \
            "Listar usuarios"     "Listar todos los usuarios" \
            "Bloquear y desbloquear usuarios"    "Bloquear o desbloquear una cuenta" \
            "Cambiar contrasena"  "Cambiar la contraseña" \
            "Gestion sudoers"     "Gestionar permisos de sudo" \
            "Salir"               "Volver al menú principal" \
            3>&1 1>&2 2>&3)

        exitstatus=$?

        #Si se pulsa Esc o Cancelar volvemos al menu principal
        if [ $exitstatus -ne 0 ]; then
            return
        fi

        case $opcion in
            "Crear usuario")       CrearUsuario ;;
            "Eliminar usuario")    EliminarUsuario ;;
            "Editar permisos")     EditarPermisos ;;
            "Listar usuarios")     MenuListarUsuarios ;;
            "Bloquear y desbloquear usuarios")    MenuEstadoUsuarios ;;
            "Cambiar contrasena")  CambiarContrasenya ;;
            "Gestion sudoers")     GestionSudoers ;;
            "Salir")               return ;;
        esac
    done
}


# ══════════════════════════════════════════════
#   MENÚ PRINCIPAL
# ══════════════════════════════════════════════

while true; do
    opcion=$(whiptail --title "Menu principal" \
        --menu "Choose an option" 25 78 16 \
        "Usuarios"              "Gestión de Usuarios" \
        "Grupos"                "Gestión de Grupos" \
        "Monotorizacion"        "Monitorización del Sistema" \
        "Firewall"              "Firewall (UFW)" \
        "Red"                   "Configuración de Red" \
        "Servicios"             "Servicios y Procesos" \
        "Instalacion programas" "Paquetes y Sistema" \
        "Copias de seguridad"   "Gestion de las copias de seguridad" \
        "Seguridad"             "Seguridad y Auditoría" \
        "Salir"                 "Salir" \
        3>&1 1>&2 2>&3)

    exitstatus=$?

    #Si se pulsa Esc o Cancelar salimos del programa
    if [ $exitstatus -ne 0 ]; then
        exit
    fi

    case $opcion in
        "Usuarios")              MenuUsuarios ;;
        "Grupos")                MenuGrupos ;;
        "Monotorizacion")        MenuMonotorizacion ;;
        "Firewall")              MenuFirewall ;;
        "Red")                   MenuRed ;;
        "Servicios")             MenuServicios ;;
        "Instalacion programas") MenuInstalaciones ;;
        "Copias de seguridad")   MenuCS ;;
        "Seguridad")             MenuSeguridadSistema ;;
        "Salir")                 exit ;;
    esac
done

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
    Username=$(whiptail --inputbox "Escoje un nombre para el neuvo usuario" 8 39 "" \
        --title "Creacion usuario" 3>&1 1>&2 2>&3)
}

PedirContrasenyaNombre(){
    Password=$(whiptail --passwordbox "Contraseña para '$Username':" 8 50 \
        --title "Creacion usuario" 3>&1 1>&2 2>&3)
}

CrearUsuario(){
    PedirNombreUsuario

    while true; do
        Password=$(whiptail --title "Creacion usuario" \
            --inputbox "Introduce la contraseña para '$Username':\n\n(Mínimo 8 caracteres)" 10 60 \
            3>&1 1>&2 2>&3)

        exitstatus=$?

        if [ $exitstatus -ne 0 ]; then
            whiptail --title "Error" --msgbox "Operación cancelada." 8 50
            return
        fi

        if [ ${#Password} -lt 8 ]; then
            whiptail --title "Error" \
                --msgbox "Contraseña incorrecta.\nDebe tener al menos 8 caracteres.\n\nInténtalo de nuevo." 8 60
        else
            sudo useradd -m -s /bin/bash "$Username"
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
	--menu "Escoje una de las opciones siguentes" 25 78 16 \
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
    Usuario=$(whiptail --title "Eliminar usuari" \
        --inputbox "Ingrese el nombre del usuario que desea eliminar" 8 39 "" \
        3>&1 1>&2 2>&3)

    nombres=$(getent passwd | cut -d: -f1)
    encontrado=false

    for elemento in "${nombres[@]}"; do
        if [[ "$elemento" == "$nombres" ]];then
            encontrado=true
            userdel -r $Usuario
            whiptail --title "Eliminar usuario" \
                --msgbox "Usuario eliminado correctamente porfabor pulso enter para ser redirijido" 8 60
            break
        fi
    done

    if [ "$encontrado" = false ]; then
        whiptail --title "Eliminar usuario" \
            --msgbox "Este usuario no existe porfavor prueba con otro" 8 60
    else
        break
    fi

}

MenuUsuarios() {
    while true; do
        opcion=$(whiptail --title "Menu administrar usuarios" \
            --menu "Escoje una de las opciones" 25 78 16 \
            "Crear usuario"       "Crear un nuevo usuario" \
            "Eliminar usuario"    "Eliminar un usuario existente" \
            "Editar permisos"     "Editar permisos de un usuario" \
            "Listar usuarios"     "Listar todos los usuarios" \
            "Bloquear usuario"    "Bloquear una cuenta" \
            "Desbloquear usuario" "Desbloquear una cuenta" \
            "Cambiar contrasena"  "Cambiar la contraseña" \
            "Gestion sudoers"     "Gestionar permisos de sudo" \
            "Salir"               "Volver al menú principal" \
            3>&1 1>&2 2>&3)

        case $opcion in
            "Crear usuario")       CrearUsuario ;;
            "Eliminar usuario")    EliminarUsuario ;;
            "Editar permisos")     EditarPermisos ;;
            "Listar usuarios")     MenuListarUsuarios ;;
            "Bloquear usuario")    BloquearUsuarios ;;
            "Desbloquear usuario") DesbloquearUsuario ;;
            "Cambiar contrasena")  CambiarContrasenya ;;
            "Gestion sudoers")     GestionSudoers ;;
            "Salir")               exit ;;
        esac
    done
}


# ══════════════════════════════════════════════
#   MENÚ PRINCIPAL
# ══════════════════════════════════════════════

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

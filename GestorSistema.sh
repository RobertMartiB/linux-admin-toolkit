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

   MenuUsuarios
}

MenuUsuarios() {
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
        "Listar usuarios")     ListarUsuarios ;;
        "Bloquear usuario")    BloquearUsuarios ;;
        "Desbloquear usuario") DesbloquearUsuario ;;
        "Cambiar contrasena")  CambiarContrasenya ;;
        "Gestion sudoers")     GestionSudoers ;;
        "Salir")               exit ;;
    esac
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

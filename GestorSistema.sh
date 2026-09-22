#!/bin/bash

# Texto descriptivo:
#   Choose an option  → texto del menú
#   25                  → altura del diálogo
#   78                  → ancho del diálogo
#   16                  → altura visible de la lista

opcion=$(whiptail --title "Menu principal" \
    --menu "Choose an option" 25 78 16 \
    "Usuarios"                 "Gestión de Usuarios" \
    "Grupos"                   "Gestión de Grupos" \
    "Monotorizacion"           "Monitorización del Sistema" \
    "Firewall"   	       "Firewall (UFW)" \
    "Red"                      "Configuración de Red" \
    "Servicios"                "Servicios y Procesos" \
    "Instalacion programas"    "Paquetes y Sistema" \
    "Copias de seguridad"      "Gestion de las copias de seguridad" \
    "Seguridad"		       "Seguridad y Auditoría" \
    "Salir"       "Salir" \
3>&1 1>&2 2>&3)

MenuUsuarios() {
    opcion=$(whiptail --title "Menu administrar usuarios" \
        --menu "Escoje una de las opciones" 25 78 16 \
        "Crear usuario"      "Crear un nuevo usuario" \
        "Eliminar usuario"   "Eliminar un usuario existente" \
        "Editar permisos"    "Editar permisos de un usuario" \
        "Listar usuarios"    "Listar todos los usuarios" \
        "Bloquear usuario"   "Bloquear una cuenta" \
        "Desbloquear usuario" "Desbloquear una cuenta" \
        "Cambiar contrasena" "Cambiar la contraseña" \
        "Gestion sudoers"    "Gestionar permisos de sudo" \
        "Salir"              "Volver al menú principal" \
3>&1 1>&2 2>&3)
}

MenuGrupos(){
   :
}

MenuMonotorizacion(){
   :
}

MenuFirewall(){
   :
}

MenuRed(){
   :
}

MenuServicios(){
   :
}

MenuInstalaciones(){
   :
}

MenuCS(){
   :
}

MenuSeguridadSistema(){
   :
}

case $opcion in
        Usuarios)
          MenuUsuarios
        ;;
        Grupos)
          MenuGrupos
        ;;
        Monotorizacion)
          MenuMonotorizacion
        ;;
        Firewall)
          MenuFirewall
        ;;
        Red)
          MenuRed
        ;;
        Servicios)
          MenuServicios
        ;;
        "Instalacion programas")
          MenuInstalaciones
        ;;
        "Copias de seguridad")
         MenuCS
        ;;
        Seguridad)
         MenuSeguridadSistema
        ;;
        Salir)
         exit
        ;;
esac

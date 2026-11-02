<h1 align="center">linux-admin-toolkit</h1>

<p align="center">
  <b>Administra un servidor Linux desde menús en la terminal.</b><br>
  Usuarios, contraseñas, bloqueos y permisos de sudo sin tener que recordar cada comando.
</p>

<p align="center">
  <a href="README.md">English</a> · <b>Español</b>
</p>

<p align="center">
  <a href="https://github.com/RobertMartiB/linux-admin-toolkit/actions/workflows/shellcheck.yml"><img src="https://github.com/RobertMartiB/linux-admin-toolkit/actions/workflows/shellcheck.yml/badge.svg" alt="ShellCheck"></a>
  <img src="https://img.shields.io/badge/Bash-4EAA25?logo=gnubash&logoColor=white" alt="Bash">
  <img src="https://img.shields.io/badge/Linux-FCC624?logo=linux&logoColor=black" alt="Linux">
  <img src="https://img.shields.io/badge/estado-en%20desarrollo-orange" alt="Estado">
  <img src="https://img.shields.io/badge/licencia-MIT-blue" alt="Licencia">
</p>

<p align="center">
  <img src="assets/banner.png" width="820" alt="Menú principal de linux-admin-toolkit">
</p>

<p align="center">
  <i>Modular Linux sysadmin toolkit with a TUI: users, groups, firewall, network, monitoring and more.</i>
</p>

---

## Índice

- [Qué hace ahora](#qué-hace-ahora)
- [Un recorrido por los menús](#un-recorrido-por-los-menús)
- [Cómo funciona el bloqueo temporal](#cómo-funciona-el-bloqueo-temporal)
- [En desarrollo](#en-desarrollo)
- [Requisitos](#requisitos)
- [Uso](#uso)
- [Contribuir](#contribuir)
- [Autor](#autor)

## Qué hace ahora

| Parte | Qué hace |
|---|---|
| **Usuarios** | Crear, eliminar, listar y cambiar contraseñas, con comprobaciones para no equivocarse. |
| **Bloqueos** | Bloquear y desbloquear cuentas, para siempre o **durante X días**. |
| **Sudo** | Ver quién tiene sudo, darlo, quitarlo o crear un usuario que ya lo tenga. |
| **Interfaz** | Menús con whiptail y un tema de colores propio. |

**Gestión de usuarios**

- **Crear usuarios** con carpeta personal y shell Bash, comprobando que el nombre no exista y que la contraseña tenga al menos 8 caracteres.
- **Eliminar usuarios** junto con su carpeta personal, con confirmación previa. No deja borrar `root`.
- **Listar usuarios**: reales (UID ≥ 1000), de sistema (UID < 1000) o todos.
- **Cambiar contraseñas** de cualquier usuario: comprueba que el usuario exista y pide la nueva contraseña dos veces, sin mostrarla, para evitar errores al escribirla.
- **Bloquear y desbloquear cuentas**, de forma permanente o **temporal durante X días**.
  - El bloqueo desactiva la contraseña y caduca la cuenta, así que tampoco se puede entrar por SSH con clave.
  - No permite bloquear a `root` ni al administrador que está usando la herramienta.

**Gestión de `sudoers`**

- **Ver qué usuarios tienen sudo** (miembros del grupo `sudo`).
- **Dar permisos de sudo** a un usuario que ya existe, o **crear un usuario nuevo** directamente con sudo.
- **Quitar permisos de sudo**, con confirmación previa.
  - No deja quitar sudo a `root` ni al administrador que está usando la herramienta, para no quedarse sin acceso.

**Interfaz**

- Menús con whiptail y tema propio de 256 colores, con un tema alternativo para terminales de 8 colores.
- Si se lanza con `sh` (dash), se vuelve a ejecutar con `bash` automáticamente.

## Un recorrido por los menús

<p align="center">
  <img src="docs/demo.gif" width="820" alt="Demo navegando por los menús">
</p>

Desde el menú principal se entra en **Usuarios**, donde están todas las opciones de cuentas.

<p align="center">
  <img src="docs/capturas/menu-usuarios.png" width="820" alt="Menú de administración de usuarios">
</p>

<table>
  <tr>
    <td width="50%"><img src="docs/capturas/menu-sudoers.png" alt="Menú de gestión de sudoers"></td>
    <td width="50%"><img src="docs/capturas/menu-bloqueo.png" alt="Menú de bloqueo de usuarios"></td>
  </tr>
  <tr>
    <td align="center"><b>Gestión de sudoers</b><br>Dar, quitar y listar permisos de sudo.</td>
    <td align="center"><b>Bloqueo de usuarios</b><br>Temporal durante unos días o permanente.</td>
  </tr>
</table>

## Cómo funciona el bloqueo temporal

En lugar de dejar un `cron` o un `sleep` en marcha, la herramienta programa un **temporizador de systemd** que deshace el cambio solo:

```bash
# Bloquear ahora…
sudo usermod -L -e 1 "$Usuario"

# …y programar el desbloqueo pasados X días
sudo systemd-run --unit="estado-usuario-$Usuario" \
    --on-active="${Dias}d" --timer-property=AccuracySec=1min \
    /usr/sbin/usermod -U -e "" "$Usuario"
```

Cada usuario tiene una sola unidad `estado-usuario-<usuario>`. Si se cambia de idea, la herramienta cancela el temporizador pendiente antes de aplicar el nuevo estado.

## En desarrollo

- [ ] Editar permisos de usuarios
- [ ] Gestión de grupos
- [ ] Monitorización del sistema
- [ ] Firewall (UFW)
- [ ] Configuración de red
- [ ] Servicios y procesos
- [ ] Paquetes y actualizaciones
- [ ] Copias de seguridad
- [ ] Seguridad y auditoría

## Requisitos

- Linux con **systemd**, pensado para Debian y Ubuntu.
- `bash`, `whiptail` y `sudo`.

```bash
sudo apt install whiptail
```

## Uso

Descargar y ejecutar en un paso:

```bash
curl -fsSLO https://raw.githubusercontent.com/RobertMartiB/linux-admin-toolkit/main/GestorSistema.sh && chmod +x GestorSistema.sh && ./GestorSistema.sh
```

O clonando el repositorio:

```bash
git clone https://github.com/RobertMartiB/linux-admin-toolkit.git
cd linux-admin-toolkit
chmod +x GestorSistema.sh
./GestorSistema.sh
```

Las acciones que modifican el sistema usan `sudo`, así que hace falta un usuario con permisos de administrador.

## Contribuir

Las ideas, avisos de errores y pull requests son bienvenidos. Las issues con la etiqueta [`good first issue`](https://github.com/RobertMartiB/linux-admin-toolkit/labels/good%20first%20issue) son un buen punto de partida.

## Autor

**Robert Martí**, técnico de sistemas (CFGS ASIX) y estudiante de Ingeniería Informática en la UOC.

[LinkedIn](https://www.linkedin.com/in/robert-marti-badia-119710235/) · [Portfolio](https://robertmartib.github.io/portfolio-robert/)

## Licencia

[MIT](LICENSE)

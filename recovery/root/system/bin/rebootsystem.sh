#!/sbin/sh
# TWRP/OrangeFox corre este script el solo (si existe) justo antes de
# rebootear a system, desde tw_reboot() en twrp-functions.cpp
# (check_and_run_script("/sbin/rebootsystem.sh", "reboot system")), antes de
# la llamada real al reboot. Es el gancho oficial para esto, no un botón del
# tema. El bootloader de Samsung deja "boot-recovery" en el BCB al entrar a
# recovery por combo de teclas, y TWRP nunca lo limpia para el target
# "system" - por eso el loop. Se limpia aca.
dd if=/dev/zero of=/dev/block/by-name/misc bs=512 count=64

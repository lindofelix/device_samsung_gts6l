# OrangeFox device tree - Samsung Galaxy Tab S6 LTE (SM-T865, gts6l)

Generado a partir del `recovery.img` stock (firmware T865XXS6DWH2, kernel 4.14.190, SoC SM8150 / msmnile).

## Datos extraídos del recovery.img
| Dato | Valor |
|---|---|
| Header boot | v1, page 4096, base 0x0, kernel 0x8000, ramdisk 0x2000000, tags 0x1e00000 |
| Board name | SRPSC20B006 |
| Kernel | Image arm64 envuelto "UNCOMPRESSED_IMG" + 2 DTB (SM8150 v1 y v2) anexados |
| Recovery DTBO | Incluido en la imagen (header v1): 1052625 bytes, 4 overlays -> `prebuilt/dtbo.img` |
| Ramdisk | gzip; el kernel soporta gzip/bzip2/LZMA (se usa LZMA para que quepa) |
| Partición recovery | 82792448 bytes (por el footer AVB) - verifícalo en el equipo |
| Particiones | NO dinámicas, NO A/B (system/vendor/product por by-name) |

## Cosas que debes verificar (no se pueden deducir del recovery)
1. **Tamaño**: kernel ~47 MiB + DTBO ~1 MiB + ramdisk de OrangeFox debe caber en ~79 MiB. Si falla por tamaño, quita funciones en `vendorsetup.sh`.
2. **Rotación**: si la pantalla sale de lado, cambia `TW_ROTATION` (90/180/270) en BoardConfig.mk.
3. **Desencriptado**: depende de blobs de /vendor. Revisa `fileencryption=` con
   `adb shell cat /vendor/etc/fstab.qcom | grep userdata` y ajusta `recovery.fstab`.
4. **Brillo**: `TW_MAX_BRIGHTNESS` es estimado (255).

## Flasheo (Samsung)
Bootloader desbloqueado (OEM unlock) + vbmeta deshabilitado, luego Odin: AP -> `OrangeFox-gts6l-odin.tar.md5`, Auto Reboot desactivado, y arrancar directo a recovery (Vol+ + Power).

## USB (MTP / ADB)
`recovery/root/init.recovery.usb.rc` usa MTP por **FunctionFS (`ffs.mtp`)**, igual que el firmware stock.
Motivo (visto en `recovery.log`): con el MTP "legacy" (`/dev/usb_mtp_gadget`) el driver de Samsung rechaza los ioctl de AOSP
(`Inappropriate ioctl for device`), por lo que se ven las carpetas pero no se puede copiar ningun archivo (error 0x80004005 en Windows).
Se monta `/dev/usb-ffs/mtp` y se fija `sys.usb.mtp.device_type=3`. VID/PID Samsung `04E8:6860`, controlador `a600000.dwc3`.
Si el PC no detecta la tablet: `ls /dev/usb-ffs/mtp`, `ls -l /config/usb_gadget/g1/configs/b.1/`, `getprop sys.usb.ffs.mtp.ready`, `dmesg | grep -i -E "ffs|mtp|dwc3"`.

## Bateria
`TW_USE_LEGACY_BATTERY_SERVICES := true`: la barra de estado mostraba 0% o 100% fijo aunque
`/sys/class/power_supply/battery/capacity` daba el valor correcto (55). Con este flag se lee ese archivo directamente.

## Tema horizontal (en pruebas)
`recovery/root/twres/` reemplaza el tema de OrangeFox por una copia adaptada a horizontal, basada en el
`twres` real extraído con `adb pull /twres` de un build ya funcionando (portrait). Cambios hechos hasta ahora:
- Lienzo (`ui.xml`): 1920x1080 en vez de 1080x1920 (mismo desajuste de escala que ya funcionaba en vertical, solo que con los ejes cambiados).
- `resources/vars.xml` (vía overrides al final de `ui.xml`): reubicadas las posiciones horizontales de la barra de estado (reloj/batería) y el panel de navegación (4 pestañas + íconos de inicio/consola/atrás), manteniendo los mismos márgenes del diseño original.
- **`pages/chrome_test.xml` reemplaza temporalmente la página "main"**: solo muestra la barra de arriba y el panel de abajo, sin cargar instalación/wipe/backup/etc. (para no mostrar pantallas aún sin adaptar, que saldrían distorsionadas con el nuevo lienzo). Los íconos no llevan a ningún lado todavía, es esperado.
- Pendiente: adaptar el resto de pantallas (`install.xml`, `wipe.xml`, `backup.xml`, `files.xml`, etc.) una por una.

## Log de kernel panic (pstore / last_kmsg)
El kernel trae el driver (`CONFIG_PSTORE_RAM=y`), pero no encontré en el binario evidencia de que el
device tree del KERNEL reserve RAM para guardarlo (`ramoops`); sin eso, el log no se genera, y eso no se
puede arreglar desde este device tree (haría falta recompilar el kernel). Igual monté `/sys/fs/pstore` en
`init.recovery.qcom.rc` por si la reserva sí existe. Para comprobarlo: provocar un panic de prueba
(`adb shell "echo c > /proc/sysrq-trigger"`), reiniciar a recovery, y `adb shell ls /sys/fs/pstore`.

## install.xml (pantalla "flash_confirm", en pruebas)
- `btn_raised_right_x`: era 1032 (fijo, pegado al borde del lienzo viejo de 1080), ahora 1872 (mismo margen de 48px, con el lienzo nuevo de 1920).
- La lista de opciones (checkboxes) se movió de debajo del nombre de archivo/carpeta a una **segunda columna a la derecha**, porque con el alto nuevo (1080 en vez de 1920) se encimaba con los botones y la barra deslizante de abajo.
- Esto solo cubre la página `flash_confirm` (la que se ve al elegir un zip). Las otras páginas de este mismo archivo (`fox_modules_confirm`, `add_zip`, `flash_zip`, etc.) todavía no están adaptadas.
- Sigue pendiente revisar, variable por variable (no por rango numérico), otras posiciones pegadas al borde derecho que aparezcan en próximas pantallas.

## splash.xml (pantalla de arranque, el logo)
Es un archivo aparte, con sus propias variables, no comparte nada con el resto del tema. Se me había
pasado corregirlo. Cambios: `<resolution>` de 1080x1920 a 1920x1080, `screen_width`/`screen_height`
a 1920/1080, y el logo/fondo/texto, centrados en x=540 (mitad del ancho viejo), ahora en x=960.
Nota: el texto "OrangeFox Recovery" usa `%screen_h%` (con "h", minúscula, distinto de `screen_height`
que sí se corrigió), una variable que no se define en este archivo - probablemente es un valor interno
del motor de OrangeFox con el alto real de pantalla. No lo toqué porque no tengo forma de confirmar qué
valor trae; si el texto sale mal ubicado verticalmente, es el primer lugar a revisar.

## files.xml (administrador de archivos, en pruebas)
Son 26 páginas en un solo archivo. Solo la primera (`filemanagerlist`, la lista de archivos que se ve
al entrar) tenía posiciones fijas pegadas al borde derecho; el resto ya usaba variables, así que debería
heredar los ajustes solo. Cambios en `filemanagerlist`:
- Iconos de ordenar/menú (x=816, x=954): ahora en 1656/1794, mismo margen pero sobre el ancho nuevo.
- Línea decorativa debajo de la barra de búsqueda (w=984): ahora 1824.
- Fila de "acciones rápidas" (w=1080, ancho fijo de pantalla completa): cambiado a `%screen_w%` para que
  siempre cubra el ancho real, sea cual sea.
Las otras 25 páginas (buscar, renombrar, permisos, confirmaciones, etc.) no se revisaron una por una:
si alguna se ve mal, hay que probarla y avisar.

## Descubrimiento importante: %screen_w% no se propaga solo
`screen_w` por sí sola SÍ se puede sobreescribir (varias páginas la leen directo y funciona), pero las
variables de `vars.xml` que a su vez SE DEFINEN usando `%screen_w%` (como `fileselector_width`) se quedan
con el valor calculado en el momento en que el tema arranca, usando el 1080 original, sin importar que
se sobreescriba `screen_w` después. Esto causó que la lista de archivos (y su barra de scroll) se
cortaran a la mitad de la pantalla nueva. Curiosamente, con `%screen_h%` esto NO pasa (son 43 variables
así y las que ya probamos, como la del panel de navegación, se ven bien) - probablemente screen_h es un
valor interno que el propio OrangeFox calcula solo a partir de la pantalla real, y screen_w no.
Corregido dándoles directamente su valor final en vez de depender de que se recalculen solas:
- `fileselector_width`: 1920 (listas de archivos a ancho completo).
- `nav_panel_w`: 1824, `nav_panel_full_h`: 1560 (fondo del panel de navegación).
Pendiente: `adv_additions_h` (en `advanced.xml`, todavía no adaptada) tiene el mismo problema; corregir
cuando se trabaje esa pantalla.

## Bateria doble (en investigacion)
Nueva teoria: `style_battery` tiene `persist="1"` en el tema original, un sistema de TWRP para ajustes
de usuario que puede ignorar una simple declaracion `<variable>` si ya existe un valor por defecto
cargado por otra via (no necesariamente un archivo en /data o /cache, podria ser un valor interno del
propio OrangeFox compilado). Se agrego una accion explicita en chrome_test.xml que FUERZA
`style_battery=0` al cargar la pagina, en vez de solo declararlo. Si esto tampoco funciona, el problema
esta mas adentro del codigo compilado de OrangeFox y no se puede arreglar solo con el device tree.

## Cambio de lienzo: 1920x1080 -> 2560x1600 (resolucion real del panel)
Se recalcularon TODAS las variables puestas a mano hasta ahora para la resolucion real del panel en
horizontal (2560x1600) en vez de la aproximacion anterior. Con esto la escala es 1:1 exacta (sin
estiramiento en ningun eje), mejor que antes. Se tuvo cuidado de seguir dando el valor final a las
variables que dependen de `%screen_w%` dentro de vars.xml (fileselector_width, nav_panel_w), en vez de
dejar que se recalculen solas, para no repetir el bug de la lista de archivos cortada a la mitad.
`nav_panel_full_h` no sigue la formula original del tema (screen_w-360): esa formula daba un resultado
mas grande que la pantalla entera una vez que el ancho es mayor que el alto (bug del tema original, no
mio), asi que se calculo con screen_h-360 en su lugar, un valor seguro.
Pendiente: `adv_additions_h` (advanced.xml) y `lb_l12` (no se ha encontrado donde se usa) quedan
para cuando se trabajen esas pantallas.

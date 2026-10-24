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

## Vuelta atras: 2560x1600 -> 1920x1080 de nuevo
El cambio a la resolucion real (2560x1600) dejo el equipo trabado en el logo de Samsung al arrancar.
No tengo confirmado que fuera exactamente por eso (no llegamos a ver el log), pero por seguridad se
revirtio TODO a 1920x1080, que es la version que si arranca. Se mantienen las correcciones de la lista
de archivos y de instalacion, recalculadas para 1920 de nuevo. El fondo de la barra de busqueda tambien
se redujo de paso (ahora 1824x220 en vez de 1824x260).
Pendiente: investigar con mas calma, un cambio a la vez, si se quiere volver a intentar la resolucion real.

## Teclado en pantalla
Cada tecla tenia un ancho fijo de 108px (10 teclas x 108 = 1080, el ancho viejo exacto), sin relacion
con ninguna variable de pantalla, por eso no se agrandaba solo y el teclado se quedaba a la izquierda.
Se escalaron TODOS los anchos (el base y los de teclas especiales como espaciadora/shift/enter) por el
mismo factor (1920/1080 = 1.778), incluyendo el teclado numerico aparte que tenia sus propios tamanos.
Barra de busqueda: alto subido de 220 a 240.

## Teclado: vuelta atras + centrado (en vez de escalar)
Escalar el ancho de cada tecla rompio la mitad del teclado: se veian las letras pero sin fondo de boton
y sin responder al tacto. Esos numeros SI son anchos reales (confirmado en el codigo fuente de TWRP),
pero algo en el motor no tolera agrandarlos asi. Por seguridad, el teclado volvio a su tamano original
(el mismo que ya funcionaba bien en vertical) y solo se desplazo su posicion X para centrarlo en la
pantalla nueva, en vez de dejarlo pegado a la izquierda con un hueco vacio al lado. El teclado del
terminal (consola) se dejo sin centrar: sus filas ya eran mas anchas que la pantalla original incluso
antes de mis cambios, asi que no se toco.

## settings.xml (ajustes, en pruebas)
- **`ab_btn1_x`/`ab_btn2_x`/`ab_btn3_x`**: los iconos de la barra superior (reset del tema, modo lab,
  etc). Estaban fijos al borde del lienzo viejo, y se usan en CASI TODAS las pantallas (`base.xml`,
  `templates.xml` y 10+ paginas mas), no solo en ajustes. Corregidos en `vars.xml`, deberian beneficiar
  a varias pantallas que ya dimos por buenas sin haberlo notado.
- Las 3 pestanas de la pantalla "Acerca de" (Creditos/Traductores/Cambios) sumaban exactamente el ancho
  viejo (360 cada una). Se agrandaron a 640 cada una para llenar el ancho nuevo parejo.
- Pendiente sin resolver: un boton "Ver mas" en la tarjeta de creditos (x=752) que podria estar mal
  posicionado; no se toco por no tener claro si pertenece a una tarjeta de ancho fijo o no. Avisar si se
  ve mal.

## Sliders cortados (brillo, vibracion, etc)
`slidervalue_w` era un numero fijo (984), calculado para el margen del ancho viejo (88+984+8=1080),
no una formula que dependiera de la pantalla. Se uso en settings.xml, files.xml y anywhere.xml.
Corregido a 1824 (mismos margenes de 88/8, sobre el ancho nuevo de 1920).

## Bateria doble: resuelto quitando el icono
Confirmado que no era arreglable desde el tema: ni declarar `style_battery=0` ni forzarlo con una accion
cambiaron nada, asi que el problema esta en el codigo ya compilado de OrangeFox (el widget nativo
`<battery>`), no en el XML. Se quitaron los 9 elementos `<battery>` de `statusbar.xml` (los 3 estilos x
3 posiciones de reloj) y se reemplazaron por texto simple con el porcentaje (`%tw_battery%%`), sin
ningun dibujo. Se pierde el icono grafico, pero ya no deberia duplicarse ni verse cortado.

## Segundo intento: 2560x1600
Se repitio el cambio de lienzo a la resolucion real, ahora recalculando tambien las correcciones hechas
despues del primer intento (iconos de barra superior, sliders, pestanas de ajustes, texto de bateria).
De paso se encontro y corrigio otro ancho fijo del canvas viejo: la lista dentro de las pestanas de
"Acerca de" (1032 -> 2512).
IMPORTANTE: la vez pasada este cambio dejo el equipo trabado en el logo de Samsung y no se pudo sacar
el log para confirmar la causa real. Si vuelve a pasar, sacar el log esta vez es prioritario:
  adb devices
  adb pull /tmp/recovery.log
incluso si la pantalla no muestra nada.

## Bateria: vuelta al icono nativo (el texto no mostraba nada)
Reemplazar el icono por texto con %tw_battery% no mostro nada en absoluto (peor que el bug anterior).
Se revirtio pages/templates/statusbar.xml a su version original, con el icono nativo de TWRP/OrangeFox
(que se duplica visualmente, bug ya confirmado que no se puede arreglar desde el tema). Se mantiene el
forzado de style_battery=0 (rectangulo simple) en vars.xml y en la accion de chrome_test.xml.

## wipe.xml (en pruebas)
Las 2 pestanas (Wipe/Formatear datos) estaban centradas (no pegadas a un borde) en el ancho viejo:
margen de 156px a cada lado. Se recentraron igual en el ancho nuevo (margen 896px), sin cambiar su
tamano. El resto del archivo (lista de particiones, boton de confirmar, etc) ya usaba variables que
se ajustan solas. No se encontraron otros numeros sueltos en todo el archivo.

## universal.xml y anywhere.xml (en pruebas)
`universal.xml` (pantallas de error/advertencia como "sin sistema operativo") no tenia ninguna posicion
ni ancho fijo en las 470 lineas del archivo; no necesito ningun cambio.
`anywhere.xml` (pantalla de bloqueo y consola/terminal):
- El boton de linterna en la consola usaba x=996 repetido 3 veces (el mismo margen que ab_btn1_x);
  se cambio para usar esa variable en vez de repetir el numero.
- `console_width` (ancho del area de texto de la consola) era un fijo 984, margen 48 a cada lado del
  canvas viejo; corregido a 2464 con el mismo margen sobre el nuevo.

## mount.xml, reboot.xml, rmmanager.xml (en pruebas)
- `reboot.xml`: 3 tarjetas (reiniciar sistema/recovery/apagar) que casi llenaban el ancho viejo de borde
  a borde (margen 42px simetrico). Recentradas como grupo en el ancho nuevo (margen 782px), sin cambiar
  su tamano.
- `mount.xml`: selector de tamano de cuadricula para el patron de bloqueo (3x3/4x4/5x5/6x6), una funcion
  poco usada. Cabe bien dentro del ancho viejo sin cortarse ni encimarse; solo deja espacio vacio a la
  derecha en la pantalla nueva. No se toco (cosmetico, no roto). El resto del archivo no tenia otros
  numeros sueltos.
- `rmmanager.xml`: no necesito cambios, el unico numero suelto (x=40) es un margen izquierdo normal.

## dialogs.xml y pass.xml (en pruebas), y correccion en mount.xml
`dialogs.xml` no necesito cambios, ya usaba variables en todo.
`pass.xml` y `mount.xml` comparten el mismo selector de cuadricula de patron (3x3 a 6x6): esta vez se
recentro como grupo (antes se habia dejado asi en mount.xml por ser cosmetico, pero el usuario pidio
consistencia ya que pass.xml se usa mas seguido). Nota: al revisar mount.xml aparecieron numeros que no
coincidian con nada calculado (869, 1690, 2511) - se re-copio limpio desde el tema original y se aplico
el cambio de nuevo correctamente; no quedo claro de donde salieron esos numeros raros.

## customization.xml (en pruebas)
Tenia el mismo patron de 3 pestanas que settings.xml (colores/iconos/estilo de navegacion, 3 veces).
Se aplico la misma correccion ya probada ahi. No se encontraron otros anchos fijos en el resto del
archivo (2140 lineas).

## advanced.xml (en pruebas) - resuelto adv_additions_h pendiente
`adv_additions_h` (pendiente desde hace tiempo) tenia el mismo bug que nav_panel_full_h: formula
screen_w-200 (altura calculada con el ANCHO), que solo funcionaba por coincidencia en vertical. Con el
ancho ahora mayor que el alto, daba un valor mas grande que la pantalla entera. Corregido a un valor fijo
seguro (1400) basado en el alto real.
`lb_l12` (tambien pendiente): confirmado que no se usa en ninguna pagina de las 23 del tema. Variable
muerta del tema original, no afecta nada.
Nota importante: el contenedor de trabajo se reinicio durante esta sesion y se perdieron los archivos
temporales; se reconstruyo todo desde el ultimo zip entregado (device_samsung_gts6l.zip) y el theme
original (twres_portrait.zip), ambos seguian disponibles. No deberia haberse perdido ningun cambio ya
confirmado, pero si algo de lo ya probado se ve distinto a como se dejo, avisar.

## backup.xml y restore.xml (en pruebas)
- `backup.xml`: boton "Actualizar" junto al "Cancelar" del dialogo de seleccion de almacenamiento, tenia
  un numero fijo. Se ajusto manteniendo la misma distancia (264px) respecto al boton Cancelar, que ya
  usa una variable correcta.
- `restore.xml`: boton para abrir ese mismo dialogo estaba centrado (336+204=540, el centro viejo);
  recentrado al centro nuevo (1076). El icono de "sin copias" tambien se reubico con el mismo
  desplazamiento del centro.
Con esto quedan las 15 pantallas principales revisadas. Pendientes menores sin resolver (dejados asi a
proposito): bateria duplicada (bug del motor compilado, no arreglable desde el tema), boton "Ver mas" en
creditos de ajustes (sin confirmar si esta bien o mal).

## BUILD FINAL - tema horizontal completo
Se confirmaron las 15 pantallas principales (incluyendo backup/restore). Se reviso el ultimo archivo
pendiente (fox.xml, modo lab) y no necesito cambios. Se quito la pagina de prueba (chrome_test.xml) y
se restauro la lista completa de paginas original, con main.xml como pagina de inicio real.
Se valido CADA archivo XML del tema (78 en total): solo 2 "fallos", ambos falsos positivos confirmados
contra el tema original (un atributo que empieza con numero, valido para OrangeFox pero no para un
parser XML estricto; y un archivo de plantilla sed que a proposito no es XML valido).
Pendientes conocidos, sin resolver (documentados arriba en este README): bateria duplicada (bug del
motor compilado), boton "Ver mas" en creditos (sin confirmar), selector de cuadricula de patron en
mount.xml/pass.xml (ya resuelto, recentrado).

## Prueba: bateria con desajuste de proporcion a proposito
A pedido del usuario, se fuerza style_battery=1 (circulo) y se cambio su caja de 48x48 (que coincide
con la imagen real) a 96x48 (el doble de ancho, desajustada a proposito) para probar si el bug de
duplicacion es sensible al desajuste de proporcion de la imagen. Si en esta prueba el icono se ve
distinto/peor que antes, confirma la teoria; si se ve igual de duplicado, confirma que no es eso.

## Correccion de emergencia: texto de diagnostico causo "render request failed"
El texto combinado (3 variables + texto literal en una linea) causo un error repetido en pantalla
("E:A render request has failed"). Se reemplazo por 3 textos separados y simples, uno por variable,
mas seguro. De paso se repuso la prueba de proporcion 96x48 en battery_circle, que habia desaparecido
del archivo sin explicacion clara (posible perdida de estado entre turnos de trabajo).

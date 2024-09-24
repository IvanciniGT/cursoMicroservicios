# Instalaciones de software

## Procedimiento tradicional: Instanación a Hierro en la máquina

           App1 + App2 + App3               Problemas:
    --------------------------------            - App1 se vuelve loca (CPU: 100%) -> OFFLINE
           Sistema Operativo                            App2 y App3 ---> OFFLINE
           Windows, Linux, ...                  - App1 y App2 pueden tener dependencias incompatibles
    --------------------------------            - App1 podría espiar a App2 y App3
                HIERRO

Esto hace que en los entornos de producción esta forma de instalar solo pueda aplicarla a servidores
en los que solo instalo un producto(aplicación).

## Máquinas virtuales

       App1   |   App2 + App3               Esto nos resuelve los problemas de las instalaciones tradicionales
    -------------------------------- 
        SO1   |       SO2
    --------------------------------        Problemas:
        MV1   |       MV2                       - Desperdicio de recursos
    --------------------------------            - Merma en el rendimiento de las apps
        Hipervisor: HyperV, Vmware              - El mnto se complica
        Citrix, VirtualBox, KVM
    -------------------------------- 
           Sistema operativo
           Windows, Linux...
    -------------------------------- 
                HIERRO

## Contenedores (2013 -> Docker)

       App1   |   App2 + App3               Esto nos resuelve los problemas de las instalaciones tradicionales
    --------------------------------
        C1    |       C2 
    --------------------------------        Pero sin los inconvenientes de las máquinas virtuales = GUAY !!!!
        Gestor de contenedores
        Docker, Podman, Rancher
        CRIO, ContainerD
    -------------------------------- 
           Sistema operativo
           Linux
    -------------------------------- 
           HIERRO

Un contenedor es un ENTORNO AISLADO dentro de un Kernel (99% linux) que permite ejecutar dentro procesos.
AISLADO en cuanto que?
- Cada contenedor(entorno) tiene su propia configuración de red (y por ende, su propia IP)
- Cada contenedor tiene sus propias variables de ENTORNO
- Cada contenedor tiene su propio sistema de archivos (como si fuera su propio HDD)
- Cada contenedor PUEDE tener limitaciones de acceso a los recursos HARDWARE de la máquina

Dentro de un Contenedor NO ES POSIBLE por definición ejecutar un Sistema Operativo.
Las apps (procesos) que corren dentro de un contenedor están gestionados (y en comunicación) con el KERNEL del HOST.

Nota: Entonces no se pueden ejecutar contenedores en una máquina con Windows? SI
- Hoy en día, de forma estandar (es una funcionaldiad que da WINDOWS) puedo levantar un kernel de linux en cualquier windows: WLS
    - Se configura en característcias avanzadas de Windows
- Desde hace poco, se ha hecho una implementación del estandar de contenedores para que pueda correr sobre el kernel NT
    - El uso de esto es muy limitado (restringido a productos muy concretos de MS)

Al trabajar con contenedores, NO INSTALAMOS SOFTWARE, lo desplegamos!
Los contenedores se crean desde IMAGENES DE CONTENEDOR.
No es nuevo... las Máquinas virtuales las creamos con una IMAGEN DE SISTEMA OPERATIVO

Una ISO de ubuntu... Varios Gbs
Y a lo mejor solo quiero poner ahí a correr un servidor WEB: NGINX (20kbs)

La imagen de un contenedor solo. lleva dentro los programas que me interesan. 
Además lo que lleva es una instalación YA EFECTUADA del programa.

## Imagen de contenedor

Es un triste archivo comprimido (como un ZIP) que lleva dentro:
- Un programa ya instalado de antemano por alguien
- Las dependencias (necesidades) que pueda tener esa programa
- Una configuración inicial (que luego podré fácilmente personalizar)
- Otros datos de interes:
    - Qué comando arranca el programa que viene instalado                       DOCKER START
    - Qué puertos está usando el programa que viene instalado
    - Qué variables de entorno necesita el programa que viene instalado
    - En qué carpetas guarda los datos el programa que viene instalado
- Pueden venir programas adicionales que sean de utilidad par quien use el contenedor
    - Quizas me interesa tener cp, o mkdir
    - Quizás me interesa tener una tienda (apt, yum, dnf)
    - Quizás me interesa tener una terminal de comandos: bash, zfs, sh

Las imágenes de contenedor atienden a un ESTANDAR(lo creo Docker), gestionado por una organización 
llamada THE OPEN CONTAINER GROUP:
-> Da igual con el gestor de contenedores que cree la imagen, va a funcionar en cualquier gestor de contenedores.

Las imágenes de contenedor las encontramos (y descargamos) de REGISTROS DE REPOSITORIOS DE IMAGENES DE CONTENEDOR.
Hay un huevo. El más famoso, con diferencia DOCKER HUB:
- Oracle Container registry
- Microsoft container registry
- Quay.io (REDHAT)
- ...
- Las empresas de hecho suelen tener sus propios registros de repos de imagenes de contenedor (NEXUS, ARTIFACTORY, GITLAB, GITHUB)

Las imágenes de contenedor se identifican por una url:
    URL_REGISTRY/REPO:tag

Las descargamos mediante un gestor de contenedores: 
    `$ docker image pull URL_REGISTRY/REPO:tag`
    
Habitualmente, cuando trabajamos con gestores de contenedores, nos vienen configurados (cuando los instalo... docker)
con unos registries por defecto.
Si al escribir la imagen de un contenmedor no escribo la parte de la URL_REGISTRY, 
el gestor de contenedores busca en los que él tenga configurados por defecto.
    `$ docker image pull REPO:tag`
    
Todos los gestores de contenedores tienen por defecto configurado el registry DOCKER HUB.

## TAGs

Los tags suelen indicar la versión del producto que llevan instalado... 
    httpd:1.24.3
Muchas veces me indican la imagen base desde la que se han generado
    -alpine
    -oraclelinux
    -debian
    EN OTRAS PALABRAS, los 4 comandos que voy a encontrar dentro adicionales al programa
A veces traen información adicional.
    httpd:1.24.3-perl

### OJO: IMPORTANTE

Hay 2 tipos de tags:
- Fijos
    nginx: 1.21.5   -> Este siempre a punta a una versión concreta   
- Variables
    nginx: 1.21     -> Este apunta a la última versión 1.21.? que exista
    nginx: 1        -> Este apunta a la última versión 1.?.? que exista
    nginx: latest   -> Este apunta a la última versión que exista

EN ENTORNOS DE PRODUCCION, cuáles están prohibidos?
    nginx: 1.21.5   -> ESTA BIEN... es muy conservadora
    nginx: 1.21     -> ES LA GUAY: Traete la funcionaldiad que necesito (que se marca con el minor)
                            pero, el último path (con todos los bugs posibles arreglados)
    nginx: 1        -> PROHIBIDO: Mañana puede apuntar a la versión 1.22.0 -> 
                            Nueva funcionalidad que no necesito, que puede traer nuevos bugs
    nginx: latest   -> PROHIBIDO: Mañana puede apuntar a la versión 2.0.0 -> BREAKING CHANGE

OJO Al tag `latest`.
Por defecto, si al pedir la descarga de una imagen de contenedor no pongo tag, solo repo:
    `$ docker image pull REPO`
Los gestores de contenedores buscan en automático un tag llamado `latest`... pero solo es un tag más, que 
en los registries se trata como cualquier otro tag.
De hecho su uso está tan desaconsejado que muchos fabricantes en sus repos mo ponen el tag `latest`.

Las imágenes de contenedor son EXTREMEADAMENTE LIGERAS EN COMPARACION con las imágenes de máquinas virtuales,
ya que no llevan dentro un Sistema operativo.

Eso me permite poder moverlas (copiarlas de una máquina a otra, descargarlas) en nada de tiempo.

Hay imágenes que las llamos IMAGENES BASE DE CONTENEDOR.
Esas imágenes no tienen dentro un programa que queda en ejeución: mariadb, tomcat.
Esas imágenes base lo que llevan es algunos comandos y carpetas instaladas de antemano.
Y usamos esas imágenes como punto de partida para montar otras imágenes.
Y heredamos todas las utilidades que las imágenes base tengan preinstaladas:

UBUNTU: Las 4 utilidades básicas que se montan por encima del kernel en una distro ubuntu
    - mkdir, cd, cp, mv
    - bash
    - apt/apt-get

FEDORA: Las 4 utilidades básicas que se montan por encima del kernel en una distro ubuntu
    - mkdir, cd, cp, mv
    - bash
    - yum / dnf
    
ALPINE:
    - mkdir, cd, cp, mv
    - sh

Todos los productos comerciales o de amplia difusión (apache httpd, tomcat, nginx, mysql, elastic, sonar, gitlab...)
los fabricantes me ofrecen ya imágenes de contenedor de serie. TODO PRODUCTO COMERCIAL se distribuye hoy en día mediante 
imágenes de contenedor.

Pero... y que pasa en una empresa, cuando monta su software (un microservicio). Voy a encontrar en docker hub una
imagen de MI microservicio?
Las empresas para sus programas crean sus propias imágenes de contenedor -> PRODUCTO DEL DESARROLLO
Antes, el producto de un desarrollo java era un .jar o un .war
Hoy en día el producto de un desarrollo java es una imágen de contenedor.

El desarrollo acaba generando una imagen de contenedor que lleve mi programa YA INSTALADO.
Pregunta, quién sabe instalar mi programa (que he montado YO como desarrollador)? YO que lo he desarrollado.

Y antiguamente, cuando trabajamos con metodologías tradicionales, que era una de las últimas cosas que hacíamos
en desarrollo? previo a la instalación? MANUAL DE INSTALACION

Claro.. que hoy en día, con las metodologías ágiles, vamos a instalar 50 veces... en pro y otras tantas (más) en pre.
Genero una imagen de contenedor y esa se despliega tanto en pro como en pre.
Y cada versión de mi programa la empaquetaré en una imagen de contenedor:
- miapp:1.0.0-alpine
- miapp:1.1.0-alpine

Antes generaba:
- miapp-1.0.0.jar
- miapp-1.1.0.jar

VAYA COÑAZO!!!
porque con los jar o war me ayudaba a generarlos en automático: maven
Bueno.. pues tendré que buscar a alguien que me ayude a generar las imágenes de contenedor en automático: docker

Y generaré imagen de contenedor de una versión concreta en la que estoy de mi producto...
Y es la mando para que se instale en un entono de pruebas.
POR CIERTO... si lo que se monte será ese archivo (IMAGEN) descomprimido... y ahí dentro va todo lo que mi app necesita
cuando pase de v1.0.0 a v1.1.0 cual será el procedimiento de instalación básicamente:
- Quita el contenedor que había creado con la imagen 1.0.0 y crea un contenedor nuevo con la imagen 1.1.0

Y si pasa en pruebas, qué hago con la imagen de contenedor? -> NEXUS
Y si automatizo ese proceso, que nombre recibía ese proceso? -> Entrega Continua (CONTINUOUS DELIVERY)
Y si saco la imagen de contenedor y la despliego en producción -> Despliegue Continuo (CONTINUOUS DEPLOYMENT)

Cuando se trabaja hoy en día con microservicios, un microservicio lo empaqueto en una IMAGEN DE CONTENEDOR = ENTREGABLE

Esa imagen de contenedor se usará para instalar mi producto (DESPLEGAR) en pre, pro....
Pero espera... y si necesito tener en un momento dado 50 instancias de mi aplicación en pro (ESCALAR), que necesito?
Descomprimir 50 veces el zip en 50 servidores
Pero espera... y si necesito tener en un momento dado 5 instancias de mi aplicación en pro (DESESCALAR), que necesito?
Cargarme esa carpeta descomprimida en 45 servidores

IDEAL !
Y es más, puedo automatizar ese proceso.. Siemrpe es igual... da igual el programa que haya dentro de esa imagen.
Y este trabajo es el que:
- En una máquina me hace una herramienta como DOCKER / PODMAN / RANCHER en automático
- En un cluster de máquinas me hace una herramienta como KUBERNETES en automático

---

# Vamos a usar docker como gestor de contenedores

Docker es una herramienta que al instalarla en nuestro computador instala 2 cosas por separado:
- Instala un servicio (DEMONIO DE DOCKER) que es quien se encarga de crear contenedores, borrarlos, monitorizarlos, 
    descargar imágenes de contenedor 
- Instala un cliente (comando docker) que nosotrtos usamos para mandar ordenes al demonio de docker

## Cómmo funciona el comando cliente de docker:

$ docker <TIPO_OBJETO> <VERBO> <args>

                                VERBOS
    TIPO_OBJETO:
        container   create      rm      ls  list      inspect     start   stop    restart
        image       build       rm      ls  list      inspect     pull
        ...

En docker prácticamente TODO COMANDO tiene un alias para poder ejecuarlo de forma más sencilla.

                                    ALIAS
    docker image ls                 docker images
    docker container list           docker ps
        SOLO MUESTRA CONTENEDORES EN EJECUCION
    docker container list -a           docker ps -a

Quiero descargar la imagen de contenedor de nginx version: 1.27.1

    docker container create --name minginx nginx:1.27.1
    docker container start minginx





---

Servidor web Apache httpd: SE USO UN HUEVO !!!!!
NGINX es u nproxy reverso con funcionaldiades de Servidor Web: El más usado del mundo a día de hoy

---

## Linux

No es un Sistema Operativo. Es el kernel de un Sistema Operativo.

Un sistema operativo no es un programa, es un montonón de programas (cientos o miles). 
En todo sistema operativo hay una parte (un conjunto de programas) que llamamos el Kernel.
El kernel hace todas las operaciones básicas de el SO:
- Control del hardware
- Control de procesos
- Control de seguridad(usuarios, permisos)
- Control del sistema de archivos

Hay muchos sistemas operativos (no tantos) que usan el kernel Linux:
- GNU/Linux -> Distribuciones de Linux: RedHat Enterprise Linux, Fedora, Ubuntu, Debian, Suse
  70%  30%
     ^
    Sistema operativo
- Android <- Sistema Operativo (tiene dentro el kernel de linux) + Añadieron librerias y otros los de google

## Windows

No es un Sistema Operativo. Es una familia de sistemas operativos:
- Windows 3     <- Esto es un Sistema operativo
- Windows 95    <- Esto es otro sistema operativo
- Windows NT
- Windows server 2016
- Windows 11

Al instalar un windows se instala:
- Un kernel? Microsoft ha creado 2 kernels en su historia y con ellos ha montado todos sus sistemas operativos
    - DOS -> MSDOS, Windows 3, Windows 95, Windows 98, Windows Millenium
    - NT(new technology) -> Windows NT, Windows 7, 8, 10, 11, XP, server
- Administrador de tareas
- Consola de sistema
- Power shell
- Programa para controlar archivos y carpetas: Explorador de Windows
- Sistema de Ventanas: Windows 7 (METRO) -> FluentDesign
- Tienda


---

ORACLE:
- Mysql             -> MariaDB
- OpenOffice (sun)  -> LibreOffice
- Hudson            -> Jenkins
- J2EE -> JEE       -> JEE (Jakarta Enterprise Edition)
    Colección de estandares apra montar apps con JAVA: JDBC, JMS, JPA   

SUN MICROSYSTEMS
- Máquina con arquitectura Sparc
- SO para esas máquinas: SOLARIS
- JAVA
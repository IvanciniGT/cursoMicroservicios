Un repositorio es como una BBDD que contiene código en sus distintas versiones, 
junto con información que permite en el futuro auditar o seguir la traza de los cambios que se
han ido haciendo en el codigo.

La herramienta más usada con diferencia a día de hoy para crear y gestionar repositorios es
GIT. GIT es un SCM (Source Code Manager) 

Ahora bien, git necesita unn sitio donde alojar repositorios para compartirlos entre personas:
Alojamientos de repositorios REMOTOS.

Hay muchos programas y servicios por internet (WEB) que nos ofrecen alojamiento 
de repositorios remotos de git: GITHUB

GITLAB, BITBUCKER (Atlassian)

---

# Comunicaciones con aplicaciones contenedorizadas

Un contenedor tiene su propia configuración de red... y su propia ip... o varias ips... PERO EN QUE REDES?

## Interfaces de red

Una interfaz de red es distinto de una red y otra cosa es la tarjeta que uso para conectarme a esa red (NIC)
    
                MAQUINA
              +---------------------------------+
              |      |                          |
-----red1-----+ NIC1 --  INTERFAZ RED 1 - IP    |
              |      \                          |
              |      |\- INTERFAZ RED 2 - IP    |
              |      |                          |
              +------|--------------------------+
                 HW  |   SO

En toda computadora qué interfaces de red tenemos? ( a nivel de SO)
- ethernet (Asociado a un NIC): IP del tipo 192.168.0.0/16 o 172.0.0.0 /8
- loopback: 127.0.0.0/16                    INTERFAZ VIRTUAL: No engancha a ninguna NIC, ni a ninguna RED
        127.0.0.1    <- En DNS interno de la máquina se le asocia el nombre "localhost"
    Esa red imaginaria (virtual) permite que distintos procesos dentro de mi máquina puedan comunicarse entre si.
- Docker, cuando se instala crea otra red VIRTUAL dentro de mi máquina, similar a la de loopback.
            Cuando vamos creando contenedores, esos contenedores docker los va pinchando en ese red... 
            y de esa red toman dirección IP

                    ------------------- MOVISTAR
                        |
                    8.0.98.123
                        |
                      router
                        |
                        192.168.09.189
                        |
    +-------------------+-----------------------------------+------- red de la empresa (192.168.0.0/16)
    |                                                       |
  192.168.23.28                                         MenchuPC (192.168.0.12)
    |                                                    - Para acceder al nginx de Ivan escribiría: 192.168.23.28:8888
    Ivan PC *            Cont: minginx1
      |  |                  |   nginx(master) 172.17.0.2:80
      |  172.17.0.1       172.17.0.2
      |  |                  |
      |  +------------------+--------------------------- docker
      |
    127.0.0.1 (localhost)
      |
      loopback (virtual)
    
    * En el IvanPC declaro un NAT: 192.168.23.28:8888 -> 172.17.0.2:80

Esto lo hacemos MUCHO !!!! de hecho SIEMPRE (99%)... y docker lo pone fácil:

    $ docker container create --name MINOMBRE -p IP_HOST:PUERTO_HOST:PUERTO_CONTENEDOR REPO_IMAGEN:TAG_IMAGEN
    
    Podemos obviar la IP_HOST... en ese caso se usa la máscara de red 0.0.0.0/0, que significa:
        EN TODAS LAS IPS DEL HOST

En muchos casos, no lo vamos a hacer porque queramos exponer fuera de la máquina los servicios. Ejemplo:
> Soy desarrollador y me monto un mariadb para mis desarrollos.. quiero tener una BBDD. Quiero exponerla a otros compañeros? NO
Entonces, necesito esto del NAT? A priori no... pero... no configurarlo implica que la única opción que tengo de atacar a la bbdd desde mi máquina sería:
MEDIANTE LA IP DEL CONTENEDOR. Y la conozco a priori? NO. Es más.. si tengo 5 contenedores en mi máquina, hoy un contenedor puede tener una IP y mañana otra.
Depende del orden de arranque de los contenedores.
Me compensa hacer un NAT al menos en localhost (127.0.0.1:3306 -> IP DEL CONTENEDOR:3306)

NOTA: Esto esta guay para entornos locales:
- Yo desarrollador para una BBDD o TOMCAT que monto
- Yo tester para instaalr una app del desarrolaldor en local y una BBDD y un selenium con CHROME y su webdriver
  y un entonto python desde el que ejecutar las pruebas contra el grid de selenium 
- Yo sysadmin en un entorno de producción para ejecutar un playbook de ansible que instale cierta paquetería en un servidor.

ESTO NO VALE PARA APPS que tengan que estar corriendo en entorno de PRODUCCION. Docker no vale para eso.

En un entorno de producción necesito Alta Disponibilidad -> Al menos 2 máquinas... y docker controla 1 máquina *
    * Hay una mierdecilla de producto llamada Docker swarm que permite montar clusters de máquinas y desplegar en ellas contenedores con algo de HA.
    QUE NO USA NI EL TATO => Para eso mejor un kubernetes, que ofrece 50 veces ... o 500 más funcionaldiad que ese Docker Swarm.

---

# Configuración de contenedores

Os dije que dentro de una imagen de contenedor viene un PROGRAMA YA INSTALADO, listo para su ejecución.
ME SIRVE? me refiero a esa instalación que ya a hecho alguien? No se... 
Hay muchas imágenes.. si no me vale una, buscaré una que si lo haga... aunque...
No creo que haya ninguna imagen de mariab por ahí en internete que venga preconfigurada con:
- El nombre de BBDD que quiero para mi proyecto
- El usuario de BBDD que quiero para mi proyecto
- La contraseña del usuario que quiero para mi proyecto
Es más, si la hubiera, no la quiero... NO JODAS una contraseña publicada en internet.

Los programas que se desarrollan pensando en que se van a poder ejecutar en contenedores, deben ofrecer formas de cambiar algunas cosas en la 
configuración de esos programas de forma dinámica.

    MONTO UN MICROSERVICIO (altaDeAnimalitos del Fermin)
        Se contectará con una BBDD.,, necesito la URL, la contraseña, el usuario
    Hombre... como voy a montar mi imagen, meto dentro mi URL, usuario y contraseña de BBDD y resuelto.
    Me vale? 
        A lo mejor si para el entorno de pre o de desarrollo
        Pero en pro, habrá otros datos... ES MAS, NO QUIERO NI SABER ESOS DATOS !
        
Hay 2 estrategias claramente usadas en la industria:

## Variables de entorno: Que el programa sea capaz de leer ciertos datos de variables de entorno.
    Al crear un contenedor, podemos darle valores a variables de entorno, especiales para ese contenedor (entorno aislado)
  El fabricante de una imagen me debe indicar QUE VARIABLES DE ENTORNO tengo disponibles para configurar, que sean leídas por el programa que ha hecho.


    docker image pull mariadb:11.6  # Esto no me haría falta ni ejecutarlo
    docker container create --name mimariadb -p 127.0.0.1:3307:3306 \
            -e MARIADB_ROOT_PASSWORD=superpassword \
            -e MARIADB_DATABASE=midb \
            -e MARIADB_USER=usuario \
            -e MARIADB_PASSWORD=password \
            mariadb:11.5

Ojo, las variables de entorno solo se pueden configurar al crear el contenedor.

Existe un estandar (un schema YAML: DOCKER COMPOSE) que permite definir de forma declarartiva PAQUETES de contenedores.
Posteriormente puedo pedirle a docker que cree o borre o arranque o pare todos los contenedores que tengo en ese YAML.
Y ese YAML, es un ficherito de texto supercómodo, que además subiré a GIT !

El esquema DOCKER COMPOSE es ampliamente soportado por todos los gestores de contenedores: PODMAN

docker compose up

## VOLUMENES

---

Los contenedores tienen la misma poersistencia que las máquinas o las máquinas virtuales.
Mientras no los borre, ahí tengo los datos.

El tema, aquí es que los contenedores NO SE USAN como se usan las máquinas o las máquinas virtuales.
Yo instalo una máquina o una máquina virtual... y la borro cuando? CUANDO YA NO HACDE FALTA PA NA'

Si tengo en una Máquina (virtual o no) instalado un MariaDB 14.8 y quiero pasar a MariaDB 15.0 que hago? Actualizar el MariaDB

Los contenedores los creamos y borramos con una alegría!!!!
Cada 5 minutos nuevo.. y quito otro!
El especialista número 1 en borrar contenedores: KUBERNETES

Los programas que vienen instalados dentro de una imagen de contenedor vienen preparados
para que yo pueda actualizar en automático de version 1 a version 2... o. a versión 2.1.
(NOTA: ME SUELEN OFRECER UN ROADMAP DE ACTUALIZACIONES 1.5-> 1.8 -> 2.0-> 2.4)

Si tengo un contenedor con MariaDB1 14.8 y quiero pasar a MariaDB 15.0... lo tengo clarito:
- PASO 1: Borro el contenedor MariaDB 14.8
- PASO 2: Creo un contenedor nuevo MariaDB 15.0
- PASO 3: CERVECITA !!!!

Y los datos???

# Volúmenes

Los volumenes en el mundo de los contenedores son:
- PUNTOS DE MONTAJE EN EL SISTEMA DE ARCHIVOS DEL CONTENEDOR (carpetas) cuya ubicación real
  está fuera del contenedor

A nivel de docker (en entornos locales) eso significa que tendré carpetas en el HOST, que compartiré (INYECTARÉ) dentro del contenedor. El contenedor podrá leer y/o escribir archivos en esas carpetas... Pero los archivos realmente se guardan a nivel del HOST.

A nivel de kubernetes (ya habermos de ello) es otra guerra.

    Cluster:
        Maquina 1 - OFFLINE                         VOLUMENES EN RED
            Contenedor: mariaDB             
        Maquina 2                                       - Datos del mariadb
            Contenedor: mariaDB                     VOLUMEN DE UN CLOUD 
                                                    CABINA DE ALMACENAMIENTO:
                                                        iscsi
                                                        nfs
                                                        fibrechannel

A nivel de docker básicamente:
    En el host tengo la carpeta "/home/ubuntu/datos"
    Y esa carpeta la hago visible en el contenedor en la ruta "/datos"

## Para qué sirven los volúmenes?

1. Persistencia de datos tras la eliminación del contenedor
2. Compartir ficheros entre contenedores
3. Inyectar archivos y carpetas desde el host: Por ejemplo:
        Voy a meter al mariadb mi propio archivo de configuración del servidor mariadb.  

Los fabricantes de imágenes me deben indicar qué carpetas del sistema de archivos del contenedor son susceptibles de ser montadas como volumenes.
---


## Comunicación entre procesos en un SO

- Shared Memory
- Sockets
- Redes y puertos
- Portapapeles

---

# Kubernetes no es un programa... ES UN ESTANDAR

Hay un huevo de programas que cumplen con kubernetes:
K8S: Kubernetes básico
K3S
Minikube
Openshift es una distro de kubernetes de la gente de redhat
Tamzú: Distro de kubernetes de la gente de VMWare
Karbon: Distro de kubernetes de la gente de Nutanix

---

Interfaces GRAFICAS: NO TOCAR PARA NADA... NINGUNA !
ODIOAMOS LAS INTERFACES GRAFICAS DE TODOS LOS PROGRAMAS DEL MUNDO
AMAMOS LAS PANTALLITAS NEGRAS Y SUS COMANDOS.

Las operaciones que hago en una interfaz grafica NO SON AUTOMATIZABLES !
Y vivimos en el mundo de la automatización.

Tampoco quiero estar tirando comanditos en una terminal.
Pero la gracia es que los comanditos que tiro en una termina, los puedo meter en un script.
Y lo que hago es ejecutar el script! = AUTOMATIZAR !


maven install
 Entre medias, me levante 3 contenedores, donde se hacen las pruebas en automático.
 Y que cuando acabe las pruebas, esos contenedores se borren

Y eso lo ejecuto yo en mi maquina y eso se ejecuta tamnbién en un servidor de pruebas.
Y toque o no botones en mi maquina, en el servidor no hay botones.
Y el script hace falta como sea.
Y si tengo script pa que voy a tocar botones.

---

# Vamos a tener un microservicio:

Servicio de Animalitos de la tienda del Fermín.
Esto lo tenemos programado en JAVA (-> C#, ----> JS, PYTHON)
                                          KOTLIN
GOOGLE NO PERDONÓ!
Una de las maniobras de googl fue extraer el motor de procesamiento de JS que habían desarrollado para el navegador CHROMIUM (Navegador Opernsource... base de Chrome, Edge, Safari, Opera) y lo convirtieron en un proyecto independiente... desligado de los navegadores: Node

Node es a JS lo que JVM es a JAVA.
Me permite ejecutar cualquier tipo de app creada con JS fuera de un navegador.
El JS de hoy no tiene NADA que ver con el JS de hace 15 años.
Es un lenguaje con una gramática tan potente o más que JAVA. 
En paralelo con eso, la ECMA generó un estandar de JS. De hecho el lenguaje ya no se llama JS. Su nombre real hoy en día es ECMASCRIPT. Además, se creo un lenguaje basado en JS... o mejor dicho que TRANSPILA a JS que aporta TIPADO ESTATICO RIGICDO (como JAVA) llamado TypeScript.

---

JAVA es una mierda de lenguaje que te cagas... en cuanto a su gramática. TIENE UNAS CAGADAS DEL 15.
Google, que quería dejar de depender de JAVA para Android encargó la creación de un lenguaje a la gente que montaba su entorno de desarrollo para Android (JetBrains: KOTLIN)

                    BYTE-CODE
    .java -> javac -> .class -> jvm
            compilación         interpretación
            
    Como lenguaje, JAVA ES RUINA !
    La arquitectura de la máquina virtual de JAVA, y el cosistema que existe en JAVA es BRUTAL !
        
    .scala -> scalac -> .class -> jvm           (LENGUAJE DEL BIGDATA)
    .kt   -> kotlinc -> .class -> jvm
    
    Kotlin o Scala son una alternativa a JAVA como lenguaje para generar Bytecode.
    Con una gramática que se mea en la de JAVA.
    
    Kotlin es especialmente bueno.
    
---
JAVA
  SPRING
  
---

# Spring

Framework de inversión de control. Y cómo tal, facilita la inyección de dependencias.

## Inversión de control: (.net core, angular)

Delegamos el flujo de la aplicación al framework. Con el framework hablamos en lenguaje DECLARATIVO
A spring le decimos que queremos montar una aplicación... y que la ejecute!
La función main() de una app spring es 1 linea de código: SpringApplitionRunner.run(MiApp.class)

A lo cuál Spring me pregunta... y que cojones hace tu app?
Nosotros se lo explicamos:
- Mi app debe tener un repositorio para guardar Animalitos.
- Un animalito tiene edad, nombre, tipo.
- Ah.. y quiero un servicio con estas funciones: 
    - nuevo Animalito
    - recuperar Animalitos
- Ah y quiero pode exponer ese servicio como REST.

A por ello campeón!

SPRING nos ayuda a desarrollar código que cumpla con PRINCIPIOS SOLID de desarrollo de software.

El problema grande de construir un software NO ES CONSTRUIR UN SOFTWARE. El problema es mantenerlo y evolucionarlo.
AQUI ES DONDE ESTABA LA PERDIDA DE PASTA GORDA EN LAS EMPRESAS !
S - Single responsability
O - OpenClosed
L - Liskov
I - Segregación de la interfaz
D - Inversión de la dependencia:

    Una clase no puede depender de otra clase:
    En una clase no puedo meter en los imports otra clase... solo interfaces

    Otra tema distinto es cómo hago yo para que mi código cumpla o no con ese principio (con esa regla).
    Aquí echamos mano de patrones de desarrollo de software:
    - Patrón Factory
    - Otro patrón, que es el que adoramos hoy en día (por copnseguir de forma mucho sencilla respectar el ppo de inversión de la dependencia) es el patrón de inyección de dependencias... y Spring me lo pone a huevo por ser un framework de inversión de control.
    
    Esto me permite montar un sistema con componentes MUY DESACOPLADOS.
    Básicamente es romper el monolito no a nivel de aplicación (ARQUITECTURA) sono a bajo nivel (COMPONENTES: paquetes/clases)
    
    CUIDADO... que esto es otro berenjenal. Montar una app así los primeros semanas/meses me cuesta mucho mucho mucho mucho más que montar un código con alto nivel de acoplameiento.
    
    Al medio plazo lo he más que amortizado.
    
Muchos estáis en desarrollos WEB -> .ear .war
ESO YA MURIÓ!

Con Spring lo que generamos es un .jar (que lleva embedido un tomcat)
Y porque un tomcat? porque me sobra. No voy a montar un megasistema que necesite de un megaservidor de aplicaciones.

Esto montando un MICROSERVICIO = PROGRAMILLA DE MIERDA CON 7 clases. y el tomcat lo peta,... y es gratis. Y LIGERO

Otro tema importante y que cambia en el mundo de los microservicios con respecto a las apps tradicionales WEB es que son STATELESS.

Las apps web tradicionales usaban el concepto de SESSION: HttpSession

Cuando un usuario conectaba con el servidor de apps la primera vez, el servidor de apps creaba una sesión para ese usuario.
Básicamente una sesión era un mapa clave/valor, que se identificaba (la sesión) por un id/token.
Ese token lo entregaba el servidor de aplicaciones al cliente mediante una cookie.
Y cada vez que el cliente hacía una petición al servidor mandaba el token (de la cookie).

TODO ESTO MURIO!
Las sesiones eran una putada:
- Necesitaba un huevo de RAM en servidor
- Y además complicaban el procesamiento en el servidor (Se responsabilizaba de la sesión)

HOY EN DIA la "sesion" la guarda el cliente.
En servidor no se guarda NADA de una petición
CADA PETICION ES LIMPIA empieza de CERO.
Y autocontiene todo lo necesario para que sea procesada.

ESTO implica a su vez que la forma de autenticarse y guardar los datos del usuairo HA CAMBIADO TOTALMENTE: 
JWT: JSON Web Token

IAM: Identity & Autorization Providers -> JWT
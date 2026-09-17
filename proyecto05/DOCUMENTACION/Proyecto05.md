# Proyecto 5 – Organización y Arquitectura de Computadores

## 1. Introducción

El Proyecto 5 corresponde a la construcción de los componentes principales de la plataforma Hack mediante HDL. El objetivo es implementar una memoria de datos, una CPU capaz de ejecutar instrucciones Hack y el computador que integra la memoria de programa, la CPU y la memoria de datos.

Los componentes desarrollados son:

- `Memory.hdl`
- `CPU.hdl`
- `Computer.hdl`

Estos componentes permiten construir una computadora funcional capaz de almacenar instrucciones, ejecutar programas Hack, realizar operaciones mediante la ALU y comunicarse con la memoria y los dispositivos de entrada/salida.

## 2. Memory

### 2.1 Función del componente

El chip `Memory` administra el acceso a la memoria de datos y a los dispositivos de entrada/salida del computador Hack.

Recibe un dato de entrada (`in[16]`), una señal que indica si se debe escribir (`load`) y una dirección de 15 bits (`address[15]`). Con esta información determina dónde debe realizarse la operación y entrega en `out` el valor correspondiente a la dirección solicitada.

### 2.2 Distribución de direcciones

La memoria utiliza los 15 bits de la dirección para seleccionar el dispositivo correspondiente:

| Rango de direcciones | Dispositivo | Función |
|:-:|:-:|:-:|
| `0 – 16383` | `RAM16K` | Memoria de datos |
| `16384 – 24575` | `Screen` | Memoria asociada a la pantalla |
| `24576` | `Keyboard` | Lectura del teclado |

Esta división permite que una misma interfaz de memoria pueda utilizarse tanto para almacenar datos como para comunicarse con los dispositivos de entrada y salida.

### 2.3 Selección de dispositivos

Para saber qué dispositivo debe utilizarse, se revisan principalmente los bits más significativos de la dirección.

La selección se realiza mediante `DMux`. Primero, `address[14]` separa la RAM del espacio de entrada/salida:

```text
address[14] = 0 → RAM16K
address[14] = 1 → I/O
```

Cuando se selecciona I/O, `address[13]` diferencia entre pantalla y teclado:

```text
address[13] = 0 → Screen
address[13] = 1 → Keyboard
```

Esta organización permite dirigir la señal `load` únicamente al dispositivo que admite operaciones de escritura, mientras que el `Keyboard` se utiliza únicamente para lectura.

### 2.4 Lectura de memoria

Para leer un dato, el circuito toma las salidas de `RAM16K`, `Screen` y `Keyboard` y utiliza multiplexores (`Mux16`) para elegir cuál de ellas debe llegar a la salida `out`.

El proceso puede entenderse de la siguiente manera

```text
                  address[14]
                       │
              ┌────────┴────────┐
              │                 │
              ▼                 ▼
           RAM16K              I/O
              │                 │
              │            address[13]
              │                 │
              │          ┌──────┴──────┐
              │          │             │
              │          ▼             ▼
              │       Screen       Keyboard
              │          │             │
              │          └──────┬──────┘
              │                 │
              │              Mux16
              │                 │
              └────────┬────────┘
                       │
                     Mux16
                       │
                      out
```

### 2.5 Escritura de memoria

La señal `load` indica si se debe guardar el dato recibido en `in`.

Cuando `load` está activa, el circuito utiliza `DMux` para enviar la señal de escritura al dispositivo seleccionado por la dirección:

- `loadRAM` permite escribir en `RAM16K`.
- `loadScreen` permite escribir en `Screen`.
- El `Keyboard` no recibe una señal de escritura porque funciona como dispositivo de entrada.

Esto evita que una operación de escritura afecte a un dispositivo diferente del que corresponde.

### 2.6 Decisiones de diseño

La implementación utiliza `DMux` para distribuir la señal de escritura y `Mux16` para seleccionar el dato que debe salir de la memoria.

También se utilizan directamente los componentes `RAM16K`, `Screen` y `Keyboard`. De esta manera, cada componente mantiene su función específica y `Memory` se concentra en decidir a cuál de ellos debe accederse.

## 3. CPU

### 3.1 Función

El chip `CPU` es el encargado de interpretar y ejecutar las instrucciones de la arquitectura Hack.

Para hacerlo, recibe la instrucción actual, el dato proveniente de la memoria y la señal `reset`. A partir de estos valores decide qué operación realizar, qué registros actualizar, si debe escribir en memoria y cuál será la siguiente instrucción.

Sus principales salidas son:

- `outM`: dato que puede escribirse en memoria.
- `writeM`: indica si se debe realizar una escritura.
- `addressM`: dirección utilizada para acceder a memoria.
- `pc`: dirección de la siguiente instrucción.

### 3.2 Identificación de instrucciones

La CPU distingue entre los dos tipos de instrucciones Hack observando el bit más significativo:

```text
instruction[15] = 0 → instrucción A
instruction[15] = 1 → instrucción C
```

En una instrucción A, los bits `instruction[14..0]` se cargan en el registro A.

En una instrucción C se utilizan los campos de cálculo, destino y salto para controlar la ALU, los registros, la memoria y el flujo de ejecución.

### 3.3 Registro A

El registro A puede recibir dos tipos de valores:

1. El valor de una instrucción A.
2. El resultado de la ALU cuando una instrucción C tiene habilitado el destino A.

Un `Mux16` selecciona cuál de estos valores se entrega al registro. La señal de carga combina la detección de una instrucción A con la condición de que una instrucción C tenga A como destino.

El contenido de A también se utiliza como dirección de memoria y como posible destino del `PC` durante un salto.

### 3.4 Registro D

El registro D almacena resultados que pueden ser utilizados posteriormente por la CPU.

Cuando una instrucción C indica que el resultado debe guardarse en D, se habilita la carga del registro D:

```text
instrucción C + instruction[4] = 1
→ DRegister recibe aluOut
```

El contenido de D también se utiliza como una de las entradas de la ALU.

### 3.5 Entrada de ALU

La ALU recibe:

```text
x = D
y = A o inM
```

La selección depende de `instruction[12]`:

```text
instruction[12] = 0 → y = A
instruction[12] = 1 → y = inM
```

En este último caso, `inM` representa el valor entregado por Memory desde la dirección indicada por A.

### 3.6 Control de ALU

Los bits de la instrucción C controlan las operaciones realizadas por la ALU:

- `zx`: pone la entrada X en cero.
- `nx`: niega X.
- `zy`: pone la entrada Y en cero.
- `ny`: niega Y.
- `f`: selecciona la operación principal.
- `no`: niega la salida.

Estos bits se conectan directamente con las entradas de control de la ALU:

```text
zx = instruction[11]
nx = instruction[10]
zy = instruction[9]
ny = instruction[8]
f  = instruction[7]
no = instruction[6]
```

El resultado de la ALU puede utilizarse para actualizar los registros, enviarse a memoria o determinar si debe realizarse un salto.

Además, la ALU genera dos señales que ayudan a tomar decisiones sobre el resultado:

```text
zr → resultado igual a cero
ng → resultado negativo
```

### 3.7 Escritura en memoria

Cuando una instrucción necesita guardar un resultado en memoria, la CPU utiliza tres señales para comunicarse con `Memory`:

```text
outM     → dato que se desea guardar
writeM   → indica que se debe escribir
addressM → dirección donde se guardará el dato
```

El dato que se escribe corresponde al resultado de la ALU:

```text
outM = aluOut
```

La dirección de memoria corresponde al contenido actual del registro A:

```text
addressM = A
```

La señal `writeM` se activa cuando una instrucción C tiene a `M` como destino:

```text
writeM = isCInstruction AND instruction[3]
```

Así, la CPU solo solicita una escritura cuando la instrucción realmente lo indica.

### 3.8 Condiciones de salto

Las instrucciones C pueden cambiar el orden normal de ejecución mediante saltos.

Para decidir si debe realizarse un salto, la CPU utiliza las señales `zr` y `ng` generadas por la ALU.

Las principales condiciones son:

**JGT**

El resultado es mayor que cero cuando no es cero y tampoco es negativo:

```text
JGT = !zr AND !ng
```

**JEQ**

El resultado es igual a cero cuando:

```text
JEQ = zr
```

**JLT**

El resultado es menor que cero cuando:

```text
JLT = ng
```

Los tres bits de salto de la instrucción indican qué condición debe comprobarse:

```text
instruction[2] → JLT
instruction[1] → JEQ
instruction[0] → JGT
```

La CPU combina los bits de salto con las condiciones generadas por la ALU. Si alguna de las condiciones indicadas por la instrucción se cumple, se activa `shouldJump` y posteriormente `loadPC`, haciendo que el `PC` cargue la dirección almacenada en el registro A.

### 3.9 Program Counter

El `PC` indica qué instrucción debe ejecutarse a continuación.

Su comportamiento puede resumirse así:

```text
reset = 1  → PC = 0
salto      → PC = A
sin salto  → PC = PC + 1
```

Por lo tanto, normalmente el programa avanza de una instrucción a la siguiente. Si se cumple una condición de salto, el `PC` cambia y comienza la ejecución desde la dirección almacenada en A.

### 3.10 Flujo de ejecución

El funcionamiento general de la CPU puede resumirse así:

```text
              instruction
                   │
                   ▼
          ┌────────────────┐
          │ Decodificación │
          └────────┬───────┘
                   │
        ┌──────────┼──────────┐
        ▼          ▼          ▼
   Registro A   Registro D   Jump
        │          │          │
        └──────┬───┘          │
               ▼              │
             ALU ─────────────┘
               │
       ┌───────┼────────┐
       ▼       ▼        ▼
     outM    Registros  PC
       │                 │
       ▼                 ▼
    Memory          instruction
```
La CPU recibe una instrucción, decide qué significa, realiza la operación correspondiente y determina qué debe ocurrir después. Si la operación necesita utilizar memoria, la CPU se comunica con `Memory`; si la instrucción contiene un salto válido, el `PC` cambia de dirección.

### 3.11 Decisiones de diseño

La CPU mantiene separadas las funciones de registros, ALU, acceso a memoria y control de saltos. Las condiciones de salto se construyen directamente a partir de `zr` y `ng`.

La dirección de memoria corresponde al contenido actual del registro A y el dato de escritura corresponde a `aluOut`, manteniendo claras las conexiones con `Memory`.

## 4. Computer

### 4.1 Función

El chip `Computer` reúne los componentes anteriores para formar el computador Hack completo.

Está compuesto por:

- `ROM32K`
- `CPU`
- `Memory`

Cada uno cumple una función diferente: la ROM contiene las instrucciones del programa, la CPU las ejecuta y `Memory` permite almacenar y consultar datos.

### 4.2 Memoria de instrucciones ROM32K

La `ROM32K` almacena el programa que debe ejecutar la computadora.

La dirección que utiliza la ROM proviene del contador de programa de la CPU:

```text
PC → ROM32K → instruction
```

De esta forma, el `PC` indica qué posición de la ROM debe consultarse y la ROM entrega la instrucción correspondiente a la CPU.

### 4.3 Conexión con CPU

La CPU recibe la instrucción de la ROM mediante `instruction`. También recibe desde `Memory` el dato que necesita cuando una instrucción utiliza una posición de memoria.

A partir de esta información, la CPU genera las señales necesarias para comunicarse con `Memory` y para indicar la siguiente instrucción:

```text
outM     → dato para Memory
writeM   → señal de escritura
addressM → dirección de Memory
pc       → dirección utilizada por ROM32K
```

### 4.4 Conexión con Memory

La comunicación entre la CPU y la memoria se realiza mediante cuatro señales principales:

```text
CPU outM     → Memory in
CPU writeM   → Memory load
CPU addressM → Memory address
Memory out   → CPU inM
```

Esto permite que la CPU pueda enviar una dirección y, si es necesario, un dato para escribir. Cuando necesita leer, `Memory` devuelve el contenido de la dirección solicitada mediante `inM`.

### 4.5 Flujo completo del computador

El flujo de información entre los componentes es:

```text
                 ┌─────────────┐
                 │   ROM32K    │
                 └──────┬──────┘
                        │ instruction
                        ▼
                  ┌───────────┐
                  │    CPU    │
                  └─────┬─────┘
             ┌──────────┼──────────┐
             │          │          │
           outM       writeM    addressM
             │          │          │
             └──────────┼──────────┘
                        ▼
                  ┌───────────┐
                  │  Memory   │
                  └─────┬─────┘
                        │ inM
                        ▼
                       CPU
```

El ciclo de ejecución puede explicarse así:

1. El `PC` indica qué instrucción debe buscarse.
2. `ROM32K` entrega esa instrucción.
3. La CPU la interpreta y la ejecuta.
4. Si necesita acceder a datos, la CPU se comunica con `Memory`.
5. `Memory` devuelve el dato solicitado o realiza la escritura indicada.
6. La CPU determina cuál será la siguiente instrucción.
7. El proceso continúa.

### 4.6 Señal reset

La señal `reset` se conecta a la CPU y permite reiniciar el flujo de ejecución.

Cuando `reset` está activo, el contador de programa vuelve a cero:

```text
reset = 1 → PC = 0
```

Esto hace que, al comenzar nuevamente la ejecución, el computador vuelva a buscar instrucciones desde el inicio de la ROM.

### 4.7 Decisiones de diseño

La implementación de `Computer` no duplica la lógica interna de los componentes. Su función principal es realizar las conexiones necesarias entre `ROM32K`, `CPU` y `Memory`.

Esta organización permite mantener una arquitectura modular y facilita verificar cada componente de manera independiente antes de realizar la integración completa.

## 5. Conclusiones

El Proyecto 5 permite completar la estructura básica del computador Hack mediante la integración de `Memory`, `CPU` y `Computer`.

`Memory` se encarga de dirigir los accesos hacia la RAM y los dispositivos de entrada y salida. `CPU` interpreta las instrucciones, realiza las operaciones necesarias y controla el flujo de ejecución. Finalmente, `Computer` conecta estos componentes con `ROM32K` para que las instrucciones almacenadas puedan ejecutarse y utilizar la memoria de datos.
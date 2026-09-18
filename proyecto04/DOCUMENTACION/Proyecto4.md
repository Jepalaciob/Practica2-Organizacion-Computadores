# Proyecto 4 – Organización y Arquitectura de Computadores

## 1. Introducción

El Proyecto 4 corresponde al desarrollo de programas en lenguaje ensamblador para la plataforma Hack.

El objetivo es comprender cómo un programa puede utilizar los registros, la memoria, las instrucciones de salto y el direccionamiento para implementar operaciones y algoritmos directamente sobre la arquitectura Hack.

Los programas desarrollados son:

- `Mult.asm`
- `Fill.asm`
- `SumN.asm`
- `CopyBlock.asm`

Los dos primeros corresponden a programas del Proyecto 4 de Nand2Tetris, mientras que `SumN.asm` y `CopyBlock.asm` son programas adicionales desarrollados para la práctica.

Estos programas permiten trabajar con operaciones aritméticas, estructuras iterativas, acceso a memoria, direccionamiento indirecto y dispositivos de entrada y salida.

---

## 2. Mult

### 2.1 Función del programa

El programa `Mult.asm` realiza la multiplicación de dos números almacenados en memoria.

Las entradas se encuentran en:

```text
RAM[0] → primer número
RAM[1] → segundo número
```

El resultado se almacena en:

```text
RAM[2] → resultado de la multiplicación
```

Por ejemplo:

```text
RAM[0] = 3
RAM[1] = 4

RAM[2] = 12
```

La multiplicación se implementa mediante sumas repetidas.

---

### 2.2 Uso de memoria

El programa utiliza las siguientes posiciones:

| Posición | Nombre | Función |
|:-:|:-:|:-|
| `RAM[0]` | `R0` | Primer operando |
| `RAM[1]` | `R1` | Segundo operando |
| `RAM[2]` | `R2` | Resultado |
| `RAM[16]` | `resultado` | Acumulador temporal |
| `RAM[17]` | `j` | Contador de iteraciones |

Las posiciones `RAM[16]` y `RAM[17]` son asignadas automáticamente por el assembler a las variables simbólicas `resultado` y `j`.

---

### 2.3 Inicialización

Antes de realizar la multiplicación se limpia el acumulador:

```asm
@resultado
M=0
```

Esto permite que el programa no dependa del contenido anterior de esa posición de memoria.

Posteriormente se consulta `R0`:

```asm
@R0
D=M

@cl
D;JEQ
```

Si el primer operando es cero, se salta directamente al caso especial donde el resultado se establece en cero.

El mismo procedimiento se realiza para `R1`.

---

### 2.4 Multiplicación

El valor de `R1` se utiliza como contador:

```asm
@R1
D=M

@j
M=D
```

En cada iteración se suma `R0` al acumulador:

```asm
@R0
D=M

@resultado
M=D+M
```

Después se disminuye el contador:

```asm
@j
M=M-1
D=M
```

Mientras `j` sea diferente de cero, el programa regresa al ciclo:

```asm
@mult
D;JNE
```

El funcionamiento puede representarse como:

```text
resultado = 0
j = R1

mientras j != 0:
    resultado = resultado + R0
    j = j - 1
```

---

### 2.5 Resultado

Cuando termina el ciclo, el acumulador se copia a `R2`:

```asm
@resultado
D=M

@R2
M=D
```

Por ejemplo:

```text
R0 = 6
R1 = 7

resultado:
R2 = 42
```

---

### 2.6 Manejo del cero

Si cualquiera de los operandos es cero, el programa entra en la sección:

```asm
(cl)
    @R2
    M=0
```

Esto permite manejar correctamente casos como:

```text
0 × 5 = 0
5 × 0 = 0
0 × 0 = 0
```

---

### 2.7 Limpieza de variables

Después de guardar el resultado, las variables auxiliares se limpian:

```asm
(clean)
    @resultado
    M=0

    @j
    M=0
```

El resultado almacenado en `R2` no se modifica.

---

### 2.8 Flujo general

```text
       R0          R1
        │           │
        └─────┬─────┘
              │
              ▼
        ¿Alguno es 0?
          │       │
         Sí       No
          │       │
          ▼       ▼
       R2 = 0    j = R1
                  │
                  ▼
          resultado += R0
                  │
                  ▼
               j = j - 1
                  │
            ┌─────┴─────┐
            │           │
          j != 0      j = 0
            │           │
            └── loop    ▼
                     R2 = resultado
```

---

## 3. Fill

### 3.1 Función del programa

El programa `Fill.asm` utiliza el teclado y la memoria de pantalla de la plataforma Hack.

Su comportamiento es:

```text
Si no se presiona ninguna tecla:
→ la pantalla se pinta de blanco

Si se presiona una tecla:
→ la pantalla se pinta de negro
```

El programa se ejecuta continuamente, por lo que detecta cambios en el teclado durante la ejecución.

---

### 3.2 Memoria de pantalla

La pantalla Hack está representada mediante memoria.

El programa recorre las direcciones:

```text
RAM[16384] → inicio de SCREEN
...
RAM[24575] → última posición de SCREEN
```

El símbolo:

```asm
@SCREEN
```

representa la dirección:

```text
16384
```

---

### 3.3 Teclado

El teclado se encuentra en:

```text
RAM[24576]
```

y se accede utilizando:

```asm
@KBD
D=M
```

Cuando:

```text
KBD = 0
```

no hay ninguna tecla presionada.

Cuando:

```text
KBD != 0
```

hay una tecla presionada.

---

### 3.4 Uso de memoria

El programa utiliza:

| Posición | Nombre | Función |
|:-:|:-:|:-|
| `RAM[16]` | `pos` | Dirección actual de la pantalla |
| `RAM[16384..24575]` | `SCREEN` | Memoria de la pantalla |
| `RAM[24576]` | `KBD` | Estado del teclado |

La variable `pos` se utiliza como un puntero para recorrer la memoria de pantalla.

---

### 3.5 Inicialización

El programa comienza obteniendo la primera dirección de la pantalla:

```asm
@SCREEN
D=A

@pos
M=D
```

Por lo tanto:

```text
pos = 16384
```

---

### 3.6 Pintar de blanco

Cuando no existe una tecla presionada, se ejecuta el ciclo `white`.

Para escribir blanco se utiliza:

```asm
@pos
A=M
M=0
```

El valor:

```text
0
```

hace que los 16 píxeles representados por esa palabra de memoria aparezcan blancos.

Después se incrementa la posición:

```asm
@pos
M=M+1
```

y se vuelve a comprobar el teclado.

---

### 3.7 Pintar de negro

Si se detecta una tecla, el programa cambia al ciclo `black`.

Para escribir negro se utiliza:

```asm
@pos
A=M
M=-1
```

El valor `-1` en una palabra de 16 bits corresponde a:

```text
1111111111111111
```

por lo que los 16 píxeles representados por esa posición aparecen negros.

Posteriormente se incrementa `pos` y se continúa recorriendo la pantalla.

---

### 3.8 Control del límite de pantalla

Antes de escribir se verifica que `pos` no haya superado la última dirección válida:

```asm
@pos
D=M

@24575
D=A-D

@reset
D;JLT
```

Cuando `pos` supera `24575`, se ejecuta `reset`.

---

### 3.9 Reinicio del recorrido

La sección:

```asm
(reset)
```

vuelve a colocar:

```text
pos = SCREEN
```

es decir:

```text
pos = 16384
```

Después vuelve a consultar el teclado para decidir si debe continuar pintando de blanco o de negro.

---

### 3.10 Flujo general

```text
                  Inicio
                    │
                    ▼
              pos = SCREEN
                    │
                    ▼
              Consultar KBD
               │         │
            KBD = 0    KBD != 0
               │         │
               ▼         ▼
            WHITE       BLACK
               │         │
          RAM[pos]=0  RAM[pos]=-1
               │         │
               └────┬────┘
                    │
                pos = pos+1
                    │
                    ▼
             ¿Fin de SCREEN?
               │         │
              No         Sí
               │         │
               └──loop   ▼
                     pos=SCREEN
```

---

## 4. SumN

### 4.1 Función del programa

El programa `SumN.asm` calcula la suma de los primeros `N` números naturales.

La entrada se encuentra en:

```text
RAM[0] = N
```

y el resultado se almacena en:

```text
RAM[1]
```

Por ejemplo:

```text
RAM[0] = 5

RAM[1] = 15
```

porque:

```text
1 + 2 + 3 + 4 + 5 = 15
```

---

### 4.2 Uso de memoria

El programa utiliza:

| Posición | Nombre | Función |
|:-:|:-:|:-|
| `RAM[0]` | `R0` | Valor de entrada `N` |
| `RAM[1]` | `R1` | Resultado |
| `RAM[16]` | `sum` | Acumulador |
| `RAM[17]` | `N` | Contador auxiliar |

---

### 4.3 Inicialización

Antes de realizar la suma se limpia el acumulador:

```asm
@sum
M=0
```

Después se obtiene el valor de entrada:

```asm
@R0
D=M
```

Si el valor es cero:

```asm
@cl
D;JEQ
```

se salta directamente a la sección final.

---

### 4.4 Contador

El valor de `R0` se copia a la variable `N`:

```asm
@N
M=D
```

Esta variable funciona como contador y disminuye durante cada iteración.

---

### 4.5 Acumulación

El ciclo realiza:

```asm
@N
D=M
M=M-1

@sum
M=D+M
```

Primero se obtiene el valor actual de `N`.

Después:

```text
sum = sum + N
```

y el contador disminuye en uno.

El proceso puede representarse como:

```text
sum = 0
N = RAM[0]

mientras N != 0:
    sum = sum + N
    N = N - 1
```

---

### 4.6 Resultado

Cuando `N` llega a cero, el valor acumulado se guarda en `R1`:

```asm
@sum
D=M
M=0

@R1
M=D
```

Al mismo tiempo se limpia la variable auxiliar `sum`.

---

### 4.7 Ejemplos

```text
N = 0
resultado = 0
```

```text
N = 1
resultado = 1
```

```text
N = 5
resultado = 15
```

```text
N = 10
resultado = 55
```

---

### 4.8 Flujo general

```text
              RAM[0] = N
                   │
                   ▼
               sum = 0
                   │
                   ▼
               ¿N = 0?
               │      │
              Sí      No
               │      │
               │      ▼
               │   sum += N
               │      │
               │    N = N-1
               │      │
               │      └── loop
               ▼
          RAM[1] = sum
```

---

## 5. CopyBlock

### 5.1 Función del programa

El programa `CopyBlock.asm` copia un bloque de posiciones de memoria desde una dirección de origen hacia una dirección de destino.

Las entradas son:

```text
RAM[0] = dirección de origen
RAM[1] = dirección de destino
RAM[2] = cantidad de posiciones
```

Por ejemplo:

```text
RAM[0] = 100
RAM[1] = 200
RAM[2] = 3
```

Si:

```text
RAM[100] = 7
RAM[101] = 9
RAM[102] = 4
```

después de ejecutar el programa:

```text
RAM[200] = 7
RAM[201] = 9
RAM[202] = 4
```

---

### 5.2 Uso de memoria

El programa utiliza:

| Posición | Nombre | Función |
|:-:|:-:|:-|
| `RAM[0]` | `R0` | Dirección inicial del origen |
| `RAM[1]` | `R1` | Dirección inicial del destino |
| `RAM[2]` | `R2` | Número de posiciones que se deben copiar |
| `RAM[16]` | `orig` | Puntero actual del origen |
| `RAM[17]` | `dest` | Puntero actual del destino |
| `RAM[18]` | `N` | Cantidad restante de posiciones |

---

### 5.3 Inicialización del origen

Primero se obtiene la dirección almacenada en `R0`:

```asm
@R0
D=M

@orig
M=D
```

Por ejemplo:

```text
R0 = 100
→ orig = 100
```

La variable `orig` funciona como un puntero que indica qué posición se debe leer.

---

### 5.4 Inicialización del destino

De forma similar:

```asm
@R1
D=M

@dest
M=D
```

Por ejemplo:

```text
R1 = 200
→ dest = 200
```

---

### 5.5 Cantidad de posiciones

El valor de `R2` indica cuántas posiciones deben copiarse:

```asm
@R2
D=M
```

Si:

```text
R2 = 0
```

el programa termina sin realizar ninguna copia:

```asm
@end
D;JEQ
```

En caso contrario, el valor se guarda en `N`:

```asm
@N
M=D
```

---

### 5.6 Lectura mediante direccionamiento indirecto

Una de las partes principales del programa es:

```asm
@orig
D=M
M=M+1

A=D
D=M
```

Primero:

```text
D = orig
```

y después el puntero `orig` se incrementa.

La instrucción:

```asm
A=D
```

hace que el registro A contenga la dirección de origen.

Luego:

```asm
D=M
```

lee el contenido almacenado en esa dirección.

Por ejemplo:

```text
orig = 100
RAM[100] = 7
```

produce:

```text
D = 7
orig = 101
```

---

### 5.7 Escritura mediante direccionamiento indirecto

El dato leído se guarda utilizando:

```asm
@dest
A=M
M=D
```

Si:

```text
dest = 200
D = 7
```

entonces:

```text
RAM[200] = 7
```

Después se incrementa el puntero de destino:

```asm
@dest
M=M+1
```

---

### 5.8 Control del ciclo

Después de cada copia se disminuye `N`:

```asm
@N
M=M-1
D=M
```

Mientras todavía queden posiciones:

```asm
@loop
D;JNE
```

se repite el proceso.

El funcionamiento puede representarse como:

```text
orig = RAM[0]
dest = RAM[1]
N = RAM[2]

mientras N != 0:
    RAM[dest] = RAM[orig]

    orig = orig + 1
    dest = dest + 1
    N = N - 1
```

---

### 5.9 Limpieza de variables

Después de completar la copia se limpian las variables auxiliares:

```asm
@orig
M=0

@dest
M=0

@N
M=0
```

Las posiciones originales:

```text
R0
R1
R2
```

no son modificadas por el programa.

---

### 5.10 Flujo general

```text
       RAM[0]         RAM[1]        RAM[2]
       origen         destino          N
          │              │             │
          ▼              ▼             ▼
        orig           dest            N
          │              │             │
          └───────┬──────┘             │
                  │                    │
                  ▼                    │
            D = RAM[orig]              │
                  │                    │
                  ▼                    │
           RAM[dest] = D               │
                  │                    │
          ┌───────┴────────┐           │
          ▼                ▼           ▼
    orig = orig+1    dest = dest+1   N=N-1
          │                │           │
          └────────────────┴─────┬─────┘
                                 │
                              N != 0
                              │     │
                             Sí     No
                              │     │
                            loop    ▼
                                  fin
```

---

## 6. Pruebas

Las pruebas del Proyecto 4 se realizaron utilizando el simulador de CPU de la plataforma Hack.

Las evidencias se encuentran almacenadas en:

```text
proyecto04/TESTS/
```

Actualmente el repositorio contiene pruebas para los cuatro programas desarrollados.

### 6.1 Pruebas de Mult

Para `Mult.asm` se verifican diferentes combinaciones de operandos, incluyendo casos donde alguno de los valores es cero y multiplicaciones normales.

Las evidencias se encuentran en:

```text
Mult 1.png
Mult 2.png
Mult 3.png
Mult 4.png
```

Las pruebas permiten comprobar:

```text
R0 × R1 → R2
```

incluyendo el manejo correcto del caso cero.

---

### 6.2 Pruebas de Fill

Para `Fill.asm` se comprueban los dos estados principales:

```text
Sin tecla presionada → pantalla blanca
Tecla presionada     → pantalla negra
```

Las evidencias se encuentran en:

```text
Fill 1.png
Fill 2.png
```

En la segunda captura no se muestra visualmente la tecla presionada debido a que al tomar la captura se pierde la selección del simulador. La prueba fue realizada presionando la tecla `c`.

---

### 6.3 Pruebas de SumN

Para `SumN.asm` se realizaron pruebas con diferentes valores de `N`.

Las evidencias se encuentran en:

```text
SumN 1.png
SumN 2.png
SumN 3.png
```

El comportamiento esperado es:

```text
RAM[0] = N
RAM[1] = 1 + 2 + ... + N
```

---

### 6.4 Pruebas de CopyBlock

Para `CopyBlock.asm` se realizaron pruebas de copia entre diferentes posiciones de memoria.

Las evidencias se encuentran en:

```text
CopyBlock 1.1.png
CopyBlock 1.2.png
CopyBlock 1.3.png
CopyBlock 2.1.png
CopyBlock 2.2.png
```

Estas pruebas permiten observar las posiciones de memoria antes y después de ejecutar el programa y verificar que los valores del bloque de origen son copiados correctamente al bloque de destino.

---

## 7. Uso del direccionamiento en los programas

Los cuatro programas utilizan diferentes formas de acceder a la memoria.

### 7.1 Direccionamiento directo

En instrucciones como:

```asm
@R0
D=M
```

el programa accede directamente a una posición conocida de memoria.

Este tipo de acceso se utiliza principalmente en:

- `Mult.asm`
- `SumN.asm`
- Las entradas iniciales de `CopyBlock.asm`

---

### 7.2 Variables simbólicas

Los programas utilizan nombres como:

```text
resultado
j
sum
N
orig
dest
pos
```

El assembler Hack asigna automáticamente estas variables a posiciones de memoria disponibles comenzando desde `RAM[16]`.

Por ejemplo, en `Mult.asm`:

```text
resultado → RAM[16]
j         → RAM[17]
```

mientras que en `CopyBlock.asm`:

```text
orig → RAM[16]
dest → RAM[17]
N    → RAM[18]
```

---

### 7.3 Direccionamiento indirecto

`CopyBlock.asm` utiliza direccionamiento indirecto para acceder a una dirección cuyo valor se encuentra almacenado en otra posición.

Por ejemplo:

```asm
@orig
D=M

A=D
D=M
```

Si:

```text
orig = 100
```

entonces:

```text
D = RAM[100]
```

Este mecanismo permite recorrer bloques de memoria sin conocer previamente todas las direcciones que serán utilizadas.

---

### 7.4 Memoria mapeada a dispositivos

`Fill.asm` utiliza memoria mapeada para interactuar con pantalla y teclado.

```text
SCREEN → RAM[16384..24575]
KBD    → RAM[24576]
```

Esto permite controlar dispositivos utilizando las mismas instrucciones de acceso a memoria utilizadas para trabajar con datos normales.

---

## 8. Flujo general del Proyecto 4

Los programas desarrollados permiten aplicar diferentes conceptos de la arquitectura Hack:

```text
                    Proyecto 4
                         │
          ┌──────────────┼──────────────┐
          │              │              │
          ▼              ▼              ▼
     Aritmética      Control de      Memoria
                      flujo
          │              │              │
     ┌────┴────┐         │       ┌──────┴───────┐
     ▼         ▼         │       ▼              ▼
   Mult       SumN      loops  CopyBlock       Fill
                                 │               │
                                 ▼               ▼
                          direccionamiento   SCREEN/KBD
                             indirecto
```

`Mult.asm` utiliza sumas repetidas para implementar una multiplicación.

`SumN.asm` utiliza un acumulador y un contador para calcular una suma iterativa.

`CopyBlock.asm` utiliza punteros y direccionamiento indirecto para mover datos entre diferentes regiones de memoria.

`Fill.asm` utiliza memoria mapeada para interactuar con los dispositivos de entrada y salida.

---

## 9. Decisiones de diseño

Los programas utilizan variables simbólicas para evitar depender directamente de posiciones específicas de RAM para las variables auxiliares.

También se utilizan ciclos implementados mediante etiquetas y saltos condicionales, ya que el lenguaje ensamblador Hack no posee estructuras como `while` o `for`.

Los programas que utilizan acumuladores inicializan las posiciones temporales antes de comenzar el cálculo. De esta manera, su funcionamiento no depende del contenido previo de la memoria.

En `CopyBlock.asm`, las direcciones de origen y destino se almacenan en punteros auxiliares, permitiendo incrementar estas direcciones durante el recorrido sin modificar los valores originales de `R0` y `R1`.

En `Fill.asm`, una única variable `pos` permite recorrer secuencialmente toda la memoria asociada a la pantalla.

---

## 10. Conclusiones

El Proyecto 4 permite comprender cómo implementar algoritmos utilizando directamente las instrucciones de la arquitectura Hack.

`Mult.asm` demuestra cómo una operación como la multiplicación puede construirse utilizando sumas repetidas y control de flujo.

`Fill.asm` permite comprender el funcionamiento de la memoria mapeada y la interacción entre software, pantalla y teclado.

`SumN.asm` utiliza acumulación y estructuras iterativas para calcular la suma de los primeros números naturales.

Finalmente, `CopyBlock.asm` permite utilizar direccionamiento indirecto y punteros para recorrer y copiar bloques de memoria.

En conjunto, los cuatro programas permiten aplicar conceptos fundamentales como instrucciones A y C, saltos condicionales, ciclos, variables, direccionamiento directo e indirecto y manipulación de memoria dentro de la arquitectura Hack.
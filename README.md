# Práctica 2 – Organización y Arquitectura de Computadores

## Estudiantes

- Juan Esteban Palacio Betancur
- Thomas Alejandro Serna Saldarriaga

## Descripción

Este repositorio contiene la solución de la Práctica 2 del curso de
Organización y Arquitectura de Computadores.

La práctica se basa en los Proyectos 4 y 5 de Nand2Tetris y comprende:
programación en lenguaje ensamblador Hack y construcción de los componentes
principales de la arquitectura Hack: Memory, CPU y Computer.

## Contenido

### Proyecto 4 – Lenguaje ensamblador

Programas oficiales:

- `Mult.asm`
- `Fill.asm`

Programas adicionales del curso:

- `SumN.asm`
- `CopyBlock.asm`

### Proyecto 5 – Hardware

Componentes:

- `Memory.hdl`
- `CPU.hdl`
- `Computer.hdl`

## Estructura del repositorio

```text
proyecto04/
├── HDL/
├── DOCUMENTACION/
└── TESTS/

proyecto05/
├── HDL/
├── DOCUMENTACION/
└── TESTS/

README.md
```

## Requisitos

Los componentes deben ser compatibles con la arquitectura Hack y ejecutarse
correctamente en los simuladores oficiales de Nand2Tetris.

No se deben modificar los simuladores ni las pruebas oficiales, ni utilizar
herramientas externas que reemplacen la implementación en HDL o assembler.

## Objetivos

- Comprender el modelo de ejecución de instrucciones de Hack.
- Implementar programas en assembler Hack.
- Manipular memoria mediante direccionamiento.
- Construir `Memory`, `CPU` y `Computer`.
- Integrar hardware y software en una arquitectura Hack funcional.
- Mantener un historial de Git claro y consistente.

## Estado

Repositorio base preparado a partir de la estructura y estilo utilizados en
la Práctica 1. Los archivos de implementación y las evidencias de pruebas
deben incorporarse en las carpetas correspondientes.

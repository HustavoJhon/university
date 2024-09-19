#!/usr/bin/env
# Autor: JHON GUSTAVO CCARITA VELASQUEZ
# fecha: 13/09/2024

# pip install rich
from rich import print

print("[bold red]PRUEBA 1[/bold red]")
print("[italic blue]Elaborar un programa para una organización reguladora ambiental, e ingresar: Monto Base en dólares, Categoría, Ruido en Decibeles, Porcentaje de Penalidad (según la tabla) y tipo de cambio a soles; para mostrar el Monto Base en soles, el Monto de Penalidad y el Monto a Pagar, ambos en soles, para una entidad.[/italic blue]\n")

print("[bold]SOLUCION:[/bold]")

print("""
      [bold]RUIDO EN DECIBELES[/bold]
      +===+============+    
      | A | 50 o menos |
      | B | 51 - 70    |
      | C | 71 - 90    |
      | D | 91 - 110   |
      | E | mas de 110 |
      +===+============+
      """)

# 1. Ingreso de variables requeridas.
categoria = input("Ingrese la categoria:\t\t ")
monto_base_dolares = int(input("Ingrese el monto en dolares:\t "+"$ "))

# 2. Realizar el calculo del monto base convertido a soles en su respectiva variable.
monto_en_soles = monto_base_dolares * 3.77

# CATEGORIA A
if (categoria.lower() == 'a'):
    if (monto_en_soles >= 50):
        # 3. Realizar el calculo del monto de Penalidad en su respectiva variable.
        penalidad = monto_en_soles * 5 / 100
        # 4. Realizar el calculo del monto de a Pagar en su respectiva variable.
        monto_pagar = (monto_en_soles - penalidad)
        
        print("\n[bold]CATEGORIA A[/bold]")
        # 5. Muestra las variables solicitadas, segun el tipo de dato que corresponde.
        print(f"\nMonto base en soles:\t S/.{monto_en_soles}")
        print(f"Monto de penalidad:\t S/.{round(penalidad, 2)}")
        print(f"Monto a pagar:\t\t S/.{round(monto_pagar,2)}\n")
    else:
        print(f"Su monto base es mayor o igual a 50")

# CATEGORIA B
if (categoria.lower() == 'b'):
    if (monto_en_soles >= 51 and monto_en_soles <= 70):
        penalidad = monto_en_soles * 7 / 100
        monto_pagar = (monto_en_soles - penalidad)
        
        print("\n[bold]CATEGORIA B[/bold")
        print(f"\nMonto base en soles:\t S/.{monto_en_soles}")
        print(f"Monto de penalidad:\t S/.{round(penalidad, 2)}")
        print(f"Monto a pagar:\t\t S/.{round(monto_pagar,2)}")
    else:
        print(f"Su monto base es menor o igual a 50 y mayor igual a 70")

# CATEGORIA C
if (categoria.lower() == 'c'):
    if (monto_en_soles >= 71 and monto_en_soles <= 90):
        penalidad = monto_en_soles * 9 / 100
        monto_pagar = (monto_en_soles - penalidad)
        
        print("\n[bold]CATEGORIA C[/bold]")
        print(f"\nMonto base en soles:\t S/.{monto_en_soles}")
        print(f"Monto de penalidad:\t S/.{round(penalidad, 2)}")
        print(f"Monto a pagar:\t S/.{round(monto_pagar,2)}")
    else:
        print(f"Su monto base es menor o igual a 71 y mayor igual a 90")

# CATEGORIA D       
if (categoria.lower() == 'd'):
    if (monto_en_soles >= 91 and monto_en_soles <= 110):
        penalidad = monto_en_soles * 12 / 100
        monto_pagar = (monto_en_soles - penalidad)
        
        print("\n[bold]CATEGORIA D[/bold]")
        print(f"\nMonto base en soles:\t S/.{monto_en_soles}")
        print(f"Monto de penalidad:\t S/.{round(penalidad, 2)}")
        print(f"Monto a pagar:\t S/.{round(monto_pagar,2)}")
    else:
        print(f"Su monto base es menor o igual a 91 y mayor igual a 110")

# CATEGORIA E    
if (categoria.lower() == 'e'):
    if (monto_en_soles > 110):
        penalidad = monto_en_soles * 15 / 100
        monto_pagar = (monto_en_soles - penalidad)
        
        print("\n[bold]CATEGORIA E[/bold]")
        print(f"\nMonto base en soles:\t S/.{monto_en_soles}")
        print(f"Monto de penalidad:\t S/.{round(penalidad, 2)}")
        print(f"Monto a pagar:\t\t S/.{round(monto_pagar,2)}")
    else:
        print(f"Su monto base es menor a 110")
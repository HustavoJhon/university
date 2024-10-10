print("INGRESO DE DATOS")
numero = int(input("Ingrese un numero entero: "))

if (numero > 0):
    if (numero >= 1 and numero <= 10):
        print("Esta en el rango de los 10 primeros numeros")
    else:
        print("Esta mas del rango de los diez primeros numeros")
else:
    print("ERROR, el numero no es mayor a cero")
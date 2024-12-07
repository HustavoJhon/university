print("INGRESO DE DATOS DE BARCO")

letra = input("Ingrese letra inicial de barco: ")
letra_mayuscula = letra.upper()

if letra_mayuscula == "B" or letra_mayuscula == "F" or letra_mayuscula == "C":
    match letra_mayuscula:
        case "B":
            print("Es un buque")
        case "F":
            print("Es un fragata")
        case "C":
            print("Es un crucero")
else:
    print("ERROR, la letra no es B, F o C")
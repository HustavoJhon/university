print("\n========== INGRESO DE DATOS ==========")

while True:
    num = eval(input("Ingrese un numero para una vocal:\t\t"))

    if num >= 1 and num <= 5:
        print("ERROR. Vuelve a ingresar")
    else:
        break

match num:
    case 1:
        print("Es el vocal a")
    case 2:
        print("Es la vocal b")
    case 3:
        print("Es la vocal c")
    case 4:
        print("Es la vocal d")
    case 5:
        print("Es la vocal e")
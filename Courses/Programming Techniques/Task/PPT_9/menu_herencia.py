def leer_dato_e():
    dato = int(input(""))
    return dato

def leer_dato_f():
    dato = float(input(""))
    return dato

def reparticion():
    while True:
        print("Ingrese monto de herencia:\t\t\t",end="")
        monto_herencia = leer_dato_f()
        if monto_herencia <= 0:
            print("ERROR. Vuelva a ingresar, Monto herencia debe ser > 0")
        else:
            break

    while True:
        print("Ingrese Cantidad de Hijos:\t\t\t", end="")
        cantidad_hijos = leer_dato_e()
        if cantidad_hijos <= 0:
            print("ERROR. Vuelve a ingresar, Cantidad hijos debe ser > 0")
        else:
            break 
    if cantidad_hijos <= 3:
        reparto = monto_herencia / cantidad_hijos
        print("Para cada hijo se reparte:\t\t\t", reparto)
    elif cantidad_hijos >= 4:
        reparto_hijo_mayor = monto_herencia / 2
        reparto = reparto_hijo_mayor / (cantidad_hijos - 1)
        print("Para el hijo mayor se reparte:\t\t\t", reparto_hijo_mayor)
        print("Para los demas hijos se reparte:\t\t\t", reparto)

def menu():
    while True:
        print("========== MENU PRINCIPAL ==========")
        print("1. Procesar")
        print("2. Salir")

        while True:
            operacion_menu = int(input("Ingrese una operacion:\t\t"))
            if operacion_menu < 1 or operacion_menu > 2:
                print("ERROR. Vuelve a ingresar 1 o 2")
            else:
                break

        match operacion_menu:
            case 1:
                reparticion()
            case 2:
                while True:
                    sleepy = input("Seguro que quiere salir?\t\t").upper()
                    if sleepy != "S" and sleepy != "N":
                        print("ERROR. Vuelva a Ingresar S o s / N o n")
                    else:
                        break
                if sleepy == "S":
                    print("Vuelva Pronto")
                    break

def Ejecutar():
    menu()

Ejecutar()
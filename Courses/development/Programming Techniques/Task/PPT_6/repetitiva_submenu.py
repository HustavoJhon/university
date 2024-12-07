monto_saldo = 0

while True:
    print("Menu Principal")
    print("1. Procesar")
    print("2. Salir")

    while True:
        opcion_menu = int(input("Ingresa opcion menu: "))

        if (opcion_menu < 1 or opcion_menu > 2):
            print("Error. Vuelve a ingresar")
        else:
            break

    match opcion_menu:
        
        case 1:
            while True:
                print("Sub menu")
                print("1. Depositar")
                print("2. Retirar")
                print("3. Ver saldo")
                print("4. Volver")

                while True:
                    opcion_sub_menu = int(input("Ingrese opcion de menu: "))

                    if (opcion_sub_menu < 1 or opcion_sub_menu > 4):
                        print("Error. Vuelva a ingresar")
                    else:
                        break
                match opcion_sub_menu:
                    case 1:
                        while True:
                            monto_deposito = float(input("Ingrese monto a depositar: "))

                            if (monto_deposito <= 0):
                                print("Error. vuelve a ingresar. monoto deposito debe ser > 0")
                            else:
                                break

                        monto_saldo = monto_saldo + monto_deposito

                    case 2:
                        while True:
                            monto_retirar = float(input("Ingrese monto a retirar: "))

                            if (monto_retirar <= 0):
                                print("Error. Vuelve a ingresar, monto a retiro debe ser > 0")
                            else:
                                break

                        if monto_retirar <= monto_saldo:
                            monto_saldo = monto_saldo - monto_retirar
                        else:
                            print("saldo insuficiente")
                    
                    case 3:
                        print("Su saldo actual es: ", monto_saldo)
                    
                    case 4:
                        while True:
                            respuesta = input("Seguro que quiere salir?: ")
                            respuesta_mayuscula = respuesta.upper()
                            if (respuesta_mayuscula != "S" and respuesta_mayuscula != "N"):
                                print("Error. Vuelve a ingresar S/N")
                            else:
                                break
                        if respuesta_mayuscula == "S":
                            print("Esta volviendo al menu principal")
                            break
                        
        case 2:
            while True:
                respuesta_sub_menu = input("Seguro que quiere salir?: ")
                respuesta_sub_menu_mayuscula = respuesta_sub_menu.upper()

                if (respuesta_sub_menu_mayuscula != "S" and respuesta_sub_menu_mayuscula != "N"):
                    print("Error vuelve a ingresar S/N")
                else:
                    break
            if respuesta_sub_menu_mayuscula == "S":
                print("Gracias vuelva pronto")
                break
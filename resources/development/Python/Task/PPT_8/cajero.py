acumular_saldo = 0.0
cantidad_deposito = 0
cantidad_retiro = 0
cantidad_operacion = 0

while True:
    print("========== MENU OPCIONES ==========")
    print("1. Depositar")
    print("2. Retirar")
    print("3. Ver saldo")
    print("4. Salir")

    while True:
        operacion_menu = int(input("Ingrese operacion de menu:\t\t"))

        if operacion_menu < 1 or operacion_menu > 4:
            print("ERROR. Ingrese una operacion valida")
        else:
            break
    
    if operacion_menu != 4:
        cantidad_operacion += 1
    
    match operacion_menu:
        case 1:
            while True:
                monto_deposito = float(input("Ingrese monto de deposito:\t\t"))

                if (monto <= 0):
                    print("ERROR. Ingrese un monto positivo")
                else:
                    break
            cantidad_deposito += 1
            acumular_saldo = acumular_saldo + monto_deposito
            print("El saldo actual es:\t\t", acumular_saldo)

        case 2:
            while True:
                monto_retiro = float(input("Ingrese monto de retiro:\t\t"))

                if (monto_retiro <= 0):
                    print("ERROR. Ingrese un monto positivo")
                else:
                    break
            
            if monto_retiro <= acumular_saldo:
                acumular_saldo = acumular_saldo - monto_retiro
                cantidad_retiro += 1
            else:
                print("Saldo Insuficiente")
            
            print("El saldo actual es:\t\t", acumular_saldo)

        case 3:
            print("El acumulador de saldo es:\t", acumular_saldo)
        
        case 4:
            print("La cantidad de depositos es:\t", cantidad_deposito)
            print("La cantidad de retiros es:\t", cantidad_retiro)
            print("La cantidad total de operaciones es:\t", cantidad_operacion)

            print(10*"=")
            print("Gracias Vuelva Pronto!")
            break


monto_saldo = 0

while True:
    print("========== MENU CAJERO ==========")
    print("1. Depositar")
    print("2. Retirar")
    print("3. Ver saldo")
    print("4. Salir")

    while True:
        operacion_menu = int(input("Ingrese una operacion:\t\t"))
        if operacion_menu < 1 or operacion_menu > 4:
            print("ERROR. Ingrese una operacion valida")
        else:
            break

    match operacion_menu:
        case 1:
            while True:
                monto_deposito = float(input("Ingrese monto a depositar:\t\t\t"))
                if monto_deposito <= 0:
                    print("ERROR. Vuelve a ingresar, Monto deposito debe ser > 0")
                else:
                    break

            monto_saldo = monto_saldo + monto_deposito
        
        case 2:
            while True:
                monto_retiro = float(input("Ingrese monto a retirar:\t\t\t"))
                if monto_retiro <= 0:
                    print("ERROR. Vuelve a ingresar, Monto retiro debe ser > 0")
                else:
                    break

            if monto_retiro <= monto_saldo:
                monto_saldo = monto_saldo - monto_retiro
            else:
                print("--- Saldo insuficiente ---")

        case 3:
            print("El saldo  actual es:\t\t\t", monto_saldo)

        case 4:
            print("Gracias... Vuelve pronto!") 
            break
            
# Elaborar un programa para simular las operaciones de un cajero automatico: Depositar, Retirar (Si hay saldo suficiente) y Ver saldo. Considere - Menu y SubMenu de Opcioens (con la opcion Salir). - Validar cada dato ingresado.
monto_saldo = 10

print("MENU CAJERO")
print("1. Depositar")
print("2. Retirar")
print("3. Ver saldo")
print("4. Salir")

operacion_menu = int(input("Ingrese una operacion: "))

if operacion_menu >= 1 and operacion_menu <= 4:
    match operacion_menu:
        case 1:
            monto_deposito = float(input("Ingrese monto a depositar: "))
            if monto_deposito > 0:
                monto_saldo = monto_saldo + monto_deposito 
            else:
                print("ERROR, el monto no puede ser negativo")
        case 2:
            monto_retiro = float(input("Ingrese monto a retirar: "))
            if monto_saldo > 0:
                if monto_retiro <= monto_saldo:
                    monto_saldo = monto_saldo - monto_retiro
                else:
                    print("--- Saldo insuficiente ---")
            else:
                print("ERROR, el monto no puede ser negativo")
        case 3:
            print("El saldo  actual es: ", monto_saldo)
        case 4:
            print("gracias... Vuelva pronto")
else:
    print("ERROR, el numero no es entre 1 y 4")
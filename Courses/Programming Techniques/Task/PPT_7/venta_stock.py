contador_pedido_completo = 0
contador_pedido_incompleto = 0
contador_pedido = 0

while True:
    print("========== MENU PRINCIPAL ==========")
    print("1. Ingresar Stock Inicial")
    print("2. Salir")


    while True:
        operacion_menu = int(input("Ingrese opcion de menu:\t\t"))

        if (operacion_menu < 1 or operacion_menu > 2):
            print("ERROR. Vuelva a ingresar")
        else:
            break 
    
    match operacion_menu:
        case 1:
            while True:
                cantidad_stock = int(input("Ingrese Stock para Vender:\t\t"))
                if (cantidad_stock <= 0 ):
                    print("ERROR. Vuelva a ingresar mayor a 0")
                else:
                    break 

            while True:
                print("========== SUB MENU: VENTAS ==========")
                print("1. Ventas")
                print("2. Reportar")
                print("3. Salir")

                while True:
                    operacion_submenu = int(input("Ingrese opcion de menu:\t\t"))

                    if (operacion_submenu < 1 or operacion_submenu > 3):
                        print("ERROR. Vuelva a ingresar")
                    else:
                        break

                match operacion_submenu:
                    case 1:
                        while True:
                            cantidad_pedidos = int(input("Ingrese Cantidad de pedidos a vender:\t\t"))
                            if (cantidad_pedidos <= 0 ):
                                print("ERROR. Vuelva a ingresar mayor a 0")
                            else:
                                break
                        
                        contador_pedido += 1

                        if cantidad_pedidos <= cantidad_stock:
                            cantidad_stock -= cantidad_pedidos
                            contador_pedido_completo += 1
                            print("========== PEDIDO COMPLETA ==========")
                        else:
                            contador_pedido_incompleto += 1
                            print("========== PEDIDO INCOMPLETA ==========")

                            falta = cantidad_pedidos - cantidad_stock
                            print(f"========== FALTO PARA COMPLETAR {falta} ==========")

                    case 2:
                        print("========== REPORTE POR TOTAL ==========")
                        print("La cantidad Total de clientes que pidieron:\t\t", contador_pedido)
                        print("La cantidad de Pedidos Completos:\t", contador_pedido_completo)
                        print("La cantidad de Pedidos Incompletos:\t", contador_pedido_incompleto)
                        print("Lo que queda en el stock es:\t\t\t\t", cantidad_stock)
                    
                    case 3:
                        print("Vuelve al Menu Principal")
                        break

        case 2:
            while True:
                sleepy = input("¿Desea Salir?\t\t").upper()

                if (sleepy != "S" and sleepy != "N"):
                    print("ERROR. Vuelva a Ingresar S o s / N o n")
                else:
                    break
            if (sleepy == "S"):
                print("Vuelva Pronto")
                break
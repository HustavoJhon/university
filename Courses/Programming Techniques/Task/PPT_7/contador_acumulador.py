contador_curso = 0 
acumulador_credito = 0

while True:
    print("========== MENU ==========")
    print("1. Procesar")
    print("2. Reportar")
    print("3. Salir")

    while True:
        operacion_menu = int(input("Ingrese una operacion:\t\t"))
        if operacion_menu < 1 or operacion_menu > 3:
            print("ERROR. Ingrese una operacion valida")
        else:
            break

    match operacion_menu:
        case 1:
            nombre_curso = input("Ingrese nombre del curso:\t\t")
            contador_curso = contador_curso + 1
            while True:
                credito_curso = int(input("Ingrese credito del curso:\t\t"))
                if credito_curso < 0 or credito_curso > 6:
                    print("ERROR. Vuelve a ingresar del 1 al 5")
                else:
                    break
            
            acumulador_credito = acumulador_credito + credito_curso

        case 2:
            print("========== REPORTE ==========")
            print("El numero de cursos procesados es:\t", contador_curso)
            print("El credito acumulado es:\t\t", acumulador_credito)

        case 3:
            print("Gracias por su compra!!!")
            break
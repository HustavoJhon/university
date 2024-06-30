Algoritmo pregunta_3
    Definir numero Como Entero;
    
    Escribir "Ingrese un número entero positivo (ingrese un número negativo para salir):";
    Leer numero;
    
    Mientras numero >= 0 Hacer
        Si numero % 2 == 0 Entonces
            Escribir "El número es par";
        Sino
            Escribir "El número es impar";
        FinSi
        
        Escribir "Ingrese otro número entero positivo (ingrese un número negativo para salir):";
        Leer numero;
    FinMientras
    
    Escribir "Fin del programa.";
FinAlgoritmo

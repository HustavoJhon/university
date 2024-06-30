Algoritmo pregunta_3
    //Escribe un algoritmo que solicite al usuario ingresar un número entero positivo. Si el número es par, el programa debe imprimir un mensaje que diga "El número es par". Si el número es impar, el programa debe imprimir un mensaje que diga "El número es impar". El programa debe continuar solicitando números al usuario hasta que ingrese un número negativo, momento en el que el programa debe detenerse.

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

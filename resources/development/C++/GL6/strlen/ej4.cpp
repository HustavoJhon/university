/*
Ejercicio 4: Calcular longitud de una cadena con strlen()

Crea un programa que calcule la longitud de la cadena sumando los caracteres 
hasta encontrar el carácter nulo '\0', utilizando la función strlen().
*/

#include <iostream>
#include <cstring> // para strlen
using namespace std;

int main() {
    char texto[100];

    cout << "Ingrese una cadena: ";
    cin.getline(texto, 100);

    // strlen ya cuenta caracteres hasta encontrar '\0'
    int longitud = strlen(texto);

    cout << "La longitud de la cadena es: " << longitud << endl;

    return 0;
}

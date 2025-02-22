/*
Ejercicio 6: Función que calcula longitud con strlen()

Crea una función que reciba una cadena y devuelva la longitud de la misma, 
utilizando un ciclo y la función strlen() para contar los caracteres.
*/

#include <iostream>
#include <cstring> // para strlen
using namespace std;

int longitudCadena(char texto[]) {
    // Aquí podríamos contar con un ciclo, pero como pide usar strlen, lo aprovechamos
    return strlen(texto);
}

int main() {
    char texto[100];

    cout << "Ingrese una cadena: ";
    cin.getline(texto, 100);

    cout << "La longitud de la cadena es: " << longitudCadena(texto) << endl;

    return 0;
}

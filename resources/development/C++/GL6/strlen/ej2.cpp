/*
Ejercicio 2: Comparación de longitudes con strlen()

Crea un programa que tome dos cadenas de texto del usuario y compare 
sus longitudes usando strlen(). Luego, imprime cuál es más larga 
o si son de la misma longitud.
*/

#include <iostream>
#include <cstring> // para strlen
using namespace std;

int main() {
    char texto1[100], texto2[100];

    cout << "Ingrese la primera cadena: ";
    cin.getline(texto1, 100);

    cout << "Ingrese la segunda cadena: ";
    cin.getline(texto2, 100);

    int len1 = strlen(texto1);
    int len2 = strlen(texto2);

    if (len1 > len2) {
        cout << "La primera cadena es más larga (" << len1 << " caracteres)." << endl;
    } else if (len2 > len1) {
        cout << "La segunda cadena es más larga (" << len2 << " caracteres)." << endl;
    } else {
        cout << "Ambas cadenas tienen la misma longitud (" << len1 << " caracteres)." << endl;
    }

    return 0;
}

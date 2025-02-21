/*
Ejercicio 5: Longitud y verificación de cadena vacía con strlen()

Modifica el programa anterior para que, además de mostrar la longitud de la cadena, 
también imprima si la cadena es vacía (tiene longitud 0) o no, usando strlen().
*/

#include <iostream>
#include <cstring> // para strlen
using namespace std;

int main() {
    char texto[100];

    cout << "Ingrese una cadena: ";
    cin.getline(texto, 100);

    int longitud = strlen(texto);

    cout << "La longitud de la cadena es: " << longitud << endl;

    if (longitud == 0) {
        cout << "La cadena está vacía." << endl;
    } else {
        cout << "La cadena NO está vacía." << endl;
    }

    return 0;
}

/*
Ejercicio 3: Contar caracteres desde la primera aparición de un carácter

Dada una cadena, escribe un programa que calcule cuántos caracteres 
hay entre la primera aparición de un carácter específico y el final 
de la cadena utilizando strlen().
*/

#include <iostream>
#include <cstring> // strlen, strchr
using namespace std;

int main() {
    char texto[100];
    char caracter;

    cout << "Ingrese una cadena: ";
    cin.getline(texto, 100);

    cout << "Ingrese el caracter a buscar: ";
    cin >> caracter;

    char* pos = strchr(texto, caracter);

    if (pos != nullptr) {
        int total = strlen(texto);
        int desde = pos - texto; // posición del caracter encontrado
        int resultado = total - desde; // cantidad desde el caracter hasta el final
        cout << "Hay " << resultado << " caracteres desde '" 
             << caracter << "' hasta el final." << endl;
    } else {
        cout << "El caracter no se encuentra en la cadena." << endl;
    }

    return 0;
}

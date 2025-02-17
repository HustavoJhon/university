/*
Ejercicio 1: Uso de strlen()

Escribe un programa que pida al usuario una cadena de texto y luego
imprima la longitud de la misma utilizando la función strlen().
*/

#include <cstring> // para strlen
#include <iostream>
using namespace std;

int main() {
  char texto[100];

  cout << "Ingrese una cadena: ";
  cin.getline(texto, 100);

  cout << "La longitud de la cadena es: " << strlen(texto) << endl;

  return 0;
}

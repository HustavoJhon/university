/*
Ejercicio 1: Actualizacion de Elemento en Array
Enunciado:
Dado un array de enteros arr[] = {5, 12, 7, 20, 3, 9},
escribe un programa que permita actualizar el valor del
elemento en la posicion i (donde i es un indice que se
ingresa por el usuario) con un nuevo valor tambien
proporcionado por el usuario.

Ejemplo:
Si el usuario ingresa i=2 y el valor 50,
el array debe quedar como: {5, 12, 50, 20, 3, 9}.
*/

#include <iostream>
using namespace std;

int main() {
  int arr[] = {5, 12, 7, 20, 3, 9};
  int i, nuevo;

  cout << "Ingrese el indice: ";
  cin >> i;
  cout << "Ingrese el nuevo valor: ";
  cin >> nuevo;

  if (i >= 0 && i < 6) {
    arr[i] = nuevo;
    cout << "Array actualizado: ";
    for (int j = 0; j < 6; j++)
      cout << arr[j] << " ";
  } else {
    cout << "Indice invalido";
  }
  return 0;
}

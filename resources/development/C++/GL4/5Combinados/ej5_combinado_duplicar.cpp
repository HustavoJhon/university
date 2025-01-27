/*
Ejercicio 5: Duplicar elementos
Enunciado:
Dado arr[] = {4, 6, 8, 5}, duplica todos los valores.
Ejemplo:
{8, 12, 16, 10}.
*/

#include <iostream>
using namespace std;

int main() {
  int arr[] = {4, 6, 8, 5};
  int n = 4;

  for (int i = 0; i < n; i++)
    arr[i] *= 2;

  cout << "Array actualizado: ";
  for (int i = 0; i < n; i++)
    cout << arr[i] << " ";
  cout << endl;
  return 0;
}

/*
Ejercicio 7: Actualizar múltiplos de 2
Enunciado:
Dado arr[] = {1, 2, 3, 4, 5, 6, 7, 8}, cambia todos los múltiplos de 2 por 100.
Ejemplo:
{1, 100, 3, 100, 5, 100, 7, 100}.
*/

#include <iostream>
using namespace std;

int main() {
  int arr[] = {1, 2, 3, 4, 5, 6, 7, 8};
  int n = 8;

  for (int i = 0; i < n; i++)
    if (arr[i] % 2 == 0)
      arr[i] = 100;

  cout << "Array actualizado: ";
  for (int i = 0; i < n; i++)
    cout << arr[i] << " ";
  cout << endl;
  return 0;
}

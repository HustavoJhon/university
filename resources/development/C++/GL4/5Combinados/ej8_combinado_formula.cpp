/*
Ejercicio 8: Actualizar con fórmula
Enunciado:
Dado arr[] = {1, 2, 3, 4, 5}, actualiza cada elemento arr[i] = arr[i] + i.
Ejemplo:
{1, 3, 5, 7, 9}.
*/

#include <iostream>
using namespace std;

int main() {
  int arr[] = {1, 2, 3, 4, 5};
  int n = 5;

  for (int i = 0; i < n; i++)
    arr[i] += i;

  cout << "Array actualizado: ";
  for (int i = 0; i < n; i++)
    cout << arr[i] << " ";
  cout << endl;
  return 0;
}

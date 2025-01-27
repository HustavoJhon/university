/*
Ejercicio 3: Ordenacion por Insercion (Insertion Sort)
Enunciado:
Dado el array arr[] = {12, 11, 13, 5, 6}, implementa el algoritmo
de ordenacion por insercion para ordenar el array de menor a mayor.
Resultado esperado: {5, 6, 11, 12, 13}
*/

#include <iostream>
using namespace std;

int main() {
  int arr[] = {12, 11, 13, 5, 6};
  int n = 5;

  for (int i = 1; i < n; i++) {
    int clave = arr[i];
    int j = i - 1;
    while (j >= 0 && arr[j] > clave) {
      arr[j + 1] = arr[j];
      j--;
    }
    arr[j + 1] = clave;
  }

  cout << "Array ordenado: ";
  for (int i = 0; i < n; i++)
    cout << arr[i] << " ";
  cout << endl;
  return 0;
}

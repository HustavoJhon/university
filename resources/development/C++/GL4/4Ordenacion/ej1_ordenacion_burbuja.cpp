/*
Ejercicio 1: Ordenacion por Burbuja (Bubble Sort)
Enunciado:
Dado el array arr[] = {5, 2, 9, 1, 5, 6}, implementa el algoritmo
de ordenacion por burbuja para ordenar el array de menor a mayor.
Resultado esperado: {1, 2, 5, 5, 6, 9}
*/

#include <iostream>
using namespace std;

int main() {
  int arr[] = {5, 2, 9, 1, 5, 6};
  int n = 6;

  for (int i = 0; i < n - 1; i++) {
    for (int j = 0; j < n - i - 1; j++) {
      if (arr[j] > arr[j + 1]) {
        int temp = arr[j];
        arr[j] = arr[j + 1];
        arr[j + 1] = temp;
      }
    }
  }

  cout << "Array ordenado: ";
  for (int i = 0; i < n; i++)
    cout << arr[i] << " ";
  cout << endl;
  return 0;
}

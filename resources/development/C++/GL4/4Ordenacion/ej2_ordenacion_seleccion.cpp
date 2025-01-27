/*
Ejercicio 2: Ordenacion por Seleccion (Selection Sort)
Enunciado:
Dado el array arr[] = {29, 10, 14, 37, 13}, implementa el algoritmo
de ordenacion por seleccion para ordenar el array de mayor a menor.
Resultado esperado: {37, 29, 14, 13, 10}
*/

#include <iostream>
using namespace std;

int main() {
  int arr[] = {29, 10, 14, 37, 13};
  int n = 5;

  for (int i = 0; i < n - 1; i++) {
    int maxIndex = i;
    for (int j = i + 1; j < n; j++) {
      if (arr[j] > arr[maxIndex]) {
        maxIndex = j;
      }
    }
    int temp = arr[i];
    arr[i] = arr[maxIndex];
    arr[maxIndex] = temp;
  }

  cout << "Array ordenado (descendente): ";
  for (int i = 0; i < n; i++)
    cout << arr[i] << " ";
  cout << endl;
  return 0;
}

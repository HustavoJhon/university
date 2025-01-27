/*
Ejercicio 5: Ordenacion Descendente con Seleccion
Enunciado:
Dado el array arr[] = {12, 7, 15, 4, 9}, implementa el algoritmo
de ordenacion por seleccion para ordenar el array de mayor a menor.
Resultado esperado: {15, 12, 9, 7, 4}
*/

#include <iostream>
using namespace std;

int main() {
  int arr[] = {12, 7, 15, 4, 9};
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

// 14. Crear un arreglo de 10 numeros enteros. Calcular el promedio y contar
// cuantos son mayores que el promedio.
#include <iostream>
using namespace std;

int main() {
  int arr[10], suma = 0;
  cout << "Ingrese 10 numeros enteros:" << endl;
  for (int i = 0; i < 10; i++) {
    cout << "Numero " << (i + 1) << ": ";
    cin >> arr[i];
    suma += arr[i];
  }
  float prom = suma / 10.0;
  int mayores = 0;
  for (int i = 0; i < 10; i++) {
    if (arr[i] > prom)
      mayores++;
  }
  cout << "Promedio: " << prom << endl;
  cout << "Cantidad de numeros mayores al promedio: " << mayores << endl;
  return 0;
}

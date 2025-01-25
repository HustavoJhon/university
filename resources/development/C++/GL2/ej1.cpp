// 1. Crear un arreglo de 5 numeros enteros. Permitir al usuario ingresar los 5
// numeros y calcular la suma total de todos los elementos del arreglo.
#include <iostream>
using namespace std;

int main() {
  int arr[5], suma = 0;
  cout << "Ingrese 5 numeros enteros:" << endl;
  for (int i = 0; i < 5; i++) {
    cout << "Numero " << (i + 1) << ": ";
    cin >> arr[i];
    suma += arr[i];
  }
  cout << "La suma total es: " << suma << endl;
  return 0;
}

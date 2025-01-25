// 6. Crear un arreglo de 10 numeros enteros. Permitir al usuario ingresar los
// 10 numeros y contar cuantos son pares y cuantos son impares.
#include <iostream>
using namespace std;

int main() {
  int arr[10], pares = 0, impares = 0;
  cout << "Ingrese 10 numeros enteros:" << endl;
  for (int i = 0; i < 10; i++) {
    cout << "Numero " << (i + 1) << ": ";
    cin >> arr[i];
    if (arr[i] % 2 == 0)
      pares++;
    else
      impares++;
  }
  cout << "Cantidad de pares: " << pares << endl;
  cout << "Cantidad de impares: " << impares << endl;
  return 0;
}

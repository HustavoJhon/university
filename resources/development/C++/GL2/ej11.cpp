// 11. Crear un arreglo de 15 numeros enteros. Calcular la suma de los pares y
// la suma de los impares.
#include <iostream>
using namespace std;

int main() {
  int arr[15], sumaP = 0, sumaI = 0;
  cout << "Ingrese 15 numeros enteros:" << endl;
  for (int i = 0; i < 15; i++) {
    cout << "Numero " << (i + 1) << ": ";
    cin >> arr[i];
    if (arr[i] % 2 == 0)
      sumaP += arr[i];
    else
      sumaI += arr[i];
  }
  cout << "Suma de pares: " << sumaP << endl;
  cout << "Suma de impares: " << sumaI << endl;
  return 0;
}

// 13. Crear un arreglo de 12 numeros enteros. Contar cuantos son positivos y
// cuantos negativos.
#include <iostream>
using namespace std;

int main() {
  int arr[12], pos = 0, neg = 0;
  cout << "Ingrese 12 numeros enteros:" << endl;
  for (int i = 0; i < 12; i++) {
    cout << "Numero " << (i + 1) << ": ";
    cin >> arr[i];
    if (arr[i] >= 0)
      pos++;
    else
      neg++;
  }
  cout << "Cantidad de positivos: " << pos << endl;
  cout << "Cantidad de negativos: " << neg << endl;
  return 0;
}

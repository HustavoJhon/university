// 12. Crear un arreglo de 8 numeros enteros. Crear un nuevo arreglo con los
// cuadrados de esos numeros y mostrar ambos.
#include <iostream>
using namespace std;

int main() {
  int arr[8], cuadrados[8];
  cout << "Ingrese 8 numeros enteros:" << endl;
  for (int i = 0; i < 8; i++) {
    cout << "Numero " << (i + 1) << ": ";
    cin >> arr[i];
    cuadrados[i] = arr[i] * arr[i];
  }
  cout << "Arreglo original: ";
  for (int i = 0; i < 8; i++)
    cout << arr[i] << " ";
  cout << endl;

  cout << "Arreglo de cuadrados: ";
  for (int i = 0; i < 8; i++)
    cout << cuadrados[i] << " ";
  cout << endl;

  return 0;
}

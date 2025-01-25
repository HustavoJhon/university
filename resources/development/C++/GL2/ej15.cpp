// 15. Crear un arreglo de 5 cadenas de texto. Invertir el orden y mostrarlo.
#include <iostream>
#include <string>
using namespace std;

int main() {
  string arr[5];
  cout << "Ingrese 5 palabras o frases:" << endl;
  cin.ignore();
  for (int i = 0; i < 5; i++) {
    cout << "Cadena " << (i + 1) << ": ";
    getline(cin, arr[i]);
  }
  cout << "Arreglo invertido: " << endl;
  for (int i = 4; i >= 0; i--) {
    cout << arr[i] << endl;
  }
  return 0;
}

// 4. Crear un arreglo de 5 notas de un estudiante. Permitir al usuario ingresar
// las 5 notas y calcular el promedio de las notas. Si el promedio es mayor o
// igual a 10.5, el estudiante aprueba; si es menor, reprueba.
#include <iostream>
using namespace std;

int main() {
  float notas[5], suma = 0;
  cout << "Ingrese 5 notas:" << endl;
  for (int i = 0; i < 5; i++) {
    cout << "Nota " << (i + 1) << ": ";
    cin >> notas[i];
    suma += notas[i];
  }
  float prom = suma / 5;
  cout << "Promedio: " << prom << " - ";
  if (prom >= 10.5) {
    cout << "El estudiante aprueba." << endl;
  } else {
    cout << "El estudiante reprueba." << endl;
  }
  return 0;
}

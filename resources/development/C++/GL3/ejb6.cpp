// 6. Crear una matriz de 3x3 numeros enteros. Ingresar valores y calcular el
// promedio de todos los elementos.
#include <iostream>
using namespace std;

int main() {
  int mat[3][3], suma = 0;
  cout << "Ingrese los valores de la matriz 3x3:" << endl;
  for (int i = 0; i < 3; i++) {
    for (int j = 0; j < 3; j++) {
      cout << "Valor [" << i << "][" << j << "]: ";
      cin >> mat[i][j];
      suma += mat[i][j];
    }
  }
  float promedio = suma / 9.0;
  cout << "El promedio de todos los elementos es: " << promedio << endl;
  return 0;
}

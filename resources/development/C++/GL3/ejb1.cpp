// 1. Crear una matriz de 3x3 numeros enteros. Permitir al usuario ingresar los
// valores en cada posicion y mostrar la matriz resultante.
#include <iostream>
using namespace std;

int main() {
  int mat[3][3];
  cout << "Ingrese los valores de la matriz 3x3:" << endl;
  for (int i = 0; i < 3; i++) {
    for (int j = 0; j < 3; j++) {
      cout << "Valor [" << i << "][" << j << "]: ";
      cin >> mat[i][j];
    }
  }
  cout << "Matriz ingresada:" << endl;
  for (int i = 0; i < 3; i++) {
    for (int j = 0; j < 3; j++) {
      cout << mat[i][j] << " ";
    }
    cout << endl;
  }
  return 0;
}

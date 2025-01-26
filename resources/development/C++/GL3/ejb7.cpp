// 7. Crear una matriz de 2x2 numeros enteros. Ingresar valores e intercambiar
// la primera fila con la segunda. Mostrar la matriz final.
#include <iostream>
using namespace std;

int main() {
  int mat[2][2];
  cout << "Ingrese los valores de la matriz 2x2:" << endl;
  for (int i = 0; i < 2; i++) {
    for (int j = 0; j < 2; j++) {
      cout << "Valor [" << i << "][" << j << "]: ";
      cin >> mat[i][j];
    }
  }

  // Intercambiar fila 0 con fila 1
  for (int j = 0; j < 2; j++) {
    int temp = mat[0][j];
    mat[0][j] = mat[1][j];
    mat[1][j] = temp;
  }

  cout << "Matriz despues del intercambio:" << endl;
  for (int i = 0; i < 2; i++) {
    for (int j = 0; j < 2; j++) {
      cout << mat[i][j] << " ";
    }
    cout << endl;
  }
  return 0;
}

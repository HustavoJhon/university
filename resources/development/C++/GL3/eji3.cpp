// 3. Verificar si una matriz n x n es simetrica
#include <iostream>
using namespace std;

int main() {
  int n;
  cout << "Ingrese el tamano de la matriz cuadrada: ";
  cin >> n;
  int mat[n][n];
  bool simetrica = true;

  cout << "Ingrese los valores de la matriz " << n << "x" << n << ":" << endl;
  for (int i = 0; i < n; i++) {
    for (int j = 0; j < n; j++) {
      cout << "Valor [" << i << "][" << j << "]: ";
      cin >> mat[i][j];
    }
  }

  for (int i = 0; i < n; i++) {
    for (int j = 0; j < n; j++) {
      if (mat[i][j] != mat[j][i]) {
        simetrica = false;
      }
    }
  }

  if (simetrica) {
    cout << "La matriz es simetrica." << endl;
  } else {
    cout << "La matriz no es simetrica." << endl;
  }

  return 0;
}

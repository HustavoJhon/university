// 2. Producto de dos matrices m x n y n x p
#include <iostream>
using namespace std;

int main() {
  int m, n, p;
  cout << "Ingrese el numero de filas de la primera matriz (m): ";
  cin >> m;
  cout << "Ingrese el numero de columnas de la primera matriz (n): ";
  cin >> n;
  cout << "Ingrese el numero de columnas de la segunda matriz (p): ";
  cin >> p;

  int a[m][n], b[n][p], prod[m][p];

  cout << "Ingrese los valores de la primera matriz (" << m << "x" << n
       << "):" << endl;
  for (int i = 0; i < m; i++) {
    for (int j = 0; j < n; j++) {
      cout << "A[" << i << "][" << j << "]: ";
      cin >> a[i][j];
    }
  }

  cout << "Ingrese los valores de la segunda matriz (" << n << "x" << p
       << "):" << endl;
  for (int i = 0; i < n; i++) {
    for (int j = 0; j < p; j++) {
      cout << "B[" << i << "][" << j << "]: ";
      cin >> b[i][j];
    }
  }

  for (int i = 0; i < m; i++) {
    for (int j = 0; j < p; j++) {
      prod[i][j] = 0;
      for (int k = 0; k < n; k++) {
        prod[i][j] += a[i][k] * b[k][j];
      }
    }
  }

  cout << "Matriz producto (" << m << "x" << p << "):" << endl;
  for (int i = 0; i < m; i++) {
    for (int j = 0; j < p; j++) {
      cout << prod[i][j] << " ";
    }
    cout << endl;
  }

  return 0;
}

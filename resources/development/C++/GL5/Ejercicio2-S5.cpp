/*
Ejercicio 2: Registro de Productos y Valor Total del Inventario

Crea un programa donde se cree un registro para almacenar el nombre, precio,
cantidad en inventario y categoría de n productos. Además, debe calcular el
valor total del inventario de cada producto (precio * cantidad), mostrar los
registros ingresados por pantalla y mostrar el valor total del inventario.
*/
#include <iostream>
using namespace std;

struct Producto {
  string nombre;
  float precio;
  int cantidad;
  string categoria;
  float total;
};

int main() {
  int n;
  cout << "Ingrese la cantidad de productos: ";
  cin >> n;
  Producto p[n];
  for (int i = 0; i < n; i++) {
    cout << "\nProducto " << i + 1 << endl;
    cout << "Nombre: ";
    cin >> p[i].nombre;
    cout << "Precio: ";
    cin >> p[i].precio;
    cout << "Cantidad: ";
    cin >> p[i].cantidad;
    cout << "Categoria: ";
    cin >> p[i].categoria;
    p[i].total = p[i].precio * p[i].cantidad;
  }
  cout << "\n--- Inventario ---\n";
  for (int i = 0; i < n; i++) {
    cout << p[i].nombre << " (" << p[i].categoria << ") Total: " << p[i].total
         << endl;
  }
  return 0;
}

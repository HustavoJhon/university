/*
Ejercicio 13: Registro de Productos y Proveedor 

Crea un programa donde se cree un registro para almacenar el nombre del producto, código del producto, 
precio unitario y cantidad en stock de n productos. Dentro de este registro, debe haber un registro 
anidado para almacenar la información del proveedor, que contenga:
    • Nombre del proveedor
    • Teléfono
    • Dirección del proveedor
El programa debe calcular el valor total del inventario (precio * cantidad en stock) de cada producto 
y mostrar los registros ingresados, junto con el valor total del inventario.
*/

#include <iostream>
using namespace std;

struct Proveedor {
    string nombre;
    string telefono;
    string direccion;
};

struct Producto {
    string nombre;
    int codigo;
    float precioUnitario;
    int stock;
    Proveedor proveedor;
    float valorInventario;
};

int main() {
    int n;
    cout << "Ingrese la cantidad de productos: ";
    cin >> n;

    Producto productos[n];

    for (int i = 0; i < n; i++) {
        cout << "\nProducto " << i + 1 << endl;
        cout << "Nombre: ";
        cin >> productos[i].nombre;
        cout << "Codigo: ";
        cin >> productos[i].codigo;
        cout << "Precio unitario: ";
        cin >> productos[i].precioUnitario;
        cout << "Cantidad en stock: ";
        cin >> productos[i].stock;

        cout << "--- Datos del proveedor ---" << endl;
        cout << "Nombre del proveedor: ";
        cin >> productos[i].proveedor.nombre;
        cout << "Telefono: ";
        cin >> productos[i].proveedor.telefono;
        cout << "Direccion: ";
        cin >> productos[i].proveedor.direccion;

        productos[i].valorInventario = productos[i].precioUnitario * productos[i].stock;
    }

    cout << "\n--- Inventario de Productos ---\n";
    for (int i = 0; i < n; i++) {
        cout << "Producto: " << productos[i].nombre
             << " | Codigo: " << productos[i].codigo
             << " | Precio: " << productos[i].precioUnitario
             << " | Stock: " << productos[i].stock
             << " | Proveedor: " << productos[i].proveedor.nombre
             << " | Valor inventario: " << productos[i].valorInventario
             << endl;
    }

    return 0;
}

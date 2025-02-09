/*
Ejercicio 8: Registro de Productos en Tienda Online y Modificación de Stock

Crea un programa donde se cree un registro para almacenar el nombre, precio, descripción y existencias 
de n productos de una tienda online. El programa debe permitir al usuario modificar las existencias 
de cada producto (agregar o quitar unidades). Luego, debe mostrar los registros ingresados y el inventario 
final con el valor total de cada producto (precio * existencias).
*/

#include <iostream>
using namespace std;

struct Producto {
    string nombre;
    float precio;
    string descripcion;
    int existencias;
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
        cout << "Precio: ";
        cin >> productos[i].precio;
        cout << "Descripcion: ";
        cin >> productos[i].descripcion;
        cout << "Existencias: ";
        cin >> productos[i].existencias;

        // Modificar existencias
        int cambio;
        cout << "Ingrese cantidad a modificar (positivo = agregar, negativo = quitar): ";
        cin >> cambio;
        productos[i].existencias += cambio;

        if (productos[i].existencias < 0) {
            productos[i].existencias = 0; // evitar existencias negativas
        }
    }

    cout << "\n--- Inventario Final ---\n";
    for (int i = 0; i < n; i++) {
        float valorTotal = productos[i].precio * productos[i].existencias;
        cout << "Producto: " << productos[i].nombre
             << " | Descripcion: " << productos[i].descripcion
             << " | Precio: " << productos[i].precio
             << " | Stock final: " << productos[i].existencias
             << " | Valor total: " << valorTotal
             << endl;
    }

    return 0;
}

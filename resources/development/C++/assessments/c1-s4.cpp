/*
--------------------------------------------------------------
EVALUACIÓN N°01 - ESTRUCTURA DE DATOS
Primera Unidad: Estructura de Datos Estática - Arrays
Caso: Gestión de Stock de Productos en una Tienda
Alumno: [Tu nombre]
Docente: Mgt. Yesenia Concha Ramos
--------------------------------------------------------------
DESCRIPCIÓN GENERAL:
Este programa permite gestionar el stock de productos en una tienda de electrodomésticos.
El sistema usa un ARREGLO UNIDIMENSIONAL (array dinámico) para almacenar las cantidades
de cada producto. Permite:
 - Buscar stock por índice.
 - Actualizar stock con validación (no negativos).
 - Ordenar los valores de stock de menor a mayor.
 - Mostrar el arreglo completo.
 - Salir del sistema.

Conceptos aplicados hasta la Semana 4:
 - Arreglos unidimensionales
 - Bucle FOR y DO-WHILE
 - Condicionales IF
 - Validación de datos
--------------------------------------------------------------
*/

#include <iostream>
using namespace std;

int main() {
    int n;

    cout << "==============================================\n";
    cout << "   SISTEMA DE GESTION DE STOCK - TIENDA XYZ\n";
    cout << "==============================================\n\n";

    // 1. INGRESO DEL TAMAÑO DEL ARREGLO
    cout << "Ingrese cantidad de productos a registrar: ";
    cin >> n;

    // Validar que el tamaño sea positivo
    while (n <= 0) {
        cout << "Error: La cantidad de productos debe ser mayor que 0. Intente de nuevo: ";
        cin >> n;
    }

    // Crear arreglo dinámico para almacenar los stocks
    int* stock = new int[n];

    cout << "\nIngrese las cantidades de stock para cada producto:\n";

    // 2. INGRESO DE STOCKS CON VALIDACIÓN
    for (int i = 0; i < n; i++) {
        do {
            cout << "Stock para el producto N°" << (i + 1) << ": ";
            int cantidad;
            cin >> cantidad;

            if (cantidad >= 0) {
                stock[i] = cantidad; // Asigna el valor al arreglo
                break; // Sale del bucle si el valor es válido
            } else {
                cout << "Error: El stock no puede ser negativo. Intente nuevamente.\n";
            }
        } while (true);
    }

    int op; // variable para el menú

    // 3. MENÚ PRINCIPAL
    do {
        cout << "\n========= MENU DE INVENTARIO =========\n";
        cout << "[1] Buscar stock por índice\n";
        cout << "[2] Actualizar stock por índice\n";
        cout << "[3] Ordenar stock de menor a mayor\n";
        cout << "[4] Mostrar todo el stock\n";
        cout << "[5] Salir\n";
        cout << "Seleccione una opción [1-5]: ";
        cin >> op;

        // 4. OPCIONES DEL MENÚ
        if (op == 1) {
            // --- BÚSQUEDA POR ÍNDICE ---
            int indice;
            cout << "Ingrese el índice del producto (0 - " << (n - 1) << "): ";
            cin >> indice;

            if (indice >= 0 && indice < n) {
                cout << "Stock del producto en índice " << indice
                     << ": " << stock[indice] << " unidades disponibles.\n";
            } else {
                cout << "Error: Índice fuera de rango.\n";
            }

        } else if (op == 2) {
            // --- ACTUALIZACIÓN DE STOCK ---
            int indice;
            cout << "Ingrese el índice del producto a actualizar (0 - " << (n - 1) << "): ";
            cin >> indice;

            if (indice >= 0 && indice < n) {
                cout << "Stock actual: " << stock[indice] << " unidades.\n";
                cout << "Ingrese la nueva cantidad: ";
                int nuevoStock;
                cin >> nuevoStock;

                if (nuevoStock >= 0) {
                    stock[indice] = nuevoStock;
                    cout << "Stock actualizado exitosamente.\n";
                } else {
                    cout << "Error: El nuevo stock no puede ser negativo.\n";
                }
            } else {
                cout << "Error: Índice fuera de rango.\n";
            }

        } else if (op == 3) {
            // --- ORDENAMIENTO BURBUJA ---
            for (int i = 0; i < n - 1; i++) {
                for (int j = 0; j < n - i - 1; j++) {
                    if (stock[j] > stock[j + 1]) {
                        int temp = stock[j];
                        stock[j] = stock[j + 1];
                        stock[j + 1] = temp;
                    }
                }
            }
            cout << "Stock ordenado de menor a mayor exitosamente.\n";

        } else if (op == 4) {
            // --- MOSTRAR ARREGLO COMPLETO ---
            cout << "\n=== LISTA COMPLETA DE STOCK ===\n";
            for (int i = 0; i < n; i++) {
                cout << "Producto " << (i + 1) << " (índice " << i
                     << "): " << stock[i] << " unidades.\n";
            }

        } else if (op == 5) {
            cout << "Saliendo del programa. ¡Gracias!\n";
        } else {
            cout << "Opción inválida. Ingrese una opción del 1 al 5.\n";
        }

    } while (op != 5);

    // Liberar la memoria usada por el arreglo dinámico
    delete[] stock;

    return 0;
}


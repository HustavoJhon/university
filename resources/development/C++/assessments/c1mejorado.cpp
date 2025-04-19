/*
------------------------------------------------------------
PROGRAMA: Sistema de Gestión de Flota de Vehículos
AUTOR: [Tu nombre]
FECHA: [Fecha actual]
DESCRIPCIÓN:
    Este programa permite gestionar una flota de vehículos 
    (autos, buses, camiones) de una empresa de transporte.
    Se implementa utilizando únicamente los conocimientos 
    hasta la Semana 7 del curso: estructuras, arreglos, 
    punteros, funciones y validaciones con cadenas C.
------------------------------------------------------------
*/

#include <iostream>
#include <cstring>

using namespace std;

// ------------------------------------------------------------
// ESTRUCTURA PRINCIPAL: Vehículo
// ------------------------------------------------------------
struct Vehiculo {
    int id;
    char placa[20];
    char tipo[20];
    int capacidad;
    float kilometraje;
    char estado[20];
    float costoDiario;
};

// Arreglo estático de vehículos y contador global
Vehiculo flota[100];
int totalVehiculos = 0;

// ------------------------------------------------------------
// FUNCIONES DE VALIDACIÓN
// ------------------------------------------------------------

/// Verifica si un ID ya está registrado
bool idExiste(int id) {
    for (Vehiculo* ptr = flota; ptr < flota + totalVehiculos; ptr++) {
        if (ptr->id == id) return true;
    }
    return false;
}

/// Verifica si el tipo ingresado es válido
bool tipoValido(const char tipo[]) {
    return (strcmp(tipo, "auto") == 0 || strcmp(tipo, "bus") == 0 || strcmp(tipo, "camion") == 0);
}

/// Verifica si el estado ingresado es válido
bool estadoValido(const char estado[]) {
    return (strcmp(estado, "activo") == 0 || strcmp(estado, "mantenimiento") == 0);
}

// ------------------------------------------------------------
// REGISTRO DE VEHÍCULOS
// ------------------------------------------------------------

/// Permite registrar un vehículo con todas las validaciones necesarias
void registrarVehiculo() {
    if (totalVehiculos >= 100) {
        cout << "⚠️ No se pueden registrar más vehículos.\n";
        return;
    }

    Vehiculo v;
    Vehiculo* p = &v; // puntero al vehículo actual

    do {
        cout << "Ingrese ID del vehículo: ";
        cin >> p->id;
        if (cin.fail() || p->id < 0 || idExiste(p->id)) {
            cin.clear(); cin.ignore(10000, '\n');
            cout << "Error: ID inválido o ya existente.\n";
            p->id = -1;
        }
    } while (p->id < 0);

    do {
        cout << "Ingrese placa: ";
        cin >> p->placa;
        if (strlen(p->placa) == 0)
            cout << "Error: Placa no puede estar vacía.\n";
    } while (strlen(p->placa) == 0);

    do {
        cout << "Ingrese tipo (auto/bus/camion): ";
        cin >> p->tipo;
        if (!tipoValido(p->tipo))
            cout << "Error: Tipo inválido.\n";
    } while (!tipoValido(p->tipo));

    do {
        cout << "Ingrese capacidad: ";
        cin >> p->capacidad;
        if (cin.fail() || p->capacidad <= 0) {
            cin.clear(); cin.ignore(10000, '\n');
            cout << "Error: Capacidad debe ser positiva.\n";
            p->capacidad = -1;
        }
    } while (p->capacidad <= 0);

    do {
        cout << "Ingrese kilometraje: ";
        cin >> p->kilometraje;
        if (cin.fail() || p->kilometraje < 0) {
            cin.clear(); cin.ignore(10000, '\n');
            cout << "Error: Kilometraje inválido.\n";
            p->kilometraje = -1;
        }
    } while (p->kilometraje < 0);

    do {
        cout << "Ingrese estado (activo/mantenimiento): ";
        cin >> p->estado;
        if (!estadoValido(p->estado))
            cout << "Error: Estado inválido.\n";
    } while (!estadoValido(p->estado));

    do {
        cout << "Ingrese costo diario: ";
        cin >> p->costoDiario;
        if (cin.fail() || p->costoDiario < 0) {
            cin.clear(); cin.ignore(10000, '\n');
            cout << "Error: Costo inválido.\n";
            p->costoDiario = -1;
        }
    } while (p->costoDiario < 0);

    // Almacenar en el arreglo global
    flota[totalVehiculos++] = v;
    cout << "✅ Vehículo registrado exitosamente.\n";
}

// ------------------------------------------------------------
// BÚSQUEDA DE VEHÍCULOS (por ID)
// ------------------------------------------------------------
void buscarVehiculo() {
    if (totalVehiculos == 0) {
        cout << "No hay vehículos registrados.\n";
        return;
    }

    int id;
    cout << "Ingrese ID a buscar: ";
    cin >> id;

    Vehiculo* ptr = flota;
    for (; ptr < flota + totalVehiculos; ptr++) {
        if (ptr->id == id) {
            cout << "\n--- Vehículo encontrado ---\n";
            cout << "ID: " << ptr->id << "\n";
            cout << "Placa: " << ptr->placa << "\n";
            cout << "Tipo: " << ptr->tipo << "\n";
            cout << "Capacidad: " << ptr->capacidad << "\n";
            cout << "Kilometraje: " << ptr->kilometraje << "\n";
            cout << "Estado: " << ptr->estado << "\n";
            cout << "Costo Diario: " << ptr->costoDiario << "\n";
            return;
        }
    }
    cout << "Vehículo no encontrado.\n";
}

// ------------------------------------------------------------
// ACTUALIZAR ESTADO
// ------------------------------------------------------------
void actualizarEstado() {
    int id;
    cout << "Ingrese ID del vehículo: ";
    cin >> id;

    for (Vehiculo* ptr = flota; ptr < flota + totalVehiculos; ptr++) {
        if (ptr->id == id) {
            char nuevoEstado[20];
            do {
                cout << "Ingrese nuevo estado (activo/mantenimiento): ";
                cin >> nuevoEstado;
                if (!estadoValido(nuevoEstado))
                    cout << "Error: Estado inválido.\n";
            } while (!estadoValido(nuevoEstado));

            strcpy(ptr->estado, nuevoEstado);
            cout << "✅ Estado actualizado.\n";
            return;
        }
    }
    cout << "Vehículo no encontrado.\n";
}

// ------------------------------------------------------------
// ACTUALIZAR KILOMETRAJE
// ------------------------------------------------------------
void actualizarKilometraje() {
    int id;
    cout << "Ingrese ID del vehículo: ";
    cin >> id;

    for (Vehiculo* ptr = flota; ptr < flota + totalVehiculos; ptr++) {
        if (ptr->id == id) {
            float nuevoKm;
            do {
                cout << "Ingrese nuevo kilometraje: ";
                cin >> nuevoKm;
                if (cin.fail() || nuevoKm < ptr->kilometraje) {
                    cin.clear(); cin.ignore(10000, '\n');
                    cout << "Error: El kilometraje no puede ser menor.\n";
                    nuevoKm = -1;
                }
            } while (nuevoKm < 0);
            ptr->kilometraje = nuevoKm;
            cout << "✅ Kilometraje actualizado.\n";
            return;
        }
    }
    cout << "Vehículo no encontrado.\n";
}

// ------------------------------------------------------------
// ORDENAR POR COSTO DIARIO (BURBUJA)
// ------------------------------------------------------------
void ordenarPorCosto() {
    for (int i = 0; i < totalVehiculos - 1; i++) {
        for (int j = 0; j < totalVehiculos - i - 1; j++) {
            Vehiculo* a = &flota[j];
            Vehiculo* b = &flota[j + 1];
            if (a->costoDiario > b->costoDiario) {
                Vehiculo temp = *a;
                *a = *b;
                *b = temp;
            }
        }
    }
    cout << "✅ Vehículos ordenados por costo diario.\n";
}

// ------------------------------------------------------------
// MOSTRAR TODOS LOS VEHÍCULOS
// ------------------------------------------------------------
void mostrarVehiculos() {
    if (totalVehiculos == 0) {
        cout << "No hay vehículos registrados.\n";
        return;
    }

    int i = 1;
    for (Vehiculo* ptr = flota; ptr < flota + totalVehiculos; ptr++, i++) {
        cout << "\nVehículo " << i << ":\n";
        cout << "ID: " << ptr->id << "\n";
        cout << "Placa: " << ptr->placa << "\n";
        cout << "Tipo: " << ptr->tipo << "\n";
        cout << "Capacidad: " << ptr->capacidad << "\n";
        cout << "Kilometraje: " << ptr->kilometraje << "\n";
        cout << "Estado: " << ptr->estado << "\n";
        cout << "Costo Diario: " << ptr->costoDiario << "\n";
    }
}

// ------------------------------------------------------------
// CALCULAR COSTO TOTAL DIARIO
// ------------------------------------------------------------
void calcularCostoTotal() {
    float total = 0;
    for (Vehiculo* ptr = flota; ptr < flota + totalVehiculos; ptr++) {
        if (strcmp(ptr->estado, "activo") == 0)
            total += ptr->costoDiario;
    }
    cout.precision(2);
    cout << fixed;
    cout << "\n💰 Costo total diario de operación (activos): " << total << endl;
}

// ------------------------------------------------------------
// MENÚ PRINCIPAL
// ------------------------------------------------------------
void mostrarMenu() {
    cout << "\n=== MENÚ DE GESTIÓN DE FLOTA ===\n";
    cout << "1. Registrar vehículo\n";
    cout << "2. Buscar vehículo\n";
    cout << "3. Actualizar estado\n";
    cout << "4. Actualizar kilometraje\n";
    cout << "5. Ordenar por costo diario\n";
    cout << "6. Mostrar todos los vehículos\n";
    cout << "7. Calcular costo total diario\n";
    cout << "8. Salir\n";
    cout << "Seleccione una opción: ";
}

// ------------------------------------------------------------
// FUNCIÓN PRINCIPAL
// ------------------------------------------------------------
int main() {
    int opcion;
    do {
        mostrarMenu();
        cin >> opcion;

        switch (opcion) {
            case 1: registrarVehiculo(); break;
            case 2: buscarVehiculo(); break;
            case 3: actualizarEstado(); break;
            case 4: actualizarKilometraje(); break;
            case 5: ordenarPorCosto(); break;
            case 6: mostrarVehiculos(); break;
            case 7: calcularCostoTotal(); break;
            case 8: cout << "👋 Saliendo del sistema...\n"; break;
            default: cout << "Opción inválida.\n";
        }
    } while (opcion != 8);

    return 0;
}


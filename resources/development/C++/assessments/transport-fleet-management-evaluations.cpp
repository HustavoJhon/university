#include <iostream>
#include <cstring> // Librería para manejo de cadenas C-style (strcmp, strcpy, strlen, etc.)

using namespace std;

/*
 * ================================================
 *  SISTEMA DE GESTIÓN DE FLOTA VEHICULAR
 * ================================================
 *  Este programa permite registrar, consultar, actualizar
 *  y ordenar vehículos almacenados en memoria.
 *
 *  Utiliza los siguientes conceptos vistos hasta la semana 7:
 *   - Estructuras (struct)
 *   - Arreglos unidimensionales
 *   - Búsqueda secuencial y binaria
 *   - Ordenamiento por burbuja
 *   - Cadenas de caracteres (char[])
 *   - Punteros implícitos (al usar arreglos y structs)
 *   - Validación de datos
 */

// Estructura que representa un vehículo
struct Vehiculo {
    int id;
    char placa[20];
    char tipo[20];
    int capacidad;
    float kilometraje;
    char estado[20];
    float costoDiario;
};

// Arreglo global que almacena los vehículos registrados
Vehiculo flota[100];
int totalVehiculos = 0; // Contador global de vehículos registrados

// -----------------------------------------------------------------------------
// FUNCIONES DE VALIDACIÓN
// -----------------------------------------------------------------------------

// Verifica si un ID ya existe dentro del arreglo "flota"
bool idExiste(int id) {
    for (int i = 0; i < totalVehiculos; i++) {
        if (flota[i].id == id) {
            return true;
        }
    }
    return false;
}

// Comprueba si el tipo de vehículo ingresado es válido
bool tipoValido(char tipo[]) {
    return (strcmp(tipo, "auto") == 0 || strcmp(tipo, "bus") == 0 || strcmp(tipo, "camion") == 0);
}

// -----------------------------------------------------------------------------
// FUNCIONES DE REGISTRO
// -----------------------------------------------------------------------------

// Registra un solo vehículo, validando todos sus datos
void registrarUnVehiculo() {
    if (totalVehiculos >= 100) {
        cout << "No se pueden registrar mas vehiculos." << endl;
        return;
    }

    Vehiculo v;

    // Ingreso y validación de ID
    do {
        cout << "Ingrese ID del vehiculo: ";
        cin >> v.id;
        if (cin.fail()) {
            cin.clear();
            cin.ignore(10000, '\n');
            cout << "Error: Debe ingresar un numero entero." << endl;
            v.id = -1;
        } else if (idExiste(v.id)) {
            cout << "Error: El ID ya existe. Ingrese uno diferente." << endl;
        }
    } while (idExiste(v.id) || v.id < 0);

    // Ingreso y validación de placa
    do {
        cout << "Ingrese placa: ";
        cin >> v.placa;
        if (strlen(v.placa) == 0) {
            cout << "Error: La placa no puede estar vacia." << endl;
        }
    } while (strlen(v.placa) == 0);

    // Ingreso y validación del tipo
    do {
        cout << "Ingrese tipo (auto/bus/camion): ";
        cin >> v.tipo;
        if (!tipoValido(v.tipo)) {
            cout << "Error: Tipo invalido. Debe ser auto, bus o camion." << endl;
        }
    } while (!tipoValido(v.tipo));

    // Ingreso y validación de capacidad
    do {
        cout << "Ingrese capacidad: ";
        cin >> v.capacidad;
        if (cin.fail()) {
            cin.clear();
            cin.ignore(10000, '\n');
            cout << "Error: Debe ingresar un numero entero." << endl;
            v.capacidad = -1;
        } else if (v.capacidad <= 0) {
            cout << "Error: La capacidad debe ser positiva." << endl;
        }
    } while (v.capacidad <= 0);

    // Ingreso y validación de kilometraje
    do {
        cout << "Ingrese kilometraje: ";
        cin >> v.kilometraje;
        if (cin.fail()) {
            cin.clear();
            cin.ignore(10000, '\n');
            cout << "Error: Debe ingresar un numero." << endl;
            v.kilometraje = -1;
        } else if (v.kilometraje < 0) {
            cout << "Error: El kilometraje no puede ser negativo." << endl;
        }
    } while (v.kilometraje < 0);

    // Ingreso y validación del estado
    do {
        cout << "Ingrese estado (activo/mantenimiento): ";
        cin >> v.estado;
        if (strcmp(v.estado, "activo") != 0 && strcmp(v.estado, "mantenimiento") != 0) {
            cout << "Error: Estado invalido." << endl;
        }
    } while (strcmp(v.estado, "activo") != 0 && strcmp(v.estado, "mantenimiento") != 0);

    // Ingreso y validación del costo diario
    do {
        cout << "Ingrese costo diario: ";
        cin >> v.costoDiario;
        if (cin.fail()) {
            cin.clear();
            cin.ignore(10000, '\n');
            cout << "Error: Debe ingresar un numero." << endl;
            v.costoDiario = -1;
        } else if (v.costoDiario < 0) {
            cout << "Error: El costo diario debe ser mayor o igual a 0." << endl;
        }
    } while (v.costoDiario < 0);

    // Almacenar el vehículo en el arreglo
    flota[totalVehiculos] = v;
    totalVehiculos++;

    cout << "Vehiculo registrado exitosamente!" << endl;
}

// Permite registrar varios vehículos de una sola vez
void registrarVehiculos() {
    int n;

    do {
        cout << "\nCuantos vehiculos desea registrar? ";
        cin >> n;

        if (cin.fail()) {
            cin.clear();
            cin.ignore(10000, '\n');
            cout << "Error: Debe ingresar un numero entero." << endl;
            n = 0;
        } else if (n <= 0) {
            cout << "Error: Debe registrar al menos 1 vehiculo." << endl;
        } else if (totalVehiculos + n > 100) {
            cout << "Error: Espacio insuficiente. Solo puede registrar "
                 << (100 - totalVehiculos) << " vehiculos mas." << endl;
            n = 0;
        }
    } while (n <= 0);

    cout << "\n=== Registro de " << n << " vehiculos ===" << endl;

    for (int i = 0; i < n; i++) {
        cout << "\n--- Vehiculo " << (i + 1) << " de " << n << " ---" << endl;
        registrarUnVehiculo();
    }

    cout << "\n¡Registro completado exitosamente!" << endl;
}

// -----------------------------------------------------------------------------
// FUNCIONES DE CONSULTA Y ACTUALIZACIÓN
// -----------------------------------------------------------------------------

// Permite buscar un vehículo por ID o placa
void buscarVehiculo() {
    if (totalVehiculos == 0) {
        cout << "No hay vehiculos registrados." << endl;
        return;
    }

    int opcionBusqueda;
    cout << "\n=== BUSCAR VEHICULO ===" << endl;
    cout << "1. Buscar por ID" << endl;
    cout << "2. Buscar por Placa" << endl;
    cout << "Seleccione una opcion: ";
    cin >> opcionBusqueda;

    // Búsqueda binaria por ID
    if (opcionBusqueda == 1) {
        // Ordenar por ID antes de buscar
        for (int i = 0; i < totalVehiculos - 1; i++) {
            for (int j = 0; j < totalVehiculos - i - 1; j++) {
                if (flota[j].id > flota[j + 1].id) {
                    Vehiculo temp = flota[j];
                    flota[j] = flota[j + 1];
                    flota[j + 1] = temp;
                }
            }
        }

        int id;
        cout << "Ingrese ID a buscar: ";
        cin >> id;

        int izquierda = 0, derecha = totalVehiculos - 1;
        bool encontrado = false;

        while (izquierda <= derecha) {
            int medio = (izquierda + derecha) / 2;

            if (flota[medio].id == id) {
                cout << "\n--- Vehiculo Encontrado ---" << endl;
                cout << "ID: " << flota[medio].id << endl;
                cout << "Placa: " << flota[medio].placa << endl;
                cout << "Tipo: " << flota[medio].tipo << endl;
                cout << "Capacidad: " << flota[medio].capacidad << endl;
                cout << "Kilometraje: " << flota[medio].kilometraje << endl;
                cout << "Estado: " << flota[medio].estado << endl;
                cout << "Costo diario: " << flota[medio].costoDiario << endl;
                encontrado = true;
                break;
            }

            if (flota[medio].id < id)
                izquierda = medio + 1;
            else
                derecha = medio - 1;
        }

        if (!encontrado) cout << "Vehiculo no encontrado." << endl;
    }
    // Búsqueda secuencial por placa
    else if (opcionBusqueda == 2) {
        char placaBuscar[20];
        cout << "Ingrese placa a buscar: ";
        cin >> placaBuscar;

        bool encontrado = false;

        for (int i = 0; i < totalVehiculos; i++) {
            if (strcmp(flota[i].placa, placaBuscar) == 0) {
                cout << "\n--- Vehiculo Encontrado ---" << endl;
                cout << "ID: " << flota[i].id << endl;
                cout << "Placa: " << flota[i].placa << endl;
                cout << "Tipo: " << flota[i].tipo << endl;
                cout << "Capacidad: " << flota[i].capacidad << endl;
                cout << "Kilometraje: " << flota[i].kilometraje << endl;
                cout << "Estado: " << flota[i].estado << endl;
                cout << "Costo diario: " << flota[i].costoDiario << endl;
                encontrado = true;
                break;
            }
        }

        if (!encontrado) cout << "Vehiculo con placa '" << placaBuscar << "' no encontrado." << endl;
    } else {
        cout << "Opcion invalida." << endl;
    }
}

// Actualiza el estado (activo/mantenimiento) de un vehículo según su ID
void actualizarEstado() {
    int id;
    cout << "Ingrese ID del vehiculo: ";
    cin >> id;

    bool encontrado = false;
    for (int i = 0; i < totalVehiculos; i++) {
        if (flota[i].id == id) {
            char nuevoEstado[20];
            do {
                cout << "Ingrese nuevo estado (activo/mantenimiento): ";
                cin >> nuevoEstado;
            } while (strcmp(nuevoEstado, "activo") != 0 && strcmp(nuevoEstado, "mantenimiento") != 0);

            strcpy(flota[i].estado, nuevoEstado);
            cout << "Estado actualizado exitosamente!" << endl;
            encontrado = true;
            break;
        }
    }

    if (!encontrado) cout << "Vehiculo no encontrado." << endl;
}

// Actualiza el kilometraje de un vehículo (no puede disminuir)
void actualizarKilometraje() {
    int id;
    cout << "Ingrese ID del vehiculo: ";
    cin >> id;

    bool encontrado = false;
    for (int i = 0; i < totalVehiculos; i++) {
        if (flota[i].id == id) {
            float nuevoKm;
            do {
                cout << "Ingrese nuevo kilometraje: ";
                cin >> nuevoKm;
                if (nuevoKm < flota[i].kilometraje) {
                    cout << "Error: El kilometraje no puede ser menor al actual (" 
                         << flota[i].kilometraje << ")." << endl;
                }
            } while (nuevoKm < flota[i].kilometraje);
            flota[i].kilometraje = nuevoKm;
            cout << "Kilometraje actualizado correctamente!" << endl;
            encontrado = true;
            break;
        }
    }

    if (!encontrado) cout << "Vehiculo no encontrado." << endl;
}

// -----------------------------------------------------------------------------
// FUNCIONES DE ORDENAMIENTO Y REPORTE
// -----------------------------------------------------------------------------

// Ordena los vehículos por costo diario (método burbuja)
void ordenarPorCosto() {
    for (int i = 0; i < totalVehiculos - 1; i++) {
        for (int j = 0; j < totalVehiculos - i - 1; j++) {
            if (flota[j].costoDiario > flota[j + 1].costoDiario) {
                Vehiculo temp = flota[j];
                flota[j] = flota[j + 1];
                flota[j + 1] = temp;
            }
        }
    }
    cout << "Vehiculos ordenados por costo diario!" << endl;
}

// Muestra la lista completa de vehículos registrados
void mostrarVehiculos() {
    if (totalVehiculos == 0) {
        cout << "No hay vehiculos registrados." << endl;
        return;
    }

    cout << "\n=== LISTA DE VEHICULOS ===" << endl;
    for (int i = 0; i < totalVehiculos; i++) {
        cout << "\nVehiculo " << (i + 1) << ":" << endl;
        cout << "ID: " << flota[i].id << endl;
        cout << "Placa: " << flota[i].placa << endl;
        cout << "Tipo: " << flota[i].tipo << endl;
        cout << "Capacidad: " << flota[i].capacidad << endl;
        cout << "Kilometraje: " << flota[i].kilometraje << endl;
        cout << "Estado: " << flota[i].estado << endl;
        cout << "Costo diario: " << flota[i].costoDiario << endl;
    }
}

// Calcula el costo total diario de operación de vehículos activos
void calcularCostoTotal() {
    float total = 0.0;
    for (int i = 0; i < totalVehiculos; i++) {
        if (strcmp(flota[i].estado, "activo") == 0) {
            total += flota[i].costoDiario;
        }
    }
    cout << "Costo total diario de vehiculos activos: S/. " << total << endl;
}

// -----------------------------------------------------------------------------
// MENÚ PRINCIPAL
// -----------------------------------------------------------------------------

void mostrarMenu() {
    cout << "\n=== SISTEMA DE GESTION DE FLOTA ===" << endl;
    cout << "1. Registrar vehiculos" << endl;
    cout << "2. Buscar vehiculo" << endl;
    cout << "3. Actualizar estado del vehiculo" << endl;
    cout << "4. Actualizar kilometraje" << endl;
    cout << "5. Ordenar vehiculos por costo diario" << endl;
    cout << "6. Mostrar todos los vehiculos" << endl;
    cout << "7. Calcular costo total diario" << endl;
    cout << "8. Salir" << endl;
    cout << "Seleccione una opcion: ";
}

// Función principal del programa
int main() {
    int opcion;

    do {
        mostrarMenu();
        cin >> opcion;

        if (cin.fail()) {
            cin.clear();
            cin.ignore(10000, '\n');
            cout << "Opcion invalida. Debe ingresar un numero." << endl;
            continue;
        }

        switch (opcion) {
            case 1: registrarVehiculos(); break;
            case 2: buscarVehiculo(); break;
            case 3: actualizarEstado(); break;
            case 4: actualizarKilometraje(); break;
            case 5: ordenarPorCosto(); break;
            case 6: mostrarVehiculos(); break;
            case 7: calcularCostoTotal(); break;
            case 8: cout << "Saliendo del sistema..." << endl; break;
            default: cout << "Opcion invalida." << endl;
        }

    } while (opcion != 8);

    return 0;
}


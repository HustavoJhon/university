#include <cctype>
#include <cstring>
#include <iostream>
using namespace std;

struct Reserva {
  int id_reserva;
  char nombre_huesped[50];
  char apellido_huesped[50];
  int numero_habitacion;
  char fecha_entrada[20];
  char fecha_salida[20];
  int num_personas;
  float monto_total;
};

// Prototipos
void registrarReserva(Reserva reservas[], int &n);
void mostrarReservas(Reserva reservas[], int n);
void convertirNombresMayusculas(Reserva reservas[], int n);
void mostrarReservaMayorMonto(Reserva reservas[], int n);
void mostrarReservasPorHabitacion(Reserva reservas[], int n);

int main() {
  Reserva reservas[100];
  int n = 0;
  int opcion;

  do {
    cout << "\n===== SISTEMA DE GESTION DE RESERVAS =====\n";
    cout << "1. Registrar reserva\n";
    cout << "2. Mostrar todas las reservas\n";
    cout << "6. Convertir nombres y apellidos a mayusculas\n";
    cout << "8. Mostrar reserva con mayor monto total\n";
    cout << "9. Mostrar reservas por habitacion\n";
    cout << "0. Salir\n";
    cout << "Seleccione una opcion: ";
    cin >> opcion;
    cin.ignore(); // limpiar buffer

    switch (opcion) {
    case 1:
      registrarReserva(reservas, n);
      break;
    case 2:
      mostrarReservas(reservas, n);
      break;
    case 6:
      convertirNombresMayusculas(reservas, n);
      break;
    case 8:
      mostrarReservaMayorMonto(reservas, n);
      break;
    case 9:
      mostrarReservasPorHabitacion(reservas, n);
      break;
    case 0:
      cout << "Saliendo del programa...\n";
      break;
    default:
      cout << "Opcion invalida. Intente nuevamente.\n";
    }

  } while (opcion != 0);

  return 0;
}

//-----------------------------------------------------------
// 1️⃣ Registrar reserva
//-----------------------------------------------------------
void registrarReserva(Reserva reservas[], int &n) {
  cout << "\n--- REGISTRO DE NUEVA RESERVA ---\n";
  reservas[n].id_reserva = n + 1;

  cout << "Nombre del huesped: ";
  cin.getline(reservas[n].nombre_huesped, 50);
  cout << "Apellido del huesped: ";
  cin.getline(reservas[n].apellido_huesped, 50);

  cout << "Numero de habitacion: ";
  cin >> reservas[n].numero_habitacion;
  cin.ignore();

  cout << "Fecha de entrada: ";
  cin.getline(reservas[n].fecha_entrada, 20);
  cout << "Fecha de salida: ";
  cin.getline(reservas[n].fecha_salida, 20);

  cout << "Numero de personas: ";
  cin >> reservas[n].num_personas;
  cout << "Monto total (S/): ";
  cin >> reservas[n].monto_total;

  n++;
  cout << "Reserva registrada correctamente.\n";
}

//-----------------------------------------------------------
// 2️⃣ Mostrar todas las reservas
//-----------------------------------------------------------
void mostrarReservas(Reserva reservas[], int n) {
  if (n == 0) {
    cout << "No hay reservas registradas.\n";
    return;
  }

  cout << "\n--- LISTA DE RESERVAS ---\n";
  for (int i = 0; i < n; i++) {
    cout << "ID: " << reservas[i].id_reserva << endl;
    cout << "Nombre: " << reservas[i].nombre_huesped << " "
         << reservas[i].apellido_huesped << endl;
    cout << "Habitacion: " << reservas[i].numero_habitacion << endl;
    cout << "Entrada: " << reservas[i].fecha_entrada
         << " - Salida: " << reservas[i].fecha_salida << endl;
    cout << "Personas: " << reservas[i].num_personas << endl;
    cout << "Monto total: S/ " << reservas[i].monto_total << endl;
    cout << "-----------------------------\n";
  }
}

//-----------------------------------------------------------
// 6️⃣ Convertir todos los nombres y apellidos a mayúsculas
//-----------------------------------------------------------
void convertirNombresMayusculas(Reserva reservas[], int n) {
  if (n == 0) {
    cout << "No hay reservas registradas.\n";
    return;
  }

  for (int i = 0; i < n; i++) {
    for (int j = 0; reservas[i].nombre_huesped[j] != '\0'; j++)
      reservas[i].nombre_huesped[j] = toupper(reservas[i].nombre_huesped[j]);
    for (int j = 0; reservas[i].apellido_huesped[j] != '\0'; j++)
      reservas[i].apellido_huesped[j] =
          toupper(reservas[i].apellido_huesped[j]);
  }

  cout << "Todos los nombres y apellidos fueron convertidos a mayusculas.\n";
}

//-----------------------------------------------------------
// 8️⃣ Mostrar la reserva con mayor monto total
//-----------------------------------------------------------
void mostrarReservaMayorMonto(Reserva reservas[], int n) {
  if (n == 0) {
    cout << "No hay reservas registradas.\n";
    return;
  }

  int posMax = 0;
  for (int i = 1; i < n; i++) {
    if (reservas[i].monto_total > reservas[posMax].monto_total)
      posMax = i;
  }

  cout << "\n--- RESERVA CON MAYOR MONTO TOTAL ---\n";
  cout << "ID: " << reservas[posMax].id_reserva << endl;
  cout << "Nombre: " << reservas[posMax].nombre_huesped << " "
       << reservas[posMax].apellido_huesped << endl;
  cout << "Habitacion: " << reservas[posMax].numero_habitacion << endl;
  cout << "Entrada: " << reservas[posMax].fecha_entrada
       << " - Salida: " << reservas[posMax].fecha_salida << endl;
  cout << "Personas: " << reservas[posMax].num_personas << endl;
  cout << "Monto total: S/ " << reservas[posMax].monto_total << endl;
}

//-----------------------------------------------------------
// 9️⃣ Mostrar las reservas de una habitación específica
//-----------------------------------------------------------
void mostrarReservasPorHabitacion(Reserva reservas[], int n) {
  if (n == 0) {
    cout << "No hay reservas registradas.\n";
    return;
  }

  int numHabitacion;
  cout << "Ingrese el numero de habitacion: ";
  cin >> numHabitacion;

  bool encontrado = false;
  cout << "\n--- RESERVAS EN HABITACION " << numHabitacion << " ---\n";
  for (int i = 0; i < n; i++) {
    if (reservas[i].numero_habitacion == numHabitacion) {
      cout << "Nombre: " << reservas[i].nombre_huesped << " "
           << reservas[i].apellido_huesped << endl;
      cout << "Entrada: " << reservas[i].fecha_entrada
           << " - Salida: " << reservas[i].fecha_salida << endl;
      cout << "Monto total: S/ " << reservas[i].monto_total << endl;
      cout << "-----------------------------\n";
      encontrado = true;
    }
  }

  if (!encontrado)
    cout << "No existen reservas para esa habitacion.\n";
}

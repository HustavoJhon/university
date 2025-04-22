#include <cstring> // strlen, strcpy, strcat, strstr
#include <iostream>
using namespace std;

// ----------------------------------------------------------
// Constantes globales
// ----------------------------------------------------------
const int MAX_MIEMBROS = 200;
const int MAX_NOMBRE = 50;
const int MAX_APELLIDO = 50;
const int MAX_PLAN = 50;
const int MAX_FECHA = 11;
const int MAX_OBS = 200;

// ----------------------------------------------------------
// Definición del registro Miembro
// ----------------------------------------------------------
struct Miembro {
  int id_miembro;
  char nombre[MAX_NOMBRE];
  char apellido[MAX_APELLIDO];
  int edad;
  char plan[MAX_PLAN];
  float monto_pago;
  char fecha_ingreso[MAX_FECHA];
  char observaciones[MAX_OBS];
};

// ----------------------------------------------------------
// Prototipos de funciones
// ----------------------------------------------------------
void menuPrincipal(Miembro miembros[], int &n);
void menuMiembros(Miembro miembros[], int &n);
void menuCadenas(Miembro miembros[], int n);

int buscarPorID(Miembro miembros[], int n, int id);
bool idExiste(Miembro miembros[], int n, int id);

void agregarMiembro(Miembro miembros[], int &n);
void eliminarMiembro(Miembro miembros[], int &n);
void buscarMiembroPorID(Miembro miembros[], int n);
void mostrarMiembro(Miembro m);
void mostrarTodos(Miembro miembros[], int n);
void ordenarPorApellido(Miembro miembros[], int n);
void ordenarPorFecha(Miembro miembros[], int n);
float calcularTotal(Miembro miembros[], int n);

// Operaciones con cadenas
void buscarPorNombreOPlan(Miembro miembros[], int n);
void modificarDatos(Miembro miembros[], int n);
void concatenarNombreApellido(Miembro miembros[], int n);
void calcularLongitudCadenas(Miembro miembros[], int n);
void buscarPalabraEnObservaciones(Miembro miembros[], int n);

// ----------------------------------------------------------
// Función principal
// ----------------------------------------------------------
int main() {
  Miembro miembros[MAX_MIEMBROS];
  int cantidad = 0;

  menuPrincipal(miembros, cantidad);

  return 0;
}

// ----------------------------------------------------------
// Función de Menú Principal
// ----------------------------------------------------------
void menuPrincipal(Miembro miembros[], int &n) {
  int opcion;
  do {
    cout << "\n-----------------------------------------\n";
    cout << "SISTEMA DE GESTION DE MIEMBROS - GIMNASIO\n";
    cout << "-----------------------------------------\n";
    cout << "1. Operaciones con miembros (Arreglos)\n";
    cout << "2. Operaciones con cadenas (Miembros)\n";
    cout << "3. Salir\n";
    cout << "Seleccione una opcion: ";
    cin >> opcion;

    switch (opcion) {
    case 1:
      menuMiembros(miembros, n);
      break;
    case 2:
      menuCadenas(miembros, n);
      break;
    case 3:
      cout << "\nSaliendo del sistema...\n";
      break;
    default:
      cout << "Opcion invalida.\n";
    }
  } while (opcion != 3);
}

// ----------------------------------------------------------
// Submenú: Operaciones con Miembros
// ----------------------------------------------------------
void menuMiembros(Miembro miembros[], int &n) {
  int opcion;
  do {
    cout << "\n----------------------------------------\n";
    cout << "OPERACIONES CON MIEMBROS\n";
    cout << "----------------------------------------\n";
    cout << "1. Agregar nuevo miembro\n";
    cout << "2. Eliminar miembro\n";
    cout << "3. Buscar miembro por ID\n";
    cout << "4. Mostrar todos los miembros\n";
    cout << "5. Ordenar miembros por apellido o fecha\n";
    cout << "6. Calcular total de ingresos\n";
    cout << "7. Volver al menu principal\n";
    cout << "Seleccione una opcion: ";
    cin >> opcion;

    switch (opcion) {
    case 1:
      agregarMiembro(miembros, n);
      break;
    case 2:
      eliminarMiembro(miembros, n);
      break;
    case 3:
      buscarMiembroPorID(miembros, n);
      break;
    case 4:
      mostrarTodos(miembros, n);
      break;
    case 5:
      ordenarPorApellido(miembros, n);
      break;
    case 6:
      cout << "\nTotal de ingresos: S/ " << calcularTotal(miembros, n) << endl;
      break;
    case 7:
      break;
    default:
      cout << "Opcion invalida.\n";
    }
  } while (opcion != 7);
}

// ----------------------------------------------------------
// Submenú: Operaciones con Cadenas
// ----------------------------------------------------------
void menuCadenas(Miembro miembros[], int n) {
  int opcion;
  do {
    cout << "\n----------------------------------------\n";
    cout << "OPERACIONES CON CADENAS\n";
    cout << "----------------------------------------\n";
    cout << "1. Buscar miembro por nombre o plan\n";
    cout << "2. Modificar datos del miembro\n";
    cout << "3. Concatenar nombre y apellido\n";
    cout << "4. Calcular longitud de nombre o plan\n";
    cout << "5. Buscar palabra en observaciones\n";
    cout << "6. Volver al menu principal\n";
    cout << "Seleccione una opcion: ";
    cin >> opcion;

    switch (opcion) {
    case 1:
      buscarPorNombreOPlan(miembros, n);
      break;
    case 2:
      modificarDatos(miembros, n);
      break;
    case 3:
      concatenarNombreApellido(miembros, n);
      break;
    case 4:
      calcularLongitudCadenas(miembros, n);
      break;
    case 5:
      buscarPalabraEnObservaciones(miembros, n);
      break;
    case 6:
      break;
    default:
      cout << "Opcion invalida.\n";
    }
  } while (opcion != 6);
}

// ----------------------------------------------------------
// FUNCIONES PRINCIPALES DE MIEMBROS
// ----------------------------------------------------------
bool idExiste(Miembro miembros[], int n, int id) {
  for (int i = 0; i < n; i++)
    if (miembros[i].id_miembro == id)
      return true;
  return false;
}

int buscarPorID(Miembro miembros[], int n, int id) {
  for (int i = 0; i < n; i++)
    if (miembros[i].id_miembro == id)
      return i;
  return -1;
}

void agregarMiembro(Miembro miembros[], int &n) {
  if (n >= MAX_MIEMBROS) {
    cout << "No se pueden agregar mas miembros.\n";
    return;
  }

  Miembro m;
  cout << "\nIngrese ID: ";
  cin >> m.id_miembro;

  if (idExiste(miembros, n, m.id_miembro)) {
    cout << "El ID ya existe.\n";
    return;
  }

  cout << "Nombre: ";
  cin.ignore();
  cin.getline(m.nombre, MAX_NOMBRE);
  cout << "Apellido: ";
  cin.getline(m.apellido, MAX_APELLIDO);
  cout << "Edad: ";
  cin >> m.edad;
  cout << "Plan: ";
  cin.ignore();
  cin.getline(m.plan, MAX_PLAN);
  cout << "Monto de pago: ";
  cin >> m.monto_pago;
  cout << "Fecha de ingreso (dd/mm/aaaa): ";
  cin.ignore();
  cin.getline(m.fecha_ingreso, MAX_FECHA);
  cout << "Observaciones: ";
  cin.getline(m.observaciones, MAX_OBS);

  miembros[n] = m;
  n++;
  cout << "Miembro agregado correctamente.\n";
}

void eliminarMiembro(Miembro miembros[], int &n) {
  int id;
  cout << "Ingrese ID a eliminar: ";
  cin >> id;
  int pos = buscarPorID(miembros, n, id);
  if (pos == -1) {
    cout << "No se encontro el ID.\n";
    return;
  }
  for (int i = pos; i < n - 1; i++)
    miembros[i] = miembros[i + 1];
  n--;
  cout << "Miembro eliminado.\n";
}

void buscarMiembroPorID(Miembro miembros[], int n) {
  int id;
  cout << "Ingrese ID: ";
  cin >> id;
  int pos = buscarPorID(miembros, n, id);
  if (pos == -1)
    cout << "No encontrado.\n";
  else
    mostrarMiembro(miembros[pos]);
}

void mostrarMiembro(Miembro m) {
  cout << "\nID: " << m.id_miembro << "\nNombre: " << m.nombre
       << "\nApellido: " << m.apellido << "\nEdad: " << m.edad
       << "\nPlan: " << m.plan << "\nMonto: " << m.monto_pago
       << "\nFecha ingreso: " << m.fecha_ingreso
       << "\nObservaciones: " << m.observaciones << "\n";
}

void mostrarTodos(Miembro miembros[], int n) {
  if (n == 0) {
    cout << "No hay miembros registrados.\n";
    return;
  }
  for (int i = 0; i < n; i++) {
    cout << "\n--- Miembro " << (i + 1) << " ---";
    mostrarMiembro(miembros[i]);
  }
}

void ordenarPorApellido(Miembro miembros[], int n) {
  Miembro aux;
  for (int i = 0; i < n - 1; i++)
    for (int j = 0; j < n - i - 1; j++)
      if (strcmp(miembros[j].apellido, miembros[j + 1].apellido) > 0) {
        aux = miembros[j];
        miembros[j] = miembros[j + 1];
        miembros[j + 1] = aux;
      }
  cout << "Miembros ordenados por apellido.\n";
}

float calcularTotal(Miembro miembros[], int n) {
  float total = 0;
  for (int i = 0; i < n; i++)
    total += miembros[i].monto_pago;
  return total;
}

// ----------------------------------------------------------
// FUNCIONES DE CADENAS
// ----------------------------------------------------------
void buscarPorNombreOPlan(Miembro miembros[], int n) {
  char palabra[50];
  cout << "Ingrese nombre o plan a buscar: ";
  cin.ignore();
  cin.getline(palabra, 50);

  for (int i = 0; i < n; i++) {
    if (strstr(miembros[i].nombre, palabra) ||
        strstr(miembros[i].plan, palabra))
      mostrarMiembro(miembros[i]);
  }
}

void modificarDatos(Miembro miembros[], int n) {
  int id;
  cout << "Ingrese ID a modificar: ";
  cin >> id;
  int pos = buscarPorID(miembros, n, id);
  if (pos == -1) {
    cout << "No encontrado.\n";
    return;
  }

  cout << "Nuevo nombre: ";
  cin.ignore();
  cin.getline(miembros[pos].nombre, MAX_NOMBRE);
  cout << "Nuevo plan: ";
  cin.getline(miembros[pos].plan, MAX_PLAN);
  cout << "Nuevo monto: ";
  cin >> miembros[pos].monto_pago;

  cout << "Datos modificados correctamente.\n";
}

void concatenarNombreApellido(Miembro miembros[], int n) {
  int id;
  cout << "Ingrese ID: ";
  cin >> id;
  int pos = buscarPorID(miembros, n, id);
  if (pos == -1) {
    cout << "No encontrado.\n";
    return;
  }

  char nombreCompleto[101];
  strcpy(nombreCompleto, miembros[pos].nombre);
  strcat(nombreCompleto, " ");
  strcat(nombreCompleto, miembros[pos].apellido);

  cout << "Nombre completo: " << nombreCompleto << endl;
}

void calcularLongitudCadenas(Miembro miembros[], int n) {
  int id;
  cout << "Ingrese ID: ";
  cin >> id;
  int pos = buscarPorID(miembros, n, id);
  if (pos == -1) {
    cout << "No encontrado.\n";
    return;
  }

  cout << "Longitud del nombre: " << strlen(miembros[pos].nombre) << endl;
  cout << "Longitud del plan: " << strlen(miembros[pos].plan) << endl;
}

void buscarPalabraEnObservaciones(Miembro miembros[], int n) {
  char palabra[50];
  cout << "Ingrese palabra a buscar en observaciones: ";
  cin.ignore();
  cin.getline(palabra, 50);

  for (int i = 0; i < n; i++) {
    if (strstr(miembros[i].observaciones, palabra))
      mostrarMiembro(miembros[i]);
  }
}

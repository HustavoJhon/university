/*
Ejercicio 12: Registro de Empleados y Departamento 

Crea un programa donde se cree un registro para almacenar el nombre del empleado, número de empleado, 
salario y fecha de ingreso de n empleados. Además, dentro de este registro debe haber un registro 
anidado para almacenar la información del departamento, que contenga:
    • Nombre del departamento
    • Piso
    • Número de extensión telefónica
El programa debe calcular el salario total de todos los empleados y mostrar los registros ingresados, 
junto con el salario total.
*/

#include <iostream>
using namespace std;

struct Departamento {
    string nombre;
    int piso;
    int extension;
};

struct Empleado {
    string nombre;
    int numero;
    float salario;
    string fechaIngreso;
    Departamento dep;
};

int main() {
    int n;
    cout << "Ingrese la cantidad de empleados: ";
    cin >> n;

    Empleado empleados[n];
    float salarioTotal = 0;

    for (int i = 0; i < n; i++) {
        cout << "\nEmpleado " << i + 1 << endl;
        cout << "Nombre: ";
        cin >> empleados[i].nombre;
        cout << "Numero de empleado: ";
        cin >> empleados[i].numero;
        cout << "Salario: ";
        cin >> empleados[i].salario;
        cout << "Fecha de ingreso: ";
        cin >> empleados[i].fechaIngreso;

        cout << "--- Datos del departamento ---" << endl;
        cout << "Nombre del departamento: ";
        cin >> empleados[i].dep.nombre;
        cout << "Piso: ";
        cin >> empleados[i].dep.piso;
        cout << "Numero de extension: ";
        cin >> empleados[i].dep.extension;

        salarioTotal += empleados[i].salario;
    }

    cout << "\n--- Empleados Registrados ---\n";
    for (int i = 0; i < n; i++) {
        cout << "Nombre: " << empleados[i].nombre
             << " | Numero: " << empleados[i].numero
             << " | Salario: " << empleados[i].salario
             << " | Fecha ingreso: " << empleados[i].fechaIngreso
             << " | Departamento: " << empleados[i].dep.nombre
             << " (Piso " << empleados[i].dep.piso 
             << ", Ext. " << empleados[i].dep.extension << ")"
             << endl;
    }

    cout << "\nSalario total de todos los empleados: " << salarioTotal << endl;

    return 0;
}

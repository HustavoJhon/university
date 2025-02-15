/*
Ejercicio 14: Registro de Cursos y Horarios

Crea un programa donde se cree un registro para almacenar el nombre del curso, código del curso, profesor 
y número de créditos de n cursos universitarios. Dentro de este registro, debe haber un registro anidado 
para almacenar el horario del curso, que contenga:
    • Día de la semana
    • Hora de inicio
    • Duración (en horas)
El programa debe calcular las horas de clase por semana de cada curso, considerando que cada crédito equivale 
a 2 horas de clase por semana. Luego, debe mostrar los registros ingresados, junto con las horas totales 
de clase para cada curso.
*/

#include <iostream>
using namespace std;

struct Horario {
    string dia;
    string horaInicio;
    int duracion;
};

struct Curso {
    string nombre;
    string codigo;
    string profesor;
    int creditos;
    Horario horario;
    int horasPorSemana;
};

int main() {
    int n;
    cout << "Ingrese la cantidad de cursos: ";
    cin >> n;

    Curso cursos[n];

    for (int i = 0; i < n; i++) {
        cout << "\nCurso " << i + 1 << endl;
        cout << "Nombre: ";
        cin >> cursos[i].nombre;
        cout << "Codigo: ";
        cin >> cursos[i].codigo;
        cout << "Profesor: ";
        cin >> cursos[i].profesor;
        cout << "Creditos: ";
        cin >> cursos[i].creditos;
        cout << "Dia de la semana: ";
        cin >> cursos[i].horario.dia;
        cout << "Hora de inicio: ";
        cin >> cursos[i].horario.horaInicio;
        cout << "Duracion (horas): ";
        cin >> cursos[i].horario.duracion;

        cursos[i].horasPorSemana = cursos[i].creditos * 2;
    }

    cout << "\n--- Cursos Registrados ---\n";
    for (int i = 0; i < n; i++) {
        cout << "Curso: " << cursos[i].nombre
             << " | Codigo: " << cursos[i].codigo
             << " | Profesor: " << cursos[i].profesor
             << " | Creditos: " << cursos[i].creditos
             << " | Horario: " << cursos[i].horario.dia << " " << cursos[i].horario.horaInicio
             << " (" << cursos[i].horario.duracion << "h)"
             << " | Horas/semana: " << cursos[i].horasPorSemana
             << endl;
    }

    return 0;
}

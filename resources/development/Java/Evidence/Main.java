package org.example;
import java.io.BufferedReader;
import java.io.InputStreamReader;

public class Main {
    public static void main(String[] args) {
        BufferedReader reader = new BufferedReader(new InputStreamReader(System.in));
        PersonaNatural nat = new PersonaNatural();
        PersonaJuridica jur = new PersonaJuridica();
        int op;

        do {
            do {
                System.out.println("------ MENÚ ------");
                System.out.println("1. Registrar Persona Natural");
                System.out.println("2. Registrar Persona Jurídica");
                System.out.println("3. Salir");
                System.out.print("Ingrese una opción: ");

                try {
                    op = Integer.parseInt(reader.readLine());
                } catch (Exception e) {
                    op = 0;
                    System.out.println("Error. Ingrese un número válido.");
                }
            } while (op < 1 || op > 3);

            switch (op) {
                case 1:
                    try {
                        System.out.print("Ingrese nombre: ");
                        String nombre = reader.readLine();
                        System.out.print("Ingrese DNI: ");
                        String dni = reader.readLine();
                        System.out.print("Ingrese teléfono: ");
                        String telefono = reader.readLine();

                        nat.registrarNat(nombre, dni, telefono);
                        nat.mostrarNat();
                    } catch (Exception e) {
                        System.out.println("Error en ingreso de datos.");
                    }
                    break;

                case 2:
                    try {
                        System.out.print("Ingrese nombre: ");
                        String nombre = reader.readLine();
                        System.out.print("Ingrese RUC: ");
                        String ruc = reader.readLine();
                        System.out.print("Ingrese representante: ");
                        String representante = reader.readLine();

                        jur.registrarJur(nombre, ruc, representante);
                        jur.mostrarJur();
                    } catch (Exception e) {
                        System.out.println("Error en ingreso de datos.");
                    }
                    break;

                case 3:
                    System.out.println("Saliendo...");
                    break;
            }

            System.out.println();

        } while (op != 3);
    }
}

package org.example;


// PersonaNatural.java
public class PersonaNatural extends Persona {
    private String nroDni;
    private String telefono;

    public void registrarNat(String nombre, String nroDni, String telefono) {
        registrar(nombre);
        this.nroDni = nroDni;
        this.telefono = telefono;
    }

    public void mostrarNat() {
        mostrar();
        System.out.println("Persona Natural");
        System.out.println("DNI: " + nroDni);
        System.out.println("Teléfono: " + telefono);
    }
}


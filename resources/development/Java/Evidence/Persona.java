package org.example;

// Persona.java
public class Persona {
    protected String nombre;

    public void registrar(String nombre) {
        this.nombre = nombre;
    }

    public void mostrar() {
        System.out.println("Nombre: " + nombre);
    }
}


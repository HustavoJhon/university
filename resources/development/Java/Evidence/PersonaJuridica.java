package org.example;

// PersonaJuridica.java
public class PersonaJuridica extends Persona {
    private String nroRuc;
    private String representante;

    public void registrarJur(String nombre, String nroRuc, String representante) {
        registrar(nombre);
        this.nroRuc = nroRuc;
        this.representante = representante;
    }

    public void mostrarJur() {
        mostrar();
        System.out.println("Persona Juridica");
        System.out.println("RUC: " + nroRuc);
        System.out.println("Representante: " + representante);
    }
}

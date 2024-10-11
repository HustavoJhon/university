print("\n========== INGRESO DE DATOS ==========")

cantidad_hombres = int(input("Ingrese cantidad de hombres:\t\t"))
cantidad_mujeres = int(input("Ingrese cantidad de mujeres:\t\t"))

total_alumnos = cantidad_hombres + cantidad_mujeres


porcentaje_hombres = round((cantidad_hombres * 100)/total_alumnos)

porcentaje_mujeres = round((cantidad_mujeres * 100)/total_alumnos)


print("\n========== REPORTE ==========")
print("el Porcentaje de Hombres es:\t\t", porcentaje_hombres)
print("el Porcentaje de MUjeres es:\t\t", porcentaje_mujeres)
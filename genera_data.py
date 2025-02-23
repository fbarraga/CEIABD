import random
from faker import Faker

fake = Faker()
num_users = 500
user_filename_quoted = "usuarios_quoted.csv"

# Generar archivo CSV con strings entre comillas
with open(user_filename_quoted, "w") as f:
    f.write("id,nombre,email,edad,ciudad\n")  # Cabecera del CSV
    for i in range(1, num_users + 1):
        nombre = f"\"{fake.name()}\""
        email = f"\"{fake.email()}\""
        edad = random.randint(18, 65)
        ciudad = f"\"{fake.city()}\""
        f.write(f"{i},{nombre},{email},{edad},{ciudad}\n")

print(f"Archivo generado: {user_filename_quoted}")
"""
M5074 - BigData i IA
Activitat: Optimització de Bases de Dades
Part 2A: Generació de dades fake amb Python
pip install faker pyodbc
"""

import pyodbc
import random
from datetime import datetime, timedelta
from faker import Faker
import time

# Configuració
fake = Faker(['es_ES', 'es_ES'])
Faker.seed(42)
random.seed(42)

connection_string = (
    'DRIVER={ODBC Driver 17 for SQL Server};'
    'SERVER=sqlserver.codeworks.local;'
    'DATABASE=VendesBigData;'
    'uid=alumne;'
    'PWD=Password123!'
)

""" opció seguretat millorada
from dotenv import load_dotenv
import os

load_dotenv()

connection_string = (
    'DRIVER={ODBC Driver 17 for SQL Server};'
    f'SERVER={os.getenv("SQL_SERVER")};'
    f'DATABASE={os.getenv("SQL_DATABASE")};'
    f'UID={os.getenv("SQL_USER")};'
    f'PWD={os.getenv("SQL_PASSWORD")};'
)
"""


# Paràmetres de generació
NUM_JERARQUIES_PRODUCTES = 50
NUM_JERARQUIES_CLIENTS = 20
NUM_CLIENTS = 100000            # 100K clients
NUM_PRODUCTES = 10000           # 10K productes
NUM_COMANDES = 1000000          # 1M comandes
BATCH_SIZE = 10000              # Inserir en lots per optimitzar

print("=" * 60)
print("GENERADOR DE DADES MASSIVES - VENDESBigData")
print("=" * 60)

def executar_batch(cursor, query, data_list, batch_size=BATCH_SIZE):
    """Executa insercions en lots per millorar el rendiment"""
    total = len(data_list)
    for i in range(0, total, batch_size):
        batch = data_list[i:i+batch_size]
        cursor.fast_executemany = True
        cursor.executemany(query, batch)
        cursor.commit()
        print(f"  Processats {min(i+batch_size, total)}/{total} registres")

def generar_jerarquies_productes(cursor):
    """Genera jerarquies de productes (Departament/Categoria/Subcategoria)"""
    print("\n1. Generant jerarquies de productes...")
    
    departaments = {
        'Electrònica': ['Ordinadors', 'Telèfons', 'Tauletes', 'Accessoris'],
        'Llar': ['Mobles', 'Decoració', 'Il·luminació', 'Tèxtil'],
        'Moda': ['Roba Home', 'Roba Dona', 'Calçat', 'Complements'],
        'Esports': ['Fitness', 'Ciclisme', 'Outdoor', 'Natació'],
        'Llibres': ['Novel·la', 'Tècnic', 'Infantil', 'Comics'],
    }
    
    subcategories = ['Premium', 'Estàndard', 'Econòmic', 'Oferta']
    
    data = []
    for dept, categories in departaments.items():
        for cat in categories:
            for subcat in subcategories:
                data.append((dept, cat, subcat, 1))
    
    query = """
        INSERT INTO JerarquiaProductes (Nivell1, Nivell2, Nivell3, Actiu)
        VALUES (?, ?, ?, ?)
    """
    cursor.executemany(query, data)
    cursor.commit()
    print(f"  ✓ {len(data)} jerarquies de productes creades")

def generar_jerarquies_clients(cursor):
    """Genera jerarquies de clients (Tipus/Segment/Sub-segment)"""
    print("\n2. Generant jerarquies de clients...")
    
    data = [
        ('Particular', 'Premium', 'VIP', 1),
        ('Particular', 'Premium', 'Gold', 1),
        ('Particular', 'Estàndard', 'Silver', 1),
        ('Particular', 'Estàndard', 'Regular', 1),
        ('Particular', 'Bàsic', 'Nou', 1),
        ('Empresa', 'Gran Empresa', 'Nacional', 1),
        ('Empresa', 'Gran Empresa', 'Internacional', 1),
        ('Empresa', 'PIME', 'Mitjana', 1),
        ('Empresa', 'PIME', 'Petita', 1),
        ('Empresa', 'Autònom', 'Professional', 1),
    ]
    
    query = """
        INSERT INTO JerarquiaClients (Nivell1, Nivell2, Nivell3, Actiu)
        VALUES (?, ?, ?, ?)
    """
    cursor.executemany(query, data)
    cursor.commit()
    print(f"  ✓ {len(data)} jerarquies de clients creades")

def generar_clients(cursor, num_clients):
    """Genera clients fake"""
    print(f"\n3. Generant {num_clients:,} clients...")
    start_time = time.time()
    
    provincies = ['Barcelona', 'Madrid', 'València', 'Sevilla', 'Saragossa', 
                  'Màlaga', 'Múrcia', 'Palma', 'Bilbao', 'Alacant']
    
    data = []
    for i in range(num_clients):
        codi = f"CLI-{i+1:08d}"
        nom = fake.company() if random.random() > 0.7 else fake.name()
        email = fake.email()
        telefon = fake.phone_number()
        direccio = fake.street_address()
        poblacio = fake.city()
        cp = fake.postcode()
        provincia = random.choice(provincies)
        jerarquia_id = random.randint(1, 10)
        
        data.append((codi, nom, email, telefon, direccio, poblacio, cp, provincia, 'Espanya', jerarquia_id, 1))
    
    query = """
        INSERT INTO Clients (CodiClient, NomClient, Email, Telefon, Direccio, 
                           Poblacio, CodiPostal, Provincia, Pais, JerarquiaClientID, Actiu)
        VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
    """
    executar_batch(cursor, query, data)
    
    elapsed = time.time() - start_time
    print(f"  ✓ Completat en {elapsed:.2f} segons ({num_clients/elapsed:.0f} reg/s)")

def generar_productes(cursor, num_productes):
    """Genera productes fake"""
    print(f"\n4. Generant {num_productes:,} productes...")
    start_time = time.time()
    
    prefixos = ['Pro', 'Super', 'Mega', 'Ultra', 'Max', 'Premium', 'Elite', 'Smart']
    sufixos = ['Plus', 'Pro', 'Advanced', 'Deluxe', 'Standard', 'Basic', 'Lite']
    
    data = []
    for i in range(num_productes):
        codi = f"PROD-{i+1:08d}"
        nom = f"{random.choice(prefixos)} {fake.word().capitalize()} {random.choice(sufixos)}"
        desc = fake.text(max_nb_chars=200)
        jerarquia_id = random.randint(1, 20)  # Assumim que hi ha 20 jerarquies
        preu = round(random.uniform(5, 2000), 2)
        cost = round(preu * random.uniform(0.4, 0.7), 2)
        stock = random.randint(0, 1000)
        
        data.append((codi, nom, desc, jerarquia_id, preu, cost, stock, 1))
    
    query = """
        INSERT INTO Productes (CodiProducte, NomProducte, Descripcio, JerarquiaProducteID,
                             PreuUnitari, Cost, StockActual, Actiu)
        VALUES (?, ?, ?, ?, ?, ?, ?, ?)
    """
    executar_batch(cursor, query, data)
    
    elapsed = time.time() - start_time
    print(f"  ✓ Completat en {elapsed:.2f} segons ({num_productes/elapsed:.0f} reg/s)")

def generar_comandes_i_linies(cursor, num_comandes):
    """Genera comandes i les seves línies"""
    print(f"\n5. Generant {num_comandes:,} comandes amb línies...")
    start_time = time.time()
    
    estats = ['Pendent', 'Processat', 'Enviat', 'Entregat', 'Cancel·lat']
    pesos_estats = [0.05, 0.10, 0.15, 0.65, 0.05]
    
    # Data inicial: 3 anys enrere
    data_inici = datetime.now() - timedelta(days=3*365)
    
    print("  Generant comandes...")
    comandes_data = []
    for i in range(num_comandes):
        num_comanda = f"COM-{i+1:010d}"
        client_id = random.randint(1, NUM_CLIENTS)
        dies_enrere = random.randint(0, 3*365)
        data_comanda = data_inici + timedelta(days=dies_enrere)
        
        estat = random.choices(estats, weights=pesos_estats)[0]
        data_enviament = data_comanda + timedelta(days=random.randint(1, 5)) if estat in ['Enviat', 'Entregat'] else None
        data_entrega = data_enviament + timedelta(days=random.randint(1, 3)) if estat == 'Entregat' else None
        
        import_total = 0  # Es calcularà amb les línies
        
        comandes_data.append((num_comanda, client_id, data_comanda, data_enviament, 
                            data_entrega, estat, import_total, 0, import_total))
    
    query = """
        INSERT INTO Comandes (NumeroComanda, ClientID, DataComanda, DataEnviament, 
                            DataEntrega, Estat, ImportTotal, Descompte, ImportNet)
        VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)
    """
    executar_batch(cursor, query, comandes_data)
    
    print("  Generant línies de comanda...")
    # Generar línies per cada comanda
    linies_data = []
    for comanda_id in range(1, num_comandes + 1):
        num_linies = random.randint(1, 8)
        
        for num_linia in range(1, num_linies + 1):
            producte_id = random.randint(1, NUM_PRODUCTES)
            quantitat = random.randint(1, 10)
            preu = round(random.uniform(10, 500), 2)
            descompte = random.choice([0, 0, 0, 5, 10, 15])
            import_linia = round(quantitat * preu * (1 - descompte/100), 2)
            
            linies_data.append((comanda_id, num_linia, producte_id, quantitat, 
                              preu, descompte, import_linia))
    
    query = """
        INSERT INTO LiniesComanda (ComandaID, NumeroLinia, ProducteID, Quantitat,
                                 PreuUnitari, Descompte, ImportLinia)
        VALUES (?, ?, ?, ?, ?, ?, ?)
    """
    executar_batch(cursor, query, linies_data)
    
    # Actualitzar imports de comandes
    print("  Actualitzant imports totals...")
    cursor.execute("""
        UPDATE c
        SET ImportTotal = totals.Total,
            ImportNet = totals.Total
        FROM Comandes c
        INNER JOIN (
            SELECT ComandaID, SUM(ImportLinia) as Total
            FROM LiniesComanda
            GROUP BY ComandaID
        ) totals ON c.ComandaID = totals.ComandaID
    """)
    cursor.commit()
    
    elapsed = time.time() - start_time
    print(f"  ✓ Completat en {elapsed:.2f} segons")
    print(f"    - {num_comandes:,} comandes creades")
    print(f"    - {len(linies_data):,} línies creades")

def main():
    try:
        conn = pyodbc.connect(connection_string)
        cursor = conn.cursor()
        
        print("\nConnexió establerta amb SQL Server")
        
        # Deshabilitar constrains temporalment per millorar rendiment
        cursor.execute("ALTER TABLE LiniesComanda NOCHECK CONSTRAINT ALL")
        cursor.execute("ALTER TABLE Comandes NOCHECK CONSTRAINT ALL")
        cursor.commit()
        
        # Generar dades
        generar_jerarquies_productes(cursor)
        generar_jerarquies_clients(cursor)
        generar_clients(cursor, NUM_CLIENTS)
        generar_productes(cursor, NUM_PRODUCTES)
        generar_comandes_i_linies(cursor, NUM_COMANDES)
        
        # Rehabilitar constrains
        print("\nRehabilitant constrains...")
        cursor.execute("ALTER TABLE LiniesComanda CHECK CONSTRAINT ALL")
        cursor.execute("ALTER TABLE Comandes CHECK CONSTRAINT ALL")
        cursor.commit()
        
        # Estadístiques finals
        print("\n" + "=" * 60)
        print("GENERACIÓ COMPLETADA!")
        print("=" * 60)
        
        cursor.execute("SELECT COUNT(*) FROM Clients")
        print(f"Clients: {cursor.fetchone()[0]:,}")
        
        cursor.execute("SELECT COUNT(*) FROM Productes")
        print(f"Productes: {cursor.fetchone()[0]:,}")
        
        cursor.execute("SELECT COUNT(*) FROM Comandes")
        print(f"Comandes: {cursor.fetchone()[0]:,}")
        
        cursor.execute("SELECT COUNT(*) FROM LiniesComanda")
        print(f"Línies comanda: {cursor.fetchone()[0]:,}")
        
        print("=" * 60)
        
        cursor.close()
        conn.close()
        
    except Exception as e:
        print(f"\n❌ Error: {e}")
        raise

if __name__ == "__main__":
    main()

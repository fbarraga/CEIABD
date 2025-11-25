import requests
from bs4 import BeautifulSoup
from selenium import webdriver
from selenium.webdriver.common.by import By
from selenium.webdriver.chrome.options import Options
import json
from collections import Counter
import re

class SelectorAnalyzer:
    def __init__(self):
        self.common_selectors = {
            'precio': [
                '.price', '.precio', '.cost', '.amount', '[data-price]',
                '.price-current', '.price-now', '.sale-price', '.final-price',
                '.product-price', '.item-price', '.unit-price'
            ],
            'titulo': [
                'h1', 'h2', 'h3', '.title', '.name', '.product-title', 
                '.product-name', '.item-title', '.heading', '[data-title]'
            ],
            'descripcion': [
                '.description', '.desc', '.product-description', '.details',
                '.summary', '.info', '.product-info', '.item-details'
            ],
            'imagen': [
                'img', '.image img', '.product-image img', '.item-image img',
                '.photo img', '.picture img', '[data-image] img'
            ],
            'enlace': [
                'a', '.link', '.product-link', '.item-link', '[href]'
            ],
            'boton': [
                'button', '.btn', '.button', '.add-to-cart', '.buy-now',
                '.purchase', '.order', '[type="submit"]'
            ]
        }
    
    def analizar_pagina(self, url: str, usar_selenium: bool = False):
        """Analiza una página y sugiere selectores útiles"""
        print(f"Analizando: {url}")
        
        if usar_selenium:
            soup = self._obtener_con_selenium(url)
        else:
            soup = self._obtener_con_requests(url)
        
        if not soup:
            return None
        
        analisis = {
            'url': url,
            'selectores_encontrados': {},
            'patrones_comunes': {},
            'estructura_productos': [],
            'selectores_sugeridos': {}
        }
        
        # Analizar cada tipo de elemento
        for tipo, selectores in self.common_selectors.items():
            analisis['selectores_encontrados'][tipo] = self._buscar_selectores(soup, selectores)
        
        # Detectar patrones de productos
        analisis['estructura_productos'] = self._detectar_productos(soup)
        
        # Generar selectores sugeridos
        analisis['selectores_sugeridos'] = self._generar_sugerencias(soup, analisis)
        
        return analisis
    
    def _obtener_con_requests(self, url: str):
        """Obtiene página con requests"""
        try:
            headers = {
                'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36'
            }
            response = requests.get(url, headers=headers, timeout=10)
            response.raise_for_status()
            return BeautifulSoup(response.content, 'html.parser')
        except Exception as e:
            print(f"Error con requests: {e}")
            return None
    
    def _obtener_con_selenium(self, url: str):
        """Obtiene página con Selenium"""
        try:
            options = Options()
            options.add_argument("--headless")
            options.add_argument("--no-sandbox")
            driver = webdriver.Chrome(options=options)
            
            driver.get(url)
            html = driver.page_source
            driver.quit()
            
            return BeautifulSoup(html, 'html.parser')
        except Exception as e:
            print(f"Error con Selenium: {e}")
            return None
    
    def _buscar_selectores(self, soup: BeautifulSoup, selectores: list):
        """Busca selectores en la página y cuenta coincidencias"""
        resultados = {}
        
        for selector in selectores:
            try:
                elementos = soup.select(selector)
                if elementos:
                    resultados[selector] = {
                        'count': len(elementos),
                        'ejemplos': [elem.get_text(strip=True)[:50] for elem in elementos[:3]],
                        'atributos': [dict(elem.attrs) for elem in elementos[:2]]
                    }
            except Exception as e:
                continue
        
        return resultados
    
    def _detectar_productos(self, soup: BeautifulSoup):
        """Detecta contenedores de productos comunes"""
        selectores_productos = [
            '.product', '.item', '.card', '.box',
            '[data-product]', '[data-item]', '.grid-item',
            '.product-item', '.product-card', '.listing-item'
        ]
        
        productos_detectados = []
        
        for selector in selectores_productos:
            elementos = soup.select(selector)
            if len(elementos) > 2:  # Debe haber múltiples elementos
                productos_detectados.append({
                    'selector': selector,
                    'cantidad': len(elementos),
                    'estructura_ejemplo': self._analizar_estructura(elementos[0]) if elementos else {}
                })
        
        return sorted(productos_detectados, key=lambda x: x['cantidad'], reverse=True)
    
    def _analizar_estructura(self, elemento):
        """Analiza la estructura interna de un elemento"""
        estructura = {
            'tag': elemento.name,
            'clases': elemento.get('class', []),
            'id': elemento.get('id', ''),
            'hijos_importantes': []
        }
        
        # Buscar elementos hijos importantes
        for hijo in elemento.find_all(['h1', 'h2', 'h3', 'h4', 'span', 'div', 'p', 'img', 'a']):
            if hijo.get_text(strip=True) or hijo.name == 'img':
                estructura['hijos_importantes'].append({
                    'tag': hijo.name,
                    'clases': hijo.get('class', []),
                    'texto_ejemplo': hijo.get_text(strip=True)[:30],
                    'selector_sugerido': self._generar_selector_hijo(hijo)
                })
        
        return estructura
    
    def _generar_selector_hijo(self, elemento):
        """Genera un selector CSS para un elemento hijo"""
        if elemento.get('class'):
            return f".{' .'.join(elemento['class'])}"
        elif elemento.get('id'):
            return f"#{elemento['id']}"
        else:
            return elemento.name
    
    def _generar_sugerencias(self, soup: BeautifulSoup, analisis: dict):
        """Genera sugerencias de selectores basadas en el análisis"""
        sugerencias = {}
        
        # Sugerir selectores para precios (buscar patrones de números con símbolos de moneda)
        elementos_con_precio = soup.find_all(text=re.compile(r'[€$£¥]\s*\d+|^\d+[,.]?\d*\s*[€$£¥]'))
        if elementos_con_precio:
            selectores_precio = []
            for elem in elementos_con_precio[:5]:
                parent = elem.parent
                if parent:
                    selector = self._construir_selector(parent)
                    selectores_precio.append(selector)
            sugerencias['precio_detectado'] = list(set(selectores_precio))
        
        # Sugerir selectores para títulos (elementos con texto largo que parecen nombres)
        titulos_potenciales = soup.find_all(['h1', 'h2', 'h3', 'h4', 'span', 'div'], 
                                          text=re.compile(r'^[A-ZÁÉÍÓÚÑ][a-záéíóúñ\s]{10,}'))
        if titulos_potenciales:
            sugerencias['titulos_detectados'] = [
                self._construir_selector(elem) for elem in titulos_potenciales[:5]
            ]
        
        return sugerencias
    
    def _construir_selector(self, elemento):
        """Construye un selector CSS para un elemento"""
        selector_parts = []
        
        if elemento.get('id'):
            return f"#{elemento['id']}"
        
        if elemento.get('class'):
            classes = elemento['class']
            # Usar las clases más específicas (evitar clases genéricas)
            clases_utiles = [c for c in classes if len(c) > 2 and c not in ['item', 'box', 'row']]
            if clases_utiles:
                return f".{' .'.join(clases_utiles[:2])}"
        
        return elemento.name
    
    def generar_codigo_scraper(self, analisis: dict, elementos_objetivo: list):
        """Genera código de scraper basado en el análisis"""
        codigo = f"""
# Scraper generado automáticamente para: {analisis['url']}

import requests
from bs4 import BeautifulSoup

def scrape_productos(url):
    headers = {{
        'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36'
    }}
    
    response = requests.get(url, headers=headers)
    soup = BeautifulSoup(response.content, 'html.parser')
    
    productos = []
    
    # Contenedores de productos detectados:
"""
        
        if analisis['estructura_productos']:
            mejor_selector = analisis['estructura_productos'][0]['selector']
            codigo += f"""    
    # Usar el selector más prometedor: {mejor_selector}
    elementos_productos = soup.select('{mejor_selector}')
    
    for elemento in elementos_productos:
        producto = {{}}
        
"""
            
            # Agregar extractores para cada tipo de elemento
            for elemento in elementos_objetivo:
                if elemento in analisis['selectores_encontrados']:
                    selectores = analisis['selectores_encontrados'][elemento]
                    if selectores:
                        mejor_selector_elem = list(selectores.keys())[0]
                        codigo += f"""        # Extraer {elemento}
        {elemento}_elem = elemento.select_one('{mejor_selector_elem}')
        producto['{elemento}'] = {elemento}_elem.get_text(strip=True) if {elemento}_elem else ""
        
"""
        
        codigo += """        productos.append(producto)
    
    return productos

# Uso:
# productos = scrape_productos('URL_AQUI')
# print(productos)
"""
        
        return codigo
    
    def guardar_analisis(self, analisis: dict, archivo: str = "analisis_selectores.json"):
        """Guarda el análisis en un archivo JSON"""
        with open(archivo, 'w', encoding='utf-8') as f:
            json.dump(analisis, f, ensure_ascii=False, indent=2)
        print(f"Análisis guardado en {archivo}")

# Herramienta interactiva para análisis
def analizar_sitio_interactivo():
    analyzer = SelectorAnalyzer()
    
    print("=== ANALIZADOR DE SELECTORES CSS ===")
    url = input("Introduce la URL a analizar: ")
    usar_selenium = input("¿Usar Selenium? (y/n): ").lower() == 'y'
    
    print("\nAnalizando página...")
    analisis = analyzer.analizar_pagina(url, usar_selenium)
    
    if analisis:
        print("\n=== RESULTADOS DEL ANÁLISIS ===")
        
        # Mostrar estructura de productos detectada
        if analisis['estructura_productos']:
            print("\n🎯 CONTENEDORES DE PRODUCTOS DETECTADOS:")
            for i, producto in enumerate(analisis['estructura_productos'][:3]):
                print(f"{i+1}. {producto['selector']} ({producto['cantidad']} elementos)")
        
        # Mostrar selectores encontrados
        print("\n📋 SELECTORES ÚTILES ENCONTRADOS:")
        for tipo, selectores in analisis['selectores_encontrados'].items():
            if selectores:
                print(f"\n{tipo.upper()}:")
                for selector, info in list(selectores.items())[:2]:
                    print(f"  • {selector} ({info['count']} elementos)")
                    if info['ejemplos']:
                        print(f"    Ejemplo: {info['ejemplos'][0]}")
        
        # Generar código
        elementos_deseados = input("\n¿Qué elementos quieres extraer? (precio,titulo,descripcion): ").split(',')
        elementos_deseados = [e.strip() for e in elementos_deseados]
        
        codigo = analyzer.generar_codigo_scraper(analisis, elementos_deseados)
        
        print("\n🚀 CÓDIGO GENERADO:")
        print(codigo)
        
        # Guardar análisis
        analyzer.guardar_analisis(analisis)
    
    else:
        print("❌ No se pudo analizar la página")

if __name__ == "__main__":
    # Análisis automático de ejemplo
    analyzer = SelectorAnalyzer()
    
    # Ejemplo de uso:
    # analisis = analyzer.analizar_pagina("https://ejemplo-tienda.com")
    # codigo = analyzer.generar_codigo_scraper(analisis, ['precio', 'titulo'])
    # print(codigo)
    
    # Para uso interactivo:
    analizar_sitio_interactivo()
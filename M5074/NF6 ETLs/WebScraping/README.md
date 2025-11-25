# Webscraping Python

- Curs: CE IA i BigData
- Mòdul: M04 Sistemes de BigData
- Autor: Francesc Barragán
- Rev: 1.0 11.11.2025
- Testejat amb Python 3.12
- Webscraping d'una pàgina simple

## 1 Introducció

El web scraping és un procés d'extracció automatitzada de dades de llocs web. Consisteix a llegir textos de pàgines web per obtenir informació i emmagatzemar-la, de forma comparable al procés automàtic de copiar i enganxar. La informació extreta es recopila i després s'exporta a un format més útil per a l'usuari, com un full de càlcul, fitxers JSON o una API.

## 2 Coneixements bàsics

El DOM (Document Object Model) és una representació estructurada d'un document HTML o XML. Permet als llenguatges de programació com JavaScript o Python  accedir i manipular el contingut, l'estructura i l'estil d'una pàgina web de manera dinàmica.

### 2.1 Característiques principals del DOM

- **Estructura en arbre**: El DOM representa el document com un arbre de nodes, on cada node pot ser un element, un atribut o un text.
- **Interactivitat**: Permet modificar el contingut i l'estructura del document en temps real, afegint, eliminant o canviant elements.
- **Accés programàtic**: Els llenguatges de programació poden utilitzar el DOM per accedir i manipular els elements de la pàgina.

Exemple:
Imagina una pàgina HTML senzilla:

```html
<!DOCTYPE html>
<html>
<head>
  <title>Exemple de DOM</title>
</head>
<body>
  <h1>Hola, món!</h1>
  <p>Això és un paràgraf.</p>
</body>
</html>
```

En el DOM, aquesta pàgina es representaria com un arbre amb el document com a node arrel, i els elements html, head, body, title, h1 i p com a nodes fills.

### 2.2 CSS_SELECTORS i XPATH

Els CSS Selectors i XPath són dues maneres diferents d'accedir i seleccionar elements dins d'un document HTML o XML.

#### 2.2.1 CSS Selectors

Els CSS Selectors s'utilitzen principalment en CSS per aplicar estils als elements HTML, però també es poden utilitzar en JavaScript per seleccionar elements del DOM. Els selectors CSS són fàcils de llegir i escriure.

Exemple:

```html
<p class="intro">Hola, món!</p>
```

Per seleccionar aquest paràgraf amb CSS:

```css
.intro {
  color: blue;
}
```

I amb JavaScript:

```javascript
document.querySelector('.intro');
```

#### 2.2.2 XPath

XPath és un llenguatge de consulta per seleccionar nodes d'un document XML. És més potent i flexible que els selectors CSS, però també més complex.

Exemple:

```html
<p class="intro">Hola, món!</p>
```

Per seleccionar aquest paràgraf amb XPath:

```xpath
//p[@class='intro']
```

I amb JavaScript:

```javascript
document.evaluate("//p[@class='intro']", document, null, XPathResult.FIRST_ORDERED_NODE_TYPE, null).singleNodeValue;
```

#### 2.2.3 Diferències clau entre CSS_Selectors i XPATH

- **Simplicitat**: Els selectors CSS són més senzills i llegibles.
- **Potència**: XPath ofereix més funcionalitats i pot seleccionar elements basant-se en criteris més complexos.
- **Ús**: Els selectors CSS són més comuns en el desenvolupament web, mentre que XPath s'utilitza més en processament XML i scraping web avançat.

### 2.3 CSS_SELECTORS i XPATH amb Python

CSS Selectors amb BeautifulSoup:

```python
from bs4 import BeautifulSoup
import requests

# Obtenir el contingut HTML
url = 'http://exemple.com'
response = requests.get(url)
html = response.content

# Analitzar el HTML
soup = BeautifulSoup(html, 'html.parser')

# Utilitzar CSS Selectors per seleccionar elements
title = soup.select_one('h1').text
paragraphs = [p.text for p in soup.select('p.intro')]

print(f"Títol: {title}")
print("Paràgrafs:")
for p in paragraphs:
    print(p)
```

XPath amb lxml:
```python
from lxml import html
import requests

# Obtenir el contingut HTML
url = 'http://exemple.com'
response = requests.get(url)
html_content = response.content

# Analitzar el HTML
tree = html.fromstring(html_content)

# Utilitzar XPath per seleccionar elements
title = tree.xpath('//h1/text()')[0]
paragraphs = tree.xpath('//p[@class="intro"]/text()')

print(f"Títol: {title}")
print("Paràgrafs:")
for p in paragraphs:
    print(p)
```

- [*BeautifulSoup*](https://beautiful-soup-4.readthedocs.io/en/latest/): Utilitza el mètode select_one per seleccionar un sol element i select per seleccionar múltiples elements utilitzant CSS Selectors.
- [*lxml*](https://lxml.de/): Utilitza el mètode xpath per seleccionar elements basant-se en expressions XPath.

### 2.4 SELECTORLIB

La llibreria [`selectorlib`](https://selectorlib.com/) a Python s'utilitza per extreure dades de pàgines HTML. Aquesta llibreria llegeix un fitxer YAML que conté selectors CSS o Xpath i, a partir d'aquests, extreu les dades en un diccionari.

Com funciona:

1. Definició de selectors: Es defineixen els elements HTML que es volen extreure utilitzant selectors CSS o Xpath en un fitxer YAML.
2. Extracció de dades: Amb la llibreria selectorlib, es llegeix aquest fitxer YAML i s'aplica a una pàgina HTML per extreure les dades definides.

Exemple:


```python
from selectorlib import Extractor

yaml_string = """
title:
  css: "h1"
  type: Text
link:
  css: "h2 a"
  type: Link
"""

extractor = Extractor.from_yaml_string(yaml_string)
html = """
<h1>Títol</h1>
<h2>Ús <a class="headerlink" href="http://exemple.com">¶</a></h2>
"""
dades = extractor.extract(html)
print(dades)
```

### 2.5 Descarregar el contingut d'una pàgina web amb la llibreria REQUESTS

Per descarregar el contingut d'una pàgina web amb la llibreria requests de Python, pots seguir aquests passos:

Instal·lar la llibreria requests:
```python
pip install requests
```

Utilitzar requests per descarregar el contingut:
```python 
import requests

# URL de la pàgina web que vols descarregar
url = 'https://www.example.com'

# Fer una petició GET a la pàgina web
response = requests.get(url)

# Comprovar si la petició ha estat exitosa
if response.status_code == 200:
    # Obtenir el contingut de la pàgina
    content = response.text
    print(content)
else:
    print(f'Error: {response.status_code}')
```

Aquest codi fa una petició GET a la URL especificada i, si la petició és exitosa (codi de resposta 200), imprimeix el contingut de la pàgina web.

## 3 Eines per la creació dels YAML files de manera fàcil i ràpida

Utilitzar el plugin de Chrome de selectorlib és una manera molt pràctica de generar fitxers YAML per extreure dades de pàgines web. Aquest plugin facilita la selecció d'elements directament des del navegador i genera automàticament el YAML necessari. Aquí tens una guia pas a pas per utilitzar-lo:

Passos per utilitzar el plugin de Chrome de selectorlib:

1. Instal·la el plugin:
Ves a la Chrome Web Store i cerca "selectorlib".
2. Instal·la el plugin al teu navegador.
Obre la pàgina web:
Navega fins a la pàgina web de la qual vols extreure dades.
3. Activa el plugin:
Fes clic a la icona del plugin de selectorlib a la barra d'eines del navegador per activar-lo o selecciona'l des de les eines de desenvolupador.
4. Selecciona els elements:
Utilitza el cursor per seleccionar els elements de la pàgina que vols extreure. Quan seleccionis un element, el plugin et permetrà definir el tipus de dada (Text, Link, etc.) i afegir-lo a la configuració YAML.
5. Genera el YAML:
Un cop hagis seleccionat tots els elements desitjats, el plugin generarà automàticament el fitxer YAML amb els selectores CSS o XPath corresponents.
6. Desa el YAML:
Desa el fitxer YAML generat al teu ordinador. Aquest fitxer es pot utilitzar directament amb la llibreria selectorlib en Python.


Exemple pràctic:
Suposem que has seleccionat un títol i alguns paràgrafs d'una pàgina web. El plugin generarà un fitxer YAML semblant a aquest:

```yaml
title:
  css: "h1"
  type: Text
paragraphs:
  css: "p.intro"
  type: Text
  multiple: true
```

Utilitzar el YAML amb selectorlib en Python:

```python
from selectorlib import Extractor

# Carregar el YAML generat pel plugin
yaml_string = """
title:
  css: "h1"
  type: Text
paragraphs:
  css: "p.intro"
  type: Text
  multiple: true
"""

# Crear l'extractor
extractor = Extractor.from_yaml_string(yaml_string)

# HTML de la pàgina
html = """
<h1>Títol de la pàgina</h1>
<p class="intro">Aquest és un paràgraf introductori.</p>
<p class="intro">Aquest és un altre paràgraf introductori.</p>
"""

# Extreure les dades
dades = extractor.extract(html)
print(dades)
```


## 4 Llibreria Selenium de Python. Què és Selenium?

Selenium és una llibreria de codi obert que permet automatitzar navegadors web. És molt utilitzada per a proves automàtiques de llocs web, scraping de dades i altres tasques que requereixen la interacció amb un navegador.

### 4.1 Instal·lació

Per instal·lar Selenium, pots utilitzar pip:

```bash
pip install selenium
```

### 4.2 Utilitzant el driver de Chrome
Per utilitzar Selenium amb el navegador Chrome, necessitaràs el ChromeDriver. Pots descarregar-lo des del [lloc oficial](https://googlechromelabs.github.io/chrome-for-testing/) i assegurar-te que està en el teu PATH.

Exemple de codi
A continuació, es mostra un exemple de com utilitzar Selenium amb el driver de Chrome:

```python
from selenium import webdriver
from selenium.webdriver.common.by import By
from selenium.webdriver.common.keys import Keys

# Inicialitzar el driver de Chrome
driver = webdriver.Chrome()

# Obrir una pàgina web
driver.get("https://www.example.com")

# Trobar un element per ID i enviar text
element = driver.find_element(By.ID, "search")
element.send_keys("Selenium" + Keys.RETURN)

# Tancar el navegador
driver.quit()
```
### 4.3 Principals Mètodes de la Llibreria Selenium amb Python

#### 4.3.1. Inicialització del WebDriver
Per començar, necessites inicialitzar el WebDriver per al navegador que vulguis utilitzar (per exemple, Chrome):

```python
from selenium import webdriver

driver = webdriver.Chrome()
```

#### 4.3.2. Obrir una pàgina web
Per navegar a una URL específica:
```python
driver.get("https://www.example.com")
```

#### 4.3.3. Trobar elements

Selenium proporciona diversos mètodes per trobar elements a la pàgina:

- find_element(By.ID, "id"): Troba un element pel seu ID.
- find_element(By.NAME, "name"): Troba un element pel seu nom.
- find_element(By.XPATH, "xpath"): Troba un element pel seu XPath.
- find_element(By.CSS_SELECTOR, "css_selector"): Troba un element pel seu selector CSS.

Exemple:

```python
from selenium.webdriver.common.by import By

element = driver.find_element(By.ID, "search")
```

#### 4.3.4. Interactuar amb elements
Un cop has trobat un element, pots interactuar amb ell:

- send_keys("text"): Envia text a un camp d'entrada.
- click(): Fa clic en un botó o enllaç.
- clear(): Neteja el contingut d'un camp d'entrada.

Exemple:
```python
element.send_keys("Selenium")
element.submit()  # Envia el formulari
```

#### 4.3.5. Obtenir informació dels elements
Pots obtenir informació dels elements, com ara el text o els atributs:

- text: Obté el text visible d'un element.
- get_attribute("attribute_name"): Obté el valor d'un atribut.

Exemple:

```python
text = element.text
href = element.get_attribute("href")
```

#### 4.3.6. Esperes
Per assegurar-te que els elements estan disponibles abans d'interactuar amb ells, pots utilitzar esperes explícites:

```python
from selenium.webdriver.common.by import By
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC

wait = WebDriverWait(driver, 10)
element = wait.until(EC.presence_of_element_located((By.ID, "search")))
```

#### 4.3.7. Tancar el navegador
Quan hagis acabat, és important tancar el navegador:

```python
driver.quit()
```

## Webgrafia

- https://realpython.com/modern-web-automation-with-python-and-selenium/
  
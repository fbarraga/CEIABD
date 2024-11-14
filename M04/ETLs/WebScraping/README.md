# Webscraping Python

- CE IA i BigData
- M04 Sistemes de BigData
- Francesc Barragán Nov 2024
- Rev: 1.0
- Testejat amb Python 3.12

## 1 Introducció

El web scraping és un procés d'extracció automatitzada de dades de llocs web. Consisteix a llegir textos de pàgines web per obtenir informació i emmagatzemar-la, de forma comparable al procés automàtic de copiar i enganxar. La informació extreta es recopila i després s'exporta a un format més útil per a l'usuari, com un full de càlcul, fitxers JSON o una API.

## 2 Coneixements bàsics

El DOM (Document Object Model) és una representació estructurada d'un document HTML o XML. Permet als llenguatges de programació com JavaScript o Python  accedir i manipular el contingut, l'estructura i l'estil d'una pàgina web de manera dinàmica.

### 2.1 Característiques principals del DOM

Estructura en arbre: El DOM representa el document com un arbre de nodes, on cada node pot ser un element, un atribut o un text.
Interactivitat: Permet modificar el contingut i l'estructura del document en temps real, afegint, eliminant o canviant elements.
Accés programàtic: Els llenguatges de programació poden utilitzar el DOM per accedir i manipular els elements de la pàgina.

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

La llibreria [`selectorlib`](https://selectorlib.com/) a Python s'utilitza per extreure dades de pàgines HTML. Aquesta llibreria llegeix un fitxer YAML que conté selectores CSS o Xpath i, a partir d'aquests, extreu les dades en un diccionari.

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

### 2.5 Eines per la creació dels YAML files de manera fàcil i ràpida

Utilitzar el plugin de Chrome de selectorlib és una manera molt pràctica de generar fitxers YAML per extreure dades de pàgines web. Aquest plugin facilita la selecció d'elements directament des del navegador i genera automàticament el YAML necessari. Aquí tens una guia pas a pas per utilitzar-lo:

Passos per utilitzar el plugin de Chrome de selectorlib:

1. Instal·la el plugin:
Ves a la Chrome Web Store i cerca "selectorlib".
2. Instal·la el plugin al teu navegador.
Obre la pàgina web:
Navega fins a la pàgina web de la qual vols extreure dades.
3. Activa el plugin:
Fes clic a la icona del plugin de selectorlib a la barra d'eines del navegador per activar-lo.
4. Selecciona els elements:
Utilitza el cursor per seleccionar els elements de la pàgina que vols extreure. Quan seleccionis un element, el plugin et permetrà definir el tipus de dada (Text, Link, etc.) i afegir-lo a la configuració YAML.
5. Genera el YAML:
Un cop hagis seleccionat tots els elements desitjats, el plugin generarà automàticament el fitxer YAML amb els selectores CSS o XPath corresponents.
6. Desa el YAML:
Desa el fitxer YAML generat al teu ordinador. Aquest fitxer es pot utilitzar directament amb la llibreria selectorlib en Python.
7. Exemple pràctic:
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


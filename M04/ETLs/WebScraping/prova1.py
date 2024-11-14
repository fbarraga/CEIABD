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
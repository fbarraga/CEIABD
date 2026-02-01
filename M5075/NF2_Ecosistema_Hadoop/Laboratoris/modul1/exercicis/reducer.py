#!/usr/bin/env python3
"""reducer.py"""
import sys

word = None
current_word = None
current_count = 0

# input comes from STDIN (standard input)
for line in sys.stdin:
        line = line.strip()
        word, count = line.split('\t', 1)

        try:
          count = int(count)
        except ValueError:
          continue

        # Para que funciona la entrada debe estar ordenada (sort)
        # en hadoop funciona directamente porque ya hace un sort
        if current_word == word:
          current_count += count
        else:
          if current_word: # Primera iteración es None
            print ('%s\t%s' % (current_word, current_count))
          current_word = word
          current_count = 1

if current_word == word:
  print ('%s\t%s' % (current_word, current_count))
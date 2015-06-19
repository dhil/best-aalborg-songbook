# BEST Aalborg Songbook
This songbook was originally created for the [BEST Aalborg](http://best.aau.dk) Summer Course 2013. It was used as a camp fire songbook, and as a codex for the [cantus](https://en.wikipedia.org/wiki/Cantus) we held during the summer course.

## Compilation
This section explains how to compile the songbook.

### Prerequistes
The songbook is written in LaTeX using the [Songs](https://songs.sourceforge.net)-package. Thus in order to compile the songbook you must have a working LaTeX distribution installed along with the Songs package. The Songs package is freely available at https://songs.sourceforge.net.

### Compiling the songbook
A makefile is distributed along with the source. Open a terminal in the ``src/``-directory and type:
```
src/ $ make && make index && make
```
The first ``make`` produces a songbook in PDF-format without an index of songs. The ``make index`` generates the index, whilst the second ``make`` includes the index of songs.

### Adapting the songbook to your needs
You can change the title, author, layout and more in the "master" file ``src/Songbook.tex``.
By default the ``savetrees``-package is enabled. Disabling this package slightly alters the layout.

### Adding and removing songs
By default all songs are found in ``src/content/``-directory. Simply create a new ``tex``-file in that directory (or any subdirectory). To include the new song in the songbook edit the ``src/content/index.tex`` to input the song. The index file can be generated automatically by the BASH script ``src/link-doc.sh``, e.g.:
```
src/ $ sh link-doc.sh Songbook
Successfully linked 71 files.
```
To remove songs either include the text ``%[LINK-DOC] ignore`` in the header of the song files or simply delete them. However, remember to regenerate the index-file afterwards.

## Acknowledgements
The songbook is created by [BEST Aalborg](http://best.aau.dk) (summer course team 2013) with aid by [BEST Copenhagen](http://best.dtu.dk) and [BEST Gothenburg](http://http://best.chs.chalmers.se/). 
The songbook based on the songbook 2012 by [BEST Vienna](http://www.bestvienna.at).
Thanks to the main contributors:
  * Daniel Hillerström, Daniel Rune Jensen, Monika Michael, and Helle Toft from [BEST Aalborg](http://best.aau.dk).
  * Christoffer Brøndum, and Marie Rasmussen from [BEST Copenhagen](http://best.dtu.dk).
  * Kristian Ott Milbo from [BEST Gothenburg](http://http://best.chs.chalmers.se/).
  * Rok Kosmina from [BEST Ljubljana](http://www.bestljubljana.si/en/).

## License
The source code for the BEST Aalborg Songbook is published under Attribution-NonCommercial-ShareAlike 4.0 International license, see [LICENSE.md](LICENSE.md) for more details.

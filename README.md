Labelled lists Extension For Quarto
===================================

[![GitHub build status][CI badge]][CI workflow]

[CI badge]: https://img.shields.io/github/actions/workflow/status/dialoa/labelled-lists/ci.yaml?branch=main
[CI workflow]: https://github.com/dialoa/labelled-lists/actions/workflows/ci.yaml

Quarto/Pandoc extension to create labelled lists.

Copyright 2021-2024 [Philosophie.ch][Philoch] under MIT License, see
LICENSE file for details.

Maintained by [Julien Dutant][JDutant].

Overview
--------

* Customize the bullet or label of unordered lists in [Quarto] and
  [Pandoc]. Use symbols, text, math; apply styles.
* Crossreference specific list items using identifiers.
  Crossreferences are automatically filled in with the item's label.
* Good citizen. To maximize compatibility with other filters and 
  output formats, labelled lists remain unordered lists in the 
  document's Pandoc types tree.  
* Graceful breakdown. The filter changes outputs in HTML and
  LaTeX/PDF. In other formats, custom labelleds are displayed after
  each item's bullet point.

Example output
--------------

See [example output][LListsExample].

Installation and usage
----------------------

See the [manual][LListsManual].

Issues and contributing
------------------------------------------------------------------

Issues and PRs welcome.

Acknowledgements
------------------------------------------------------------------

Development funded by [Philosophie.ch][Philoch].

[LListsManual]: https://dialoa.github.io/labelled-lists/
[LListsExample]: https://dialoa.github.io/labelled-lists/output.html
[Dialectica]: https://dialectica.philosophie.ch
[Philoch]: https://philosophie.ch
[JDutant]: https://github.com/jdutant
[Pandoc]: https://www.pandoc.org
[PandocMan]: https://www.pandoc.org/MANUAL.html
[Pandoc-crossref]: https://github.com/lierdakil/pandoc-crossref
[Quarto]: https://quarto.org/


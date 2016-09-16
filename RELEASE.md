rough instructions for releasing and publishing packages to the site

* build the site locally if you haven't yet:
  ```
  cd site && make && make publish
  ```
* make the code ready
* update VERSION in lib/Analizo.pm, commit
* build package
* copy package files (.deb, .dsc, .changes and .tar.gz) into site/publish/download
* cd site/publish/download && ./update-repository
* cd site/publish && git add . && git commit -m 'update repository'
* cd site && make upload

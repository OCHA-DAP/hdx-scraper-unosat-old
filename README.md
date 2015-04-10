## Scraper for UNOSAT Data
Scraper designed to extract data from [UNOSAT's website](http://www.unitar.org/unosat/maps). It contains a few routines for identifying datasets of interest and excluding possible duplicates. It generates a CKAN compliant metadata JSON with all the resources -- and gallery items -- that have to be created in batch on HDX.

## Logic
The scraper is dissasociated from the scripts that register datasets (and resources and gallery items) on HDX. This was intentional design as I was trying to make the latter functions useful in other contexts.

## Scraper
In order to scrape data from UNOSAT's website, run the `run.sh` shell script. On Unix systems, do:

```shell
$ bash run.sh
```

Or run direactly using `R`:

```shell
$ Rscript code/scraper.R
```

That should scrape datasets from UNOSAT's website and create three files: `datasets.json`, `gallery.json`, and `resources.json`. Each of those contains relevant information about datasets, gallery items, and resources respectivelly. Those are passed to the `create-datasets.py` script for registering datasets on HDX.


## Registering
At the beginning of the `create-datasets.py` script you will see a `Configuration` area. Use those variables to configure your CKAN instance (i.e. test or real) and to specify where are the `datasets.json`, `gallery.json`, and `resources.json` files. Then:

```shell
$ python create-datasets.py
```

You should be able to follow the progress from the terminal.

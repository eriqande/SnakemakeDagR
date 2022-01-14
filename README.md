SnakemakeDagR
================
Eric C. Anderson

This is an R package in development. My main goal here is to be able to
render DAG output from Snakemake that is somewhat shaped like the
rulegraph, but also contains some more information than it.

My main beef with the straight-up DAG is that if you have a lot of
instances of each job, it is total nightmare to visualize. The rulegraph
on the other hand, doesn’t give you any information about how many
instances have successfully run and how many have not.

## Example DAGs

As an example I am using DAGs from a bioinformatics project I am
involved in at the moment, crunching through WGS data from Yukon River
Chinook salmon. There are 384 samples, but the fastqs for 9 of them were
corrupt. So, there are a few jobs left to do when we get uncorrupted
versions of those (if we ever do).

This is the DAG for all the jobs up through trimming, mapping,
dup-marking, and QC-ing.

The first is simply the DAG, obtained with:

``` sh
snakemake -np --dag results/qc/multiqc.html > ~/example_dag.dot
```

The second is the rulegraph, obtained with:

``` sh
snakemake -np --rulegraph results/qc/multiqc.html > ~/example_rulegraph.dot
```

The third is the filegraph, obtained with:

``` sh
snakemake -np --filegraph  results/qc/multiqc.html > ~/example_filegraph.dot
```

These are available with

``` r
system.file("extdata/example_dag.dot", package = "SnakemakeDagR")
system.file("extdata/example_rulegraph.dot", package = "SnakemakeDagR")
system.file("extdata/example_filegraph.dot", package = "SnakemakeDagR")
```

## Functions

The main function is `condense_dag()` which turns the dag output into
something that looks like the rulegraph, but has dashed and solid rules
to indicate whether they have been completed or not, and also includes
the number of instances of each rule that are completed (for dashed
nodes) and the number of instances that remain to be run (for solid
nodes). The edges are also labelled with the number of instances that
have been done or which remain to be done.

Here is an example

``` r
library(SnakemakeDagR)
condense_dag(
  dagfile = system.file("extdata/example_dag.dot", package = "SnakemakeDagR")
)
```

Running dot on the resulting output file gives this sort of picture:
<img src="/Users/eriq/Library/R/4.1/library/SnakemakeDagR/extdata/images/condensed.svg" width="100%" style="display: block; margin: auto;" />

Cool!

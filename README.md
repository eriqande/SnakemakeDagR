SnakemakeDagR
================
Eric C. Anderson

This is an R package in development. My main goal here is to be able to
render DAG output from Snakemake that is somewhat shaped like the
rulegraph, but also contains some more information than it.

My main beef with the straight-up DAG is that if you have a lot of
instances of each job, it is total nightmare to visualize. The rulegraph
on the other hand, doesn’t give you any information about how many
instances have successfully run and how many have not, now does it
provide any information about the wildcards that are in play within any
string of rules.

## Example DAGs

As an example I am using DAGs from a bioinformatics project I am
involved in at the moment, crunching through WGS data from Yukon River
Chinook salmon. There are 384 samples, but the fastqs for 9 of them were
corrupt. So, there are a few jobs left to do when we get uncorrupted
versions of those (if we ever do).

For this project the DAG is obtained with:

``` sh
snakemake -np --dag results/qc/multiqc.html > ~/example_dag.dot
```

The file that Snakemake produces from that `example_dag.dot` is
available within this package with:

``` r
system.file("extdata/example_dag.dot", package = "SnakemakeDagR")
```

Of course, if you try to plot that with dot, it is, as you might expect
with 384 samples, a complete nightmare! There are thousands of nodes and
bazillions of edges and everything gets flattened out so it is hardly
visible.

Enter the package function `condense_dag()`, the main (and currently
only) function in this package.

`condense_dag()` turns the dag output into something that looks like the
rulegraph, but has dashed and solid rules to indicate whether different
rules have been completed or not. Each node (dotted or dashed) also
includes the number of instances of each rule that are completed (for
dashed nodes) and the number of instances that remain to be run (for
solid nodes). The edges are also labelled with the total number of edges
that appear between such nodes in the `--dag` output. Also we print the
names of the wildcards on the nodes. Note that the wildcard names only
come out on the “top” node of a chain that uses the same wildcards.

Here is how you would run

``` r
library(SnakemakeDagR)
condense_dag(
  dagfile = system.file("extdata/example_dag.dot", package = "SnakemakeDagR"), 
  outfile = "condensed.dot" 
)
```

Running dot on the resulting output file gives this sort of picture:

<img src="README_files/images/condensed.svg" width="100%" style="display: block; margin: auto;" />

Cool!

## A more complex example

Here is what things look like on the workflow when it is expanded out to
some variant calling, making this dotfile:

``` r
system.file("extdata/more_steps.dot", package = "SnakemakeDagR")
```

which condenses down to this:

<img src="README_files/images/more_steps.svg" width="100%" style="display: block; margin: auto;" />

That is pretty informative. I like being able to see the different
wildcards that are in play.

## Running it on the command line

If you have R up and running on your system, and you have installed the
`SnakemakeDagR` package, then you can make a small executable file named
`condense_dag` that looks like this:

``` r
#!/usr/local/bin/Rscript
SnakemakeDagR::condense_dag(
  dagfile = file("stdin"),
  outfile = stdout() 
)
```

and put it in your `PATH`.

Note that the top line (with the shebang: `#!`) has to point to Rscript
on your system. You can get that with `which Rscript`.

Then when you make a DAG with Snakemake, you can just pipe it through to
condense it and render it with dot like this:

``` sh
snakemake  --dag | condense_dag | dot -Tpng > condensed_dag.png
```

Sweet!

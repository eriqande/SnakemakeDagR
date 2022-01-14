#' Condense a DAG into a rulegraph shape, but provide statistics on instance completion
#'
#' I had originally thought that I would end up with a rule graph with
#' numbers on the tail and head of each arrow saying how many jobs were done
#' and how many remained to be completed.  But I later decided to do dashed
#' nodes for completed, solid for incomplete.  Each such node will get a count
#' that says how many times, in total, that rule has been run, and the edges
#' between things will get a single weight that says how many such jobs
#' have been run, or are remaining to run.  So, there should never be an
#' edge from a solid (incomplete) parent to a dashed daughter, but we should see edges
#' from a dashed (complete) parent to a solid daughter.
#' @param dagfile path the dag file
#' @param outfile path to the output file to write a new .dot file into
#' @export
#' @examples
#' dagfile <- system.file("extdata/example_dag.dot", package = "SnakemakeDagR")
condense_dag <- function(
  dagfile,
  outfile = tempfile()
) {

  lines <- readLines(dagfile)

  # just take the first 4 lines and hope that stays constant
  pream <- lines[1:4]

  # get the nodes and edges in a tibble
  nodes <- tibble(
    raw = lines[str_detect(lines, "label = ")]
  )
  edges <- tibble(
    raw = lines[str_detect(lines, "->")]
  )

  # now, work over the node text so we can group it up, etc.

  ## Remove the wildcard values if present, then determine if it has been
  ## run or not, and also tweeze off the index/id
  nodes2 <- nodes %>%
    extract(
      raw,
      into = c("wildcards"),
      regex =  '(\\\\n.*)", color',
      remove = FALSE
    ) %>%
    replace_na(list(wildcards = "")) %>%
    mutate(
      canonical = str_replace(raw, '(\\\\n.*)", color', '", color') %>%
        str_replace(., "^\\s*\\d+\\[", "[")
    ) %>%
    extract(
      raw,
      into = "id",
      regex =  "^\\s*(\\d+)\\[label",
      remove = FALSE
    ) %>%
    mutate(
      status = case_when(
        str_detect(raw, "dashed") ~ "complete",
        TRUE ~ "incomplete"
      )
    ) %>%
    select(id, status, wildcards, canonical, raw)

  ## Now, we whittle that down to what we will work with:
  nodes3 <- nodes2 %>%
    select(id, canonical, status)

  ### Now, deal with the edges
  edges2 <- edges %>%
    extract(
      raw,
      into = c("origin", "dest"),
      regex = "^\\s*(\\d+)\\s*->\\s*(\\d+)"
    )


  ### Now we just join and enumerate
  tmp <- nodes3 %>%
    left_join(edges2, by = c("id" = "origin")) %>%
    setNames(str_c("origin_", names(.))) %>%
    rename(dest_id = origin_dest)

  full_set <- nodes3 %>%
    setNames(str_c("dest_", names(.))) %>%
    left_join(tmp, ., by = "dest_id")


  ### cool.  Now we just have to enumerate and then put new IDs on, and
  ### make a new dot file.
  FS2 <- full_set %>%
    filter(!is.na(dest_id)) %>% # remove non-existent arrows to daughters
    count(origin_canonical, dest_canonical, origin_status, dest_status)

  # first, get integer identifiers for each node
  node_levs <- unique(c(FS2$origin_canonical, FS2$dest_canonical))

  # make indexes for them, and also add text to the label that
  # shows how many times it has been (or needs to be) run
  FS3 <- FS2 %>%
    mutate(
      origin_idx = as.integer(factor(origin_canonical, levels = node_levs)),
      dest_idx = as.integer(factor(dest_canonical, levels = node_levs))
    ) %>%
    mutate(
      origin_canonical = str_replace(origin_canonical, "\", color", str_c(": ", n, "\", color")),
      dest_canonical = str_replace(dest_canonical, "\", color", str_c(": ", n, "\", color"))
    )

  # get the node text
  node_text <- unique(c(
    str_c(FS3$origin_idx, FS3$origin_canonical),
    str_c(FS3$dest_idx, FS3$dest_canonical)
  )) %>%
    str_c("    ", .)

  # get the edge decorations then make the edge text
  edge_text <- FS3 %>%
    mutate(
      decorations = case_when(
        dest_status == "incomplete" ~ str_c("[label = \"", n, "\"]"),
        TRUE ~ str_c("[style = \"dashed\", label = \"", n, "\"]")
      )
    ) %>%
    mutate(
      edge_text = sprintf("    %d -> %d %s;", origin_idx, dest_idx, decorations)
    ) %>%
    pull(edge_text)

  ### Now, plop that into a file
  cat(pream, sep = "\n", file = outfile)
  cat(node_text, sep = "\n", file = outfile, append = TRUE)
  cat(edge_text, sep = "\n", file = outfile, append = TRUE)
  cat("}", sep = "\n", file = outfile, append = TRUE)
}

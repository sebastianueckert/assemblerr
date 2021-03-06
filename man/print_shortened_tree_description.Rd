% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/description.R
\name{print_shortened_tree_description}
\alias{print_shortened_tree_description}
\title{Print tree description in compact format}
\usage{
print_shortened_tree_description(
  tree_description,
  type = "building block",
  show = "all",
  child_type = "entries",
  skip_root = TRUE
)
}
\arguments{
\item{tree_description}{A TreeDescription object}

\item{type}{type label to print to console}

\item{show}{which child nodes of the root to print or 'all' to print all}

\item{child_type}{type label for child elements}

\item{skip_root}{whether the root node should be printed}
}
\value{
The function prints to the console
}
\description{
Print tree description in compact format
}
\keyword{internal}

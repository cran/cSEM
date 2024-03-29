% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/zz_datasets.R
\docType{data}
\name{ITFlex}
\alias{ITFlex}
\title{Data: ITFlex}
\format{
A data frame containing the following variables:
\describe{
\item{\code{ITCOMP1}}{Software applications can be easily transported and
used across multiple platforms.}
\item{\code{ITCOMP2}}{Our firm provides multiple interfaces or entry points
(e.g., web access) for external end users.}
\item{\code{ITCOMP3}}{Our firm establishes corporate rules and standards for
hardware and operating systems to ensure platform compatibility.}
\item{\code{ITCOMP4}}{Data captured in one part of our organization are
immediately available to everyone in the firm.}
\item{\code{ITCONN1}}{Our organization has electronic links and connections
throughout the entire firm.}
\item{\code{ITCONN2}}{Our firm is linked to business partners through
electronic channels (e.g., websites, e-mail, wireless devices, electronic data interchange).}
\item{\code{ITCONN3}}{All remote, branch, and mobile offices are connected to
the central office.}
\item{\code{ITCONN4}}{There are very few identifiable communications
bottlenecks within our firm.}
\item{\code{MOD1}}{Our firm possesses a great speed in developing new
business applications or modifying existing applications.}
\item{\code{MOD2}}{Our corporate database is able to communicate in
several different protocols.}
\item{\code{MOD3}}{Reusable software modules are widely used in new
systems development.}
\item{\code{MOD4}}{IT personnel use object-oriented and prepackaged
modular tools to create software applications.}
\item{\code{ITPSF1}}{Our IT personnel have the ability to work effectively in
cross-functional teams.}
\item{\code{ITPSF2}}{Our IT personnel are able to interpret business problems
and develop appropriate technical solutions.}
\item{\code{ITPSF3}}{Our IT personnel are self-directed and proactive.}
\item{\code{ITPSF4}}{Our IT personnel are knowledgeable about the key
success factors in our firm.}
}
}
\source{
The data was collected through a survey by \insertCite{Benitez2018;textual}{cSEM}.
}
\usage{
ITFlex
}
\description{
A data frame containing 16 variables with 100 observations.
}
\details{
The dataset was studied by \insertCite{Benitez2018;textual}{cSEM} and is used in
\insertCite{Henseler2021;textual}{cSEM} for demonstration purposes, see the
corresponding tutorial.
All questionnaire items are measured on a 5-point scale.
}
\examples{
#============================================================================
# Example is taken from Henseler (2020)
#============================================================================
model_IT_Fex="
# Composite models
ITComp  <~ ITCOMP1 + ITCOMP2 + ITCOMP3 + ITCOMP4
Modul   <~ MOD1 + MOD2 + MOD3 + MOD4
ITConn  <~ ITCONN1 + ITCONN2 + ITCONN3 + ITCONN4
ITPers  <~ ITPSF1 + ITPSF2 + ITPSF3 + ITPSF4

# Saturated structural model
ITPers ~ ITComp + Modul + ITConn
Modul  ~ ITComp + ITConn 
ITConn ~ ITComp 
"

out <- csem(.data = ITFlex, .model = model_IT_Fex,
           .PLS_weight_scheme_inner = 'factorial',
           .tolerance = 1e-06,
           .PLS_ignore_structural_model = TRUE)

}
\references{
\insertAllCited{}
}
\keyword{datasets}

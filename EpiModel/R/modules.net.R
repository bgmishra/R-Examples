
#' @title Modules for Stochastic Network Models
#'
#' @description
#' Stochastic network models of infectious disease in EpiModel require statistical
#' modeling of networks, simulation of those networks forward through time, and
#' simulation of epidemic dynamics on top of those evolving networks. The
#' \code{\link{netsim}} function handles both the network and epidemic simulation
#' tasks. Within this function are a series of modules that initialize the
#' simulation, and then simulate new infections, recoveries, and demographics on
#' the network. Modules also handle the resimulation of the network and some
#' bookkeeping calculations for disease prevalence.
#'
#' Writing original network models that expand upon our built-in model set will
#' require modifying the existing modules or adding new modules to the workflow
#' in \code{\link{netsim}}. The existing modules may be used as a template for
#' replacement or new modules.
#'
#' This help page provides an orientation to these module functions, in the order
#' in which they are used within \code{\link{netsim}}, to help guide users in
#' writing their own functions. These module functions are not shown
#' on the help index since they are not called directly by the end-user. To
#' understand these functions in more detail, review the separate help pages
#' listed below.
#'
#' @section Initialization Module:
#' This function sets up the nodal attributes like disease status on the network
#' at the starting time step of disease simulation, \eqn{t_1}. For multiple-simulation
#' function calls, these are reset at the beginning of each individual simulation.
#' \itemize{
#'  \item \code{\link{initialize.net}}: sets up the master data structure used in
#'        the simulation, initializes which nodes are infected (via the initial
#'        conditions passed in \code{\link{init.net}}), and simulates a first
#'        time step of the networks given the network model fit from
#'        \code{\link{netest}}.
#' }
#'
#' @section Disease Status Modification Modules:
#' The main disease simulation occurs at each time step given the current state
#' of the network at that step. Infection of nodes is simulated as a function of
#' attributes of the nodes and the edges. Recovery of nodes is likewise simulated
#' as a function of nodal attributes of those infected nodes. These functions
#' also calculate summary flow measures such as disease incidence.
#' \itemize{
#'  \item \code{\link{infection.net}}: simulates disease transmission given an
#'        edgelist of discordant partnerships by calculating the relevant
#'        transmission and act rates for each edge, and then updating the nodal
#'        attributes and summary statistics.
#'  \item \code{\link{recovery.net}}: simulates recovery from infection either to
#'        a lifelong immune state (for SIR models) or back to the susceptible
#'        state (for SIS models), as a function of the recovery rate parameters
#'        specified \code{\link{param.net}}.
#' }
#'
#'
#' @section Demographic Modules:
#' Demographics such as birth and death processes are simulated at each time
#' step to update entries into and exits from the network. These are used in
#' dependent network models, in which the network is resimulated at each time
#' step to account for the nodal changes affecting the edges.
#' \itemize{
#'  \item \code{\link{deaths.net}}: randomly simulates death for nodes given
#'        their disease status (susceptible, infected, recovered), and their
#'        mode-specific death rates specified in \code{\link{param.net}}. Deaths
#'        involve deactivating nodes, which are then deleted from the network
#'        if \code{delete.nodes=TRUE} is set in \code{\link{control.net}}.
#'  \item \code{\link{births.net}}: randomly simulates new births into the network
#'        given the current population size and the birth rate specified in the
#'        \code{b.rate} parameters. This involves adding new nodes into the network.
#' }
#'
#' @section Network Resimulation Module:
#' In dependent network models, the network object is resimulated at each time
#' step to account for changes in the size of the network (changed through entries
#' and exits), and the disease status of the nodes.
#' \itemize{
#'  \item \code{\link{edges_correct}}: adjusts the edges coefficient of a network
#'        model to account for changes in the population size due to entries and
#'        exits. The default behavior is to preserve the mean degree (average
#'        number of edges per person) in response to change population sizes.
#'  \item \code{\link{resim_nets}}: resimulates the network object one time step
#'        forward given the set of formation and dissolution coefficients estimated
#'        in \code{\link{netest}}. This function also deletes the inactive nodes
#'        if the \code{delete.nodes} control is set to \code{TRUE}.
#' }
#'
#' @section Bookkeeping Module:
#' Network simulations require bookkeeping at each time step to calculate the
#' summary epidemiological statistics used in the model output analysis.
#' \itemize{
#'  \item \code{\link{get_prev.net}}: calculates the number in each disease state
#'        (susceptible, infected, recovered) at each time step for those active
#'        nodes in the network. If the \code{epi.by} control is used, it calculates
#'        these statistics by a set of nodal attributes.
#'  \item \code{\link{verbose.net}}: summarizes the current state of the simulation
#'        and prints this to the console.
#' }
#'
#'
#' @name modules.net
#' @aliases modules.net
#'
NULL

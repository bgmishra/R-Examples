## Copyright (C) 1995, 1996, 1997  Andreas Weingessel
##
## This file is part of Octave.
##
## Octave is free software; you can redistribute it and/or modify it
## under the terms of the GNU General Public License as published by
## the Free Software Foundation; either version 2, or (at your option)
## any later version.
##
## Octave is distributed in the hope that it will be useful, but
## WITHOUT ANY WARRANTY; without even the implied warranty of
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
## General Public License for more details.
##
## You should have received a copy of the GNU General Public License
## along with Octave; see the file COPYING.  If not, write to the Free
## Software Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA
## 02110-1301, USA.

## -*- texinfo -*-
## @deftypefn {Function File} {} bartlett (@var{m})
## Return the filter coefficients of a Bartlett (triangular) window of
## length @var{m}.
##
## For a definition of the Bartlett window, see e.g. A. V. Oppenheim &
## R. W. Schafer, "Discrete-Time Signal Processing".
## @} # deftypefn

## Author: AW <Andreas.Weingessel@ci.tuwien.ac.at>
## Description: Coefficients of the Bartlett (triangular) window

bartlett  <- function(n) {
  if (!(length(n) == 1 && (n == round(n)) && (n > 0)))
    stop("n has to be an integer > 0")
  if (n == 1)
    c <- 1
  else {
    n <- n - 1
    m <- trunc(n / 2)
    c <- c(2*(0:m)/n, 2 - 2*((m+1):n)/n)
  }
  c
}

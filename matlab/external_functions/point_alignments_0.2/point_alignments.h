/*----------------------------------------------------------------------------

  Point alignment detector

  This code implements the algorithm described in

    "Point Alignment Detection" by Jose Lezama, Rafael Grompone von Gioi,
    Jean-Michel Morel, and Gregory Randall, submitted to PAMI.

  Copyright (c) 2013 rafael grompone von gioi <grompone@gmail.com>

  This program is free software: you can redistribute it and/or modify
  it under the terms of the GNU Affero General Public License as
  published by the Free Software Foundation, either version 3 of the
  License, or (at your option) any later version.

  This program is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
  GNU Affero General Public License for more details.

  You should have received a copy of the GNU Affero General Public License
  along with this program. If not, see <http://www.gnu.org/licenses/>.

  ----------------------------------------------------------------------------*/

#ifndef POINT_ALIGNMENTS_HEADER
#define POINT_ALIGNMENTS_HEADER

/*----------------------------------------------------------------------------*/
/*
   input:  point     - input points (including extended points at the end)
           N         - number of points
           X,Y       - domain size [0,X] x [0,Y]

   output: pointer to *Nout 8-tuples
           x1 y1 x2 y2 width local_window_width num_boxes log_nfa

           if local_window_width is zero, no local window
           if num_boxes is zero, no boxes
 */
double * point_alignments(double * point, int N, double X, double Y, int *Nout);

#endif /* !POINT_ALIGNMENTS_HEADER */
/*----------------------------------------------------------------------------*/

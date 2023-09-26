Point alignment detector
========================
version 0.2 - October 17, 2013
by Rafael Grompone von Gioi <grompone@gmail.com>


Introduction
------------

This code implements an algorithm for automatically finding alignments in
a 2D set of points. The method was developed by Jose Lezama,
Rafael Grompone von Gioi, Jean-Michel Morel, and Gregory Randall and is
described in:

  "Point Alignment Detection", by Jose Lezama, Rafael Grompone von Gioi,
  Jean-Michel Morel, and Gregory Randall, submitted to IEEE Transactions
  on Pattern Analysis and Machine Intelligence.

For more information, including this code and an online demo, please visit:
http://bit.ly/point_alignments


Files
-----

README.txt             - This file
COPYING                - GNU AFFERO GENERAL PUBLIC LICENSE Version 3
Makefile               - Compilation instructions for 'make'
point_alignments.c     - Point Alignment Detector ANSI C code
point_alignments.h     - Point Alignment Detector header
point_alignments_cmd.c - Command line interface, C source file
alignments2eps.c       - Auxiliary program for generating EPS output
data.txt               - Sample point set
align.txt              - Expected result for 'data.txt'
align.eps              - Expected result for 'data.txt', EPS drawing
align.pdf              - Expected result for 'data.txt', PDF drawing


Compiling
---------

This implementation of the Point Alignment Detector is written in ANSI C
Language and can be used as a module to be called from other C language
program (using files point_alignments.h and point_alignments.c), or by
using the provided command line interface.

This distribution includes a Makefile file with instructions for the program
'make', to build the command line interface. The same Makefile includes
instructions for the auxiliary program alignments2eps for generating an EPS
output for simple visualization.

To build both programs, a C compiler (called with 'cc') must be installed on
your system, as well as the program 'make'. These program only use the
standard C library so it should compile in any ANSI C Language environment.
In particular, it should compile in an Unix like system. In such an
environment, the compiling instruction is just

  make

from the directory where the source codes and the Makefile are located. The
compiled program can be tested by running on the sample data and comparing to
the expected output. Due numerical rounding errors, it is possible that the
exact numerical values obtained differ in different systems. The errors should
be however small. Visualizing the EPS or PDF drawing of the results, it should
be indistinguishable from the expected one. In a Unix environment, the test set
is executed with

  make test

The result should include the files out.txt, out.eps, and out.pdf, that should
correspond to provided ones, align.txt, align.eps, and align.pdf. In addition,
a simplified drawing should be generated for the same output in files
out_simple.eps and out_simple.pdf.

If the 'make' program is not available, the compilation instruction for the
main program is

  cc -O3 -o point_alignments point_alignments_cmd.c point_alignments.c -lm

The compiler 'cc' may be replaced by the appropriate compiler command in the
case it differs. The option '-O3' is to ask the compiler to optimize the code
for better execution time; it can be removed if unavailable.


Running
-------

The simplest point alignment command execution is just

  point_alignments

or

  ./point_alignments

if the command is not in the path. That should print a simple error message
and the expected input. A typical execution would be

  ./point_alignments data.txt 1 1 out.txt

where data.txt is the input data, (1,1) is the domain size (Dx,Dy), implying
that input points should have coordinates in [0 Dx] x [0 Dy], and out.txt
is the filename to write the output.

Input is a TXT file with numbers written in standard ASCII floating point
notation, and separated by any combination of spaces, tabs, or end-of-line. The
order of the numbers is important; the first two numbers corresponds to the two
coordinates of the first point, the second two numbers is the second point, and
so on. The following is an example of input file with four points:

  0.1523418 0.8593640
  0.1933569 0.8242081
  0.2460906 0.7851462
  0.2910119 0.7343656

The output is also a TXT file containing one row per alignment found,
and eight numbers per alignment. The following is an example with 3 detections:

  0.218747 0.263668 0.943347 0.546868 0.013752 0.194494 16 -7.4866628
  0.121092 0.341792 0.419916 0.917957 0.022947 0.229472 19 -4.9414027
  0.783193 0.205075 0.218747 0.816395 0.041602 0.294175 21 -1.8594956

The eight numbers represents the following:

  x1 y1 x2 y2 width local_window_width num_boxes log_nfa

Observing the provided result 'align.pdf' may help to understand these numbers.
The first four numbers define the coordinates of the alignment as a line
segment from coordinates (x1,y1) to (x2,y2). These coordinates should
corresponds to the coordinates of points in the input (the candidates for
alignments are build for pairs of input points). The following number is the
width of the alignment, corresponding a rectangle where input points forming
the alignment are included. This number gives an idea of how well aligned into
a line are these points. The 'local_window_width' is the width of an external
rectangle to the alignment where the local point density was estimated. The
alignment was divided into a certain number of boxes to evaluate its
meaningfulness; the integer 'num_boxes' indicates this number. Finally, the
last number is the log(NFA) associated with the detections, and it is a number
that measure how meaningful is: the smaller this quantity, the more meaningful
the detection. The standard threshold on this quantity is NFA=1 or log(NFA)=0,
so all values should be negative. For more information, please see the paper
"Point Alignment Detection" mentioned above.

The auxiliary program 'alignments2eps' may help visualization by generating an
EPS drawing of the result. The EPS figure can be easily converted to PDF format
also. This program uses several parameters to modify the appearance of the
produced drawing. A typical execution is

  ./alignments2eps data.txt align.txt 1 1 500 1.75 2 1 1 8 out.eps

and executing the command without parameters one get a short description of
the required input. These parameters are:

  ./alignments2eps point.txt align.txt Dx Dy s r w1 w2 w3 t out.eps

First we have to give the input point set (point.txt) and the resulting
alignment output (align.txt). The domain size Dx,Dy is required, it should be
the same used before and all points should fit in it. The EPS output will have
the same output as the domain; for this reason, one may one to scale the
drawing when the domain size is not adequate. In the previous example, the unit
domain size seems a little small, so a 500 scale factor (s) was applied.  The
following 5 numbers corresponds to the size or width of all the graphical
elements: r is the radius of the point dots, w1 is the line width for alignment
strip, w2 is the line width of the local window, w3 is the line width of the
boxes, and t is the size of the text showing the NFA value. Each one of these 5
elements can be removed by using a negative o zero value. The EPS file is
written in 'out.eps'.

The previous example used a set of parameters convenient to show all the
elements involved in the detection: local window, boxes, NFA value. A second
useful parameter set is the following, that only shows the detected rectangles:

  ./alignments2eps data.txt align.txt 1 1 500 1.75 2 0 0 0 out_simple.eps


Copyright and License
---------------------

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


Thanks
------

We would be grateful to receive any comment, especially about errors,
bugs, or strange results.

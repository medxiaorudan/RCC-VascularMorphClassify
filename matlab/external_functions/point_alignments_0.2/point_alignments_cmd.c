/*----------------------------------------------------------------------------

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
#include <stdio.h>
#include <stdlib.h>
#include "point_alignments.h"

/*----------------------------------------------------------------------------*/
/** max and min value */
#define max(a,b) (((a)>(b))?(a):(b))
#define min(a,b) (((a)<(b))?(a):(b))

/*----------------------------------------------------------------------------*/
/** Fatal error, print a message to standard-error output and exit.
 */
static void error(char * msg)
{
  fprintf(stderr,"Error: %s\n",msg);
  exit(EXIT_FAILURE);
}

/*----------------------------------------------------------------------------*/
/** Memory allocation, print an error and exit if fail.
 */
static void * xmalloc(size_t size)
{
  void * p;
  if( size == 0 ) error("xmalloc: zero size");
  p = malloc(size);
  if( p == NULL ) error("xmalloc: out of memory");
  return p;
}

/*----------------------------------------------------------------------------*/
/** Memory re-allocation, print an error and exit if fail.
 */
static void * xrealloc(void * p, size_t size)
{
  if( size == 0 ) error("xrealloc: zero size");
  p = realloc(p,size);
  if( p == NULL ) error("xrealloc: out of memory");
  return p;
}

/*----------------------------------------------------------------------------*/
/** Open file, print an error and exit if fail.
 */
static FILE * xfopen(const char * path, const char * mode)
{
  FILE * f = fopen(path,mode);
  if( f == NULL ) error("xfopen: unable to open file");
  return f;
}

/*----------------------------------------------------------------------------*/
/** Close file, print an error and exit if fail.
 */
static int xfclose(FILE * f)
{
  if( fclose(f) == EOF ) error("xfclose: unable to close file");
  return 0;
}

/*----------------------------------------------------------------------------*/
static double * read_txt(char * filename, int * N)
{
  FILE * f;
  int i,n,n_alloc;
  double val;
  double * p;

  /* open file */
  f = xfopen(filename,"r");

  /* initialize output */
  n = 0;
  n_alloc = 1;
  p = xmalloc( n_alloc * sizeof(double) );

  /* read points */
  while( fscanf(f,"%lf%*[^0-9.eE+-]",&val) == 1 )
    {
      if( n >= n_alloc )
        {
          n_alloc *= 2;
          p = xrealloc( p, n_alloc * sizeof(double) );
        }
      p[n++] = val;
    }

  /* close file */
  xfclose(f);

  /* return list of points */
  *N = n;
  return p;
}

/*----------------------------------------------------------------------------*/
/** Write an TXT format matrix file
 */
void write_txt(double * data, int X, int Y, char * filename)
{
  FILE * f;
  int i,j;

  /* open file */
  f = xfopen(filename,"w");

  /* write data */
  if( data != NULL && X > 0 && Y > 0 )
    for(j=0; j<Y; j++)
      {
        for(i=0; i<X; i++) fprintf(f,"%.16g ",data[i+j*X]);
        fprintf(f,"\n");
      }

  /* close file */
  xfclose(f);
}

/*----------------------------------------------------------------------------*/
/*                                    Main                                    */
/*----------------------------------------------------------------------------*/
int main(int argc, char ** argv)
{
  double * point;
  int N;
  double X,Y;
  double * align;
  int Nout;

  /* read input */
  if( argc != 5 ) error("use: point_alignments point.txt Dx Dy output.txt\n\n"
                        "points should be in the domain [0 Dx] x [0 Dy]");
  point = read_txt(argv[1],&N); /* N is the total number of numbers,
                                   it corresponds to N/2 points in 2D */
  X = atof(argv[2]);
  Y = atof(argv[3]);

  /* compute alignments */
  align = point_alignments(point,N/2,X,Y,&Nout);

  /* output */
  printf("%d point alignments found\n",Nout);
  write_txt(align,8,Nout,argv[4]);

  /* free memory */
  if( align != NULL ) free( (void *) align );
  free( (void *) point );

  return EXIT_SUCCESS;
}
/*----------------------------------------------------------------------------*/

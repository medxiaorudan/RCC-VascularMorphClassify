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
#include <string.h>
#include <math.h>

/*----------------------------------------------------------------------------*/
/** 2 pi */
#define M_2__PI 6.28318530718

/*----------------------------------------------------------------------------*/
/** Fatal error, print a message to standard-error output and exit.
 */
void error(char * msg)
{
  fprintf(stderr,"Error: %s\n",msg);
  exit(EXIT_FAILURE);
}

/*----------------------------------------------------------------------------*/
/** Memory allocation, print an error and exit if fail.
 */
void * xmalloc(size_t size)
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
void * xrealloc(void * p, size_t size)
{
  if( size == 0 ) error("xrealloc: zero size");
  p = realloc(p,size);
  if( p == NULL ) error("xrealloc: out of memory");
  return p;
}

/*----------------------------------------------------------------------------*/
/** Open file, print an error and exit if fail.
 */
FILE * xfopen(const char * path, const char * mode)
{
  FILE * f = fopen(path,mode);
  if( f == NULL ) error("xfopen: unable to open file");
  return f;
}

/*----------------------------------------------------------------------------*/
/** Close file, print an error and exit if fail.
 */
int xfclose(FILE * f)
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
/** Open an EPS file.
    If the name is "-" the file is written to standard output.

    According to

      Adobe "Encapsulated PostScript File Format Specification",
      Version 3.0, 1 May 1992,

    and

      Adobe "PostScript(R) LANGUAGE REFERENCE", third edition, 1999.
 */
FILE * eps_open(char * filename, int xsize, int ysize)
{
  FILE * eps;

  /* open file */
  if( strcmp(filename,"-") == 0 ) eps = stdout;
  else eps = fopen(filename,"w");
  if( eps == NULL ) error("unable to open EPS output file.");

  /* write EPS header */
  fprintf(eps,"%%!PS-Adobe-3.0 EPSF-3.0\n");
  fprintf(eps,"%%%%BoundingBox: 0 0 %d %d\n",xsize,ysize);
  fprintf(eps,"%%%%Creator: jirafa\n");
  fprintf(eps,"%%%%Title: (%s)\n",filename);
  fprintf(eps,"%%%%EndComments\n");

  return eps;
}

/*----------------------------------------------------------------------------*/
/** Close an EPS file.

    According to

      Adobe "Encapsulated PostScript File Format Specification",
      Version 3.0, 1 May 1992,

    and

      Adobe "PostScript(R) LANGUAGE REFERENCE", third edition, 1999.
 */
void eps_close(FILE * eps)
{
  if( eps == NULL ) error("NULL EPS file pointer.");

  /* close EPS file */
  fprintf(eps,"showpage\n");
  fprintf(eps,"%%%%EOF\n");
  if( eps != stdout && fclose(eps) == EOF )
    error("unable to close file while writing EPS file.");
}

/*----------------------------------------------------------------------------*/
/** Add a line segment to an EPS file.

    According to

      Adobe "Encapsulated PostScript File Format Specification",
      Version 3.0, 1 May 1992,

    and

      Adobe "PostScript(R) LANGUAGE REFERENCE", third edition, 1999.
 */
void eps_add_line( FILE * eps, double x1, double y1, double x2, double y2,
                   double width )
{
  if( eps == NULL ) error("NULL EPS file pointer.");

  fprintf( eps, "newpath %f %f moveto %f %f lineto %f setlinewidth stroke\n",
           x1, y1, x2, y2, width );
}

/*----------------------------------------------------------------------------*/
/** Add a dot to an EPS file.

    According to

      Adobe "Encapsulated PostScript File Format Specification",
      Version 3.0, 1 May 1992,

    and

      Adobe "PostScript(R) LANGUAGE REFERENCE", third edition, 1999.
 */
void eps_add_dot( FILE * eps, double x, double y, double radius )
{
  if( eps == NULL ) error("NULL EPS file pointer.");
  fprintf(eps,"newpath %f %f %f 0 360 arc closepath fill\n",x,y,radius);
}

/*----------------------------------------------------------------------------*/
/** Write text to an EPS file.

    According to

      Adobe "Encapsulated PostScript File Format Specification",
      Version 3.0, 1 May 1992,

    and

      Adobe "PostScript(R) LANGUAGE REFERENCE", third edition, 1999.
 */
void eps_text( FILE * eps, double x, double y, double angle,
               double size, char * text )
{
  if( eps == NULL ) error("NULL EPS file pointer.");
  fprintf(eps,"gsave\n");
  fprintf(eps,"  /Courier findfont %f scalefont setfont\n",size);
  fprintf(eps,"  %f %f translate %f rotate\n",x,y,angle);
  fprintf(eps,"  newpath 0 0 moveto (%s) show\n",text);
  fprintf(eps,"grestore\n");
}

/*----------------------------------------------------------------------------*/
/*                                    Main                                    */
/*----------------------------------------------------------------------------*/
int main(int argc, char ** argv)
{
  double * point;
  double * align;
  int N,M;
  double Dx,Dy,s,R,W1,W2,W3,T;
  FILE * eps;
  int i,j;
  double x1,y1,x2,y2,w,l,b,nfa,dx,dy,len,hw,hl,hb;
  char buffer[512];

  /* usage */
  if( argc != 12 )
    error("use: alignments2eps point.txt align.txt X Y s r w1 w2 w3 t out.eps\n"
          "\n"
          "     point.txt  2xN matrix, points coordinates\n"
          "     align.txt  8xM matrix, alignment data:\n"
          "                x1 y1 x2 y2 width local boxes nfa\n"
          "                    if local=0, no local window\n"
          "                    if boxes=0, no boxes\n"
          "     X Y        domain size\n"
          "     s          scale points and domain by multiplying by s\n"
          "     r          radius of dots (not drawn for r<=0)\n"
          "     w1         line width for alignment strip (not drawn w1<=0)\n"
          "     w2         width local window lines (not drawn for w2<=0)\n"
          "     w3         width box lines (not drawn for w3<=0)\n"
          "     t          size of text (not draw for t<=0)\n"
          "     out.eps    output");

  /* read input */
  point = read_txt(argv[1],&N);
  if( N<=0 || (N%2)!=0 ) error("invalid point file");
  N /= 2; /* N=total numbers => N/2 points */
  align = read_txt(argv[2],&M);
  if( M<0 || (M%8)!=0 ) error("invalid alignment file");
  M /= 8; /* M=total numbers => M/8 alignments */
  Dx = atof(argv[3]);  /* domain x */
  Dy = atof(argv[4]);  /* domain y */
  s  = atof(argv[5]);  /* scale */
  R  = atof(argv[6]);  /* dot radius */
  W1 = atof(argv[7]);  /* aligment lines width */
  W2 = atof(argv[8]);  /* local window lines width */
  W3 = atof(argv[9]);  /* box lines width */
  T  = atof(argv[10]); /* text size */

  /* apply scale */
  Dx *= s;
  Dy *= s;
  for(i=0; i<N; i++)
    {
      point[2*i+0] *= s;
      point[2*i+1] *= s;
    }
  for(i=0; i<M; i++)
    {
      align[8*i + 0] *= s;
      align[8*i + 1] *= s;
      align[8*i + 2] *= s;
      align[8*i + 3] *= s;
      align[8*i + 4] *= s;
      align[8*i + 5] *= s;
    }

  /* create EPS */
  eps = eps_open(argv[11], Dx, Dy);

  /* dots */
  if( R > 0.0 )
    for(i=0; i<N; i++)
      eps_add_dot(eps,point[2*i+0],Dy-point[2*i+1],R);

  /* alignments */
  for(i=0; i<M; i++)
    {
      x1  = align[8*i + 0];
      y1  = align[8*i + 1];
      x2  = align[8*i + 2];
      y2  = align[8*i + 3];
      w   = align[8*i + 4];
      l   = align[8*i + 5];
      b   = align[8*i + 6];
      nfa = align[8*i + 7];

      dx = x2-x1;
      dy = y2-y1;
      len = sqrt( dx*dx + dy*dy );
      dx /= len;
      dy /= len;

      hw = w / 2.0; /* half width */
      hl = l / 2.0; /* half local window width */

      /* alignment rectangle */
      if( W1 > 0.0 )
        {
          eps_add_line(eps,x1-dy*hw,Dy-(y1+dx*hw),x2-dy*hw,Dy-(y2+dx*hw),W1);
          eps_add_line(eps,x1+dy*hw,Dy-(y1-dx*hw),x2+dy*hw,Dy-(y2-dx*hw),W1);
          eps_add_line(eps,x1-dy*hw,Dy-(y1+dx*hw),x1+dy*hw,Dy-(y1-dx*hw),W1);
          eps_add_line(eps,x2-dy*hw,Dy-(y2+dx*hw),x2+dy*hw,Dy-(y2-dx*hw),W1);
        }

      /* local window */
      if( l > 0.0 && W2 > 0.0 )
        {
          eps_add_line(eps,x1-dy*hl,Dy-(y1+dx*hl),x2-dy*hl,Dy-(y2+dx*hl),W2);
          eps_add_line(eps,x1+dy*hl,Dy-(y1-dx*hl),x2+dy*hl,Dy-(y2-dx*hl),W2);
          eps_add_line(eps,x1-dy*hl,Dy-(y1+dx*hl),x1+dy*hl,Dy-(y1-dx*hl),W2);
          eps_add_line(eps,x2-dy*hl,Dy-(y2+dx*hl),x2+dy*hl,Dy-(y2-dx*hl),W2);
        }

      /* boxes */
      if( b > 0.0 && W3 > 0.0 )
        {
          hb = len / (b+1) / 2.0; /* half box side */

          for(j=0; j<=b; j++)
            eps_add_line(eps, x1-dy*hw     + dx*hb*(1+2*j),
                              Dy-(y1+dx*hw + dy*hb*(1+2*j)),
                              x1+dy*hw     + dx*hb*(1+2*j),
                              Dy-(y1-dx*hw + dy*hb*(1+2*j)), W3);
        }

      /* write NFA value */
      if( T > 0.0 )
        {
          sprintf(buffer,"%g",nfa);
          eps_text(eps, x1+dy*(hw+1)+dx, Dy-(y1-dx*(hw+1)+dy),
                        -360*atan2(dy,dx)/M_2__PI, T, buffer);
        }
    }

  /* close EPS */
  eps_close(eps);

  /* free memory */
  free( (void *) point );
  free( (void *) align );

  return EXIT_SUCCESS;
}
/*----------------------------------------------------------------------------*/

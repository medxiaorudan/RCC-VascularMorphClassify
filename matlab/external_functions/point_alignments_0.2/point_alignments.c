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
#include <stdio.h>
#include <stdlib.h>
#include <math.h>

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
/* Log10 of tail of binomial distribution by Hoeffding approximation
*/
static double log_bin(int n, int k, double p)
{
  double r = (double) k / (double) n;
  if( r <= p ) return 0.0;
  else if( n == k) return k * log10(p);
  else return k * log10(p/r) + (n-k) * log10( (1-p)/(1-r) );
}

/*----------------------------------------------------------------------------*/
static int comp_align(const void *a, const void *b)
{
  if( *( ((double *) a) + 7) < *( ((double *) b) + 7) ) return -1;
  if( *( ((double *) a) + 7) > *( ((double *) b) + 7) ) return  1;
  return 0;
}

/*----------------------------------------------------------------------------*/
/*
   input:  point     - input points (including extended points at the end)
           N         - number of points
           Next      - number of extended points

   output: pointer to *Nout 8-tuples
           x1 y1 x2 y2 width local_window_width num_boxes log_nfa

           if local_window_width is zero, no local window
           if num_boxes is zero, no boxes
 */
static double * find_alignments( double * point, int N, int Next, int * Nout,
                                 double X, double Y )
{
  int i,j,k,n,nn,n1,n2,m,v,b,n_box;
  double x1,y1,x2,y2,dx,dy,len,w,xx,yy,logNFA,l,box,p0,p1,d;
  double max_w_over_len = 10.0;
  int n_w = 8;
  int n_l = 8;
  int ww,ll;
  int NN;
  int * used;
  double * in_align;

  /* number of tests */
  double logNT = log10(N) + log10(N-1) - log10(2) + log10(n_w) + log10(n_l)
                 + log10(N)/2.0;

  /* initialize output */
  int n_align = 0;
  int n_alloc = 1;
  double * align = xmalloc( n_alloc * 8 * sizeof(double) );

  /* loop over all pair of points */
#pragma omp parallel for schedule(dynamic) private(i,j,x1,y1,x2,y2,dx,dy,len,w,ww,l,ll,d,NN,n1,n2,nn,m,xx,yy,in_align,k,box,v,used,b,n,p0,p1,n_box,logNFA)
  for(i=0; i<(N-1); i++)
    for(j=i+1; j<N; j++)
      {
        x1 = point[2*i];          y1 = point[2*i+1];
        x2 = point[2*j];          y2 = point[2*j+1];
        dx = x2-x1;               dy = y2-y1;
        len = sqrt(dx*dx+dy*dy);
        if( len == 0.0 )  continue;
        dx /= len;                dy /= len;

        /* get memory */
        used = xmalloc( (N-2) * sizeof(int) );
        in_align = xmalloc( N * sizeof(double) );

        /* loop over width */
        for( w=len/max_w_over_len, ww=0; ww<n_w; ++ww, w/=sqrt(2) )
          {
            /* loop over local window size */
            for( l=len, ll=0; l>w && ll<n_l; ++ll, l/=sqrt(2) )
              {
                /* check if local window goes out of domain.
                   to speed-up, extended points are only used
                   when the local window exceed the domain. */
                if( (d=(x1 - dy*l/2.0)) < 0.0 || d >= X ||
                    (d=(x1 + dy*l/2.0)) < 0.0 || d >= X ||
                    (d=(x2 - dy*l/2.0)) < 0.0 || d >= X ||
                    (d=(x2 + dy*l/2.0)) < 0.0 || d >= X ||
                    (d=(y1 + dx*l/2.0)) < 0.0 || d >= Y ||
                    (d=(y1 - dx*l/2.0)) < 0.0 || d >= Y ||
                    (d=(y2 + dx*l/2.0)) < 0.0 || d >= Y ||
                    (d=(y2 - dx*l/2.0)) < 0.0 || d >= Y )  NN = Next;
                else NN = N;

                /* count number of points in the strips */
                n1 = n2 = nn = 0;
                for(m=0; m<NN; m++)
                  {
                    if( m==i || m==j ) continue; /* do not count i and j */

                    /* compute coordinates relative to alingments */
                    xx =  dx * (point[2*m]-x1) + dy * (point[2*m+1]-y1);
                    yy = -dy * (point[2*m]-x1) + dx * (point[2*m+1]-y1);

                    /* count local window points */
                    if( xx < 0.0 || xx >= len ) continue;
                    if( yy < -l/2.0 || yy > l/2.0 ) continue;
                    if( yy < -w/2.0 ) ++n1;
                    else if( yy > w/2.0 ) ++n2;
                    else if(m<N) in_align[nn++] = xx;
                  }

                /* number of boxes in the alignment: from 1 to N-2
                   the two points that define the alignment are not counted */
                for(k=max(nn/2,1); k<=min(2*nn,N-2); k++)
                  {
                    /* compute box side */
                    box = len / (k+1);

                    /* free used boxes */
                    for(v=0; v<k; v++) used[v] = 0;

                    /* count points in boxes */
                    for(m=0; m<nn; m++)
                      {
                        b = floor( (in_align[m] - box/2.0) / box );
                        if( b>=0 && b<k ) ++used[b];
                      }

                    /* compute NFA */
                    n = 2 * max(n1,n2) + nn;
                    p0 = w * box / len / l;
                    p1 = 1.0 - pow( 1.0 - p0, n );
                    for( n_box = 0, v=0; v<k; v++ )
                      if( used[v] != 0 )
                        ++n_box;
                    logNFA = logNT + log_bin( k, n_box, p1 );

                    /* store result */
                    if( logNFA < 0.0 )
#pragma omp critical
                      {
                        /* get more memory if needed */
                        if( n_align >= n_alloc )
                          {
                            n_alloc *= 2;
                            align = xrealloc(align, n_alloc*8*sizeof(double));
                          }

                        align[8*n_align+0] = x1;
                        align[8*n_align+1] = y1;
                        align[8*n_align+2] = x2;
                        align[8*n_align+3] = y2;
                        align[8*n_align+4] = w;
                        align[8*n_align+5] = l;
                        align[8*n_align+6] = k;
                        align[8*n_align+7] = logNFA;
                        ++n_align;
                      }
                  }
              }
          }

        /* free memory */
        free( (void *) used );
        free( (void *) in_align );
      }

  /* result */
  *Nout = n_align;
  return align;
}

/*----------------------------------------------------------------------------*/
/*
   input:  point     - input points (including extended points at the end)
           N         - number of points
           Next      - number of extended points
           align     - list of alignments
           Na        - number of input alignments

   output: pointer to *Nout 8-tuples
           x1 y1 x2 y2 width local_window_width num_boxes log_nfa

           if local_window_width is zero, no local window
           if num_boxes is zero, no boxes
 */
static double * masking( double * point, int N, int Next,
                         double * align, int Na, int * Nout,
                         double X, double Y )
{
  int i,j,k,n,n1,n2,n3,m,v,b,n_box;
  double x1,y1,x2,y2,dx,dy,len,w,xx,yy,l,box,p0,p1,d;
  double m_x1,m_y1,m_x2,m_y2,m_dx,m_dy,m_len,m_w,m_xx,m_yy,m_l;
  double logNFA,max_logNFA;
  int n_w = 8;
  int n_l = 8;
  int NN;

  /* number of tests */
  double logNT = log10(N) + log10(N-1) - log10(2) + log10(n_w) + log10(n_l)
                 + log10(N)/2.0;

  /* get memory to store used boxes */
  int * used = xmalloc( (N-2) * sizeof(int) );

  /* initialize output */
  int n_out = 0;
  int n_alloc = 1;
  double * out = xmalloc( n_alloc * 8 * sizeof(double) );

  /* sort alignments by NFA */
  qsort( (void *) align, Na, 8*sizeof(double), &comp_align );

  /* first alignment is directly added to the output */
  out[8*n_out+0] = align[0];
  out[8*n_out+1] = align[1];
  out[8*n_out+2] = align[2];
  out[8*n_out+3] = align[3];
  out[8*n_out+4] = align[4];
  out[8*n_out+5] = align[5];
  out[8*n_out+6] = align[6];
  out[8*n_out+7] = align[7];
  ++n_out;

  /* loop over ordered alignments */
  for(i=1; i<Na; i++)
    {
      /* alignment data */
      x1 = align[8*i+0];
      y1 = align[8*i+1];
      x2 = align[8*i+2];
      y2 = align[8*i+3];
      w  = align[8*i+4];
      l  = align[8*i+5];
      k  = align[8*i+6];
      dx = x2-x1;
      dy = y2-y1;
      len = sqrt(dx*dx+dy*dy);
      dx /= len;
      dy /= len;
      box = len / (k+1);

      /* try masking the alignment by already detected ones */
      max_logNFA = align[8*i+7];
      for(j=0; j<n_out; j++)
        {
          /* masking candidate data */
          m_x1 = out[8*j+0];
          m_y1 = out[8*j+1];
          m_x2 = out[8*j+2];
          m_y2 = out[8*j+3];
          m_w  = out[8*j+4];
          m_l  = out[8*j+5];
          m_dx = m_x2-m_x1;
          m_dy = m_y2-m_y1;
          m_len = sqrt(m_dx*m_dx+m_dy*m_dy);
          m_dx /= m_len;
          m_dy /= m_len;

          /* free used boxes */
          for(v=0; v<k; v++) used[v] = 0;

          /* check if local window goes out of domain.
             to speed-up, extended points are only used
             when the local window exceed the domain. */
          if( (d=(x1 - dy*l/2.0)) < 0.0 || d >= X ||
              (d=(x1 + dy*l/2.0)) < 0.0 || d >= X ||
              (d=(x2 - dy*l/2.0)) < 0.0 || d >= X ||
              (d=(x2 + dy*l/2.0)) < 0.0 || d >= X ||
              (d=(y1 + dx*l/2.0)) < 0.0 || d >= Y ||
              (d=(y1 - dx*l/2.0)) < 0.0 || d >= Y ||
              (d=(y2 + dx*l/2.0)) < 0.0 || d >= Y ||
              (d=(y2 - dx*l/2.0)) < 0.0 || d >= Y )  NN = Next;
          else NN = N;

          /* count points */
          n1 = n2 = n3 = 0;
          for(m=0; m<NN; m++)
            {
              /* do not count defining points */
              if( point[2*m] == x1 && point[2*m+1] == y1 ) continue;
              if( point[2*m] == x2 && point[2*m+1] == y2 ) continue;

              /* compute coordinates relative to alingments */
              xx =  dx * (point[2*m]-x1) + dy * (point[2*m+1]-y1);
              yy = -dy * (point[2*m]-x1) + dx * (point[2*m+1]-y1);

              /* count points in the local window */
              if( xx < 0.0 || xx >= len ) continue;
              if( yy < -l/2.0 || yy > l/2.0 ) continue;
              if( yy < -w/2.0 )
                {
                  ++n1;
                  continue;
                }
              if( yy >  w/2.0 )
                {
                  ++n2;
                  continue;
                }
              if( m>=N ) continue; /* do not count ext points */
              ++n3;

              /* masked if the point belong to masking candidate */
              m_xx =  m_dx * (point[2*m]-m_x1) + m_dy * (point[2*m+1]-m_y1);
              m_yy = -m_dy * (point[2*m]-m_x1) + m_dx * (point[2*m+1]-m_y1);
              if( fabs(m_yy) < m_w/2.0 && m_xx>=0.0 && m_xx<m_len ) continue;

              /* count if the points that belong to one box */
              b = floor( (xx - box/2.0) / box );
              if( b>=0 && b<k ) ++used[b];
            }

          /* compute NFA after masking */
          n = 2 * max(n1,n2) + n3;
          p0 = w * box / len / l;
          p1 = 1.0 - pow( 1.0 - p0, n );
          for( n_box = 0, v=0; v<k; v++ )
            if( used[v] != 0 )
              ++n_box;
          logNFA = logNT + log_bin( k, n_box, p1 );
          if( logNFA > max_logNFA ) max_logNFA = logNFA;
        }
      if( max_logNFA > 0.0 ) continue;

      /* get more memory if needed */
      if( n_out >= n_alloc )
        {
          n_alloc *= 2;
          out = xrealloc( out, n_alloc * 8 * sizeof(double) );
        }

      /* store alignment to output */
      out[8*n_out+0] = align[8*i+0];
      out[8*n_out+1] = align[8*i+1];
      out[8*n_out+2] = align[8*i+2];
      out[8*n_out+3] = align[8*i+3];
      out[8*n_out+4] = align[8*i+4];
      out[8*n_out+5] = align[8*i+5];
      out[8*n_out+6] = align[8*i+6];
      out[8*n_out+7] = align[8*i+7];
      ++n_out;
    }

  /* free memory */
  free( (void *) used );

  /* result */
  *Nout = n_out;
  return out;
}

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
double * point_alignments(double * point, int N, double X, double Y, int * Nout)
{
  double * align;
  double * align_m;
  int Na,Nm;
  double * point_ext;
  int Next;
  int i,j;
  double Xsign[9] =   { 1, -1,  1, -1, -1, -1, -1,  1, -1 };
  double Ysign[9] =   { 1, -1, -1, -1,  1,  1, -1, -1, -1 };
  double Xoffset[9] = { 0,  0,  0,  2,  0,  2,  0,  0,  2 };
  double Yoffset[9] = { 0,  0,  0,  0,  0,  0,  2,  2,  2 };

  /* extended points to handle domain border: symmtric extension */
  Next = 9*N;
  point_ext = xmalloc( 2*Next * sizeof(double) );
  for(i=0; i<9; i++)
    for(j=0; j<N; j++)
      {
        point_ext[i*2*N + 2*j + 0] = Xsign[i] * point[2*j + 0] + X*Xoffset[i];
        point_ext[i*2*N + 2*j + 1] = Ysign[i] * point[2*j + 1] + Y*Yoffset[i];
      }

  /* find all meaningful alignments */
  align = find_alignments(point_ext,N,Next,&Na,X,Y);

  /* reduce redundancy */
  if( Na>=1 ) align_m = masking(point_ext,N,Next,align,Na,&Nm,X,Y);

  /* free memory */
  free( (void *) align );
  free( (void *) point_ext );

  /* result */
  if( Na>=1 && Nm>=1 )
    {
      *Nout = Nm;
      return align_m;
    }

  /* no detection */
  *Nout = 0;
  return NULL;
}
/*----------------------------------------------------------------------------*/

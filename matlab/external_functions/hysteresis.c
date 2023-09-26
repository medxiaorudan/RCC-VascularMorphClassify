/*=================================================================
 *
 * hysteresis.c
 *
 * The calling syntax is:
 *
 *		[yp] = yprime(t, y)
 *
 *  You may also want to look at the corresponding M-code, yprime.m.
 *
 * This is a MEX-file for MATLAB.
 * Copyright 1984-2000 The MathWorks, Inc.
 *
 *=================================================================*/
/* $Revision: 1.00 $ */
#include <math.h>
#include "mex.h"

#if !defined(TRUE)
#define	TRUE 1
#endif

#if !defined(FALSE)
#define	FALSE	0
#endif


void mexFunction( int nlhs, mxArray *plhs[],
		  int nrhs, const mxArray*prhs[] )

{
    double *in, *out, *connected;
	int w, h, size;
	double tLo, tHi;
	int i, j;
	int colIdx, nextC, prevC;

    /* Check for proper number of arguments */

	if (nrhs != 3) {
	mexErrMsgTxt("Wrong number of input arguments! 3 input arguments required.");
    } else if (nlhs > 1) {
	mexErrMsgTxt("Too many output arguments!");
    }

	h = mxGetM(prhs[0]);
    w = mxGetN(prhs[0]);
	size = w*h;
    if (!mxIsDouble(prhs[0]) || mxIsComplex(prhs[0])) {
		mexErrMsgTxt("YPRIME requires that Y be a 4 x 1 vector.");
    }

	/* Create a matrix for the return argument */
    plhs[0] = mxCreateDoubleMatrix(h, w, mxREAL);

	/* Assign pointers to the various parameters */
    out = mxGetPr( plhs[0] );

	in = mxGetPr( prhs[0] );

	tLo = mxGetScalar( prhs[1] );
	mexPrintf( "tLo = %f\n", tLo );
	tHi = mxGetScalar( prhs[2] );
	mexPrintf( "tHi = %f\n", tHi );

	i = floor( h/2.0 )-1;
	j = floor( w/2.0 )-1;
	/*mexPrintf( "i, j, idx, Value: %d, %d, %d, %f\n", i, j, j*h+i, in[j*h+i] ); */

	connected = (double*)mxCalloc( w*h, sizeof(double) );

	/* memcpy( connected, in, size*sizeof(double) );
	memcpy( out, in, size*sizeof(double) ); */

	mexPrintf( "First thresholding pass\n" );
	for( i=0; i<size; ++i  )
	{
		if( connected[i] < tLo )
		{
			connected[i] = FALSE;
			out[i] = FALSE;
		}
		else if( connected[i] > tHi )
		{
			connected[i] = TRUE;
			out[i] = TRUE;
		}
	}


	mexPrintf( "Forwards propagation pass\n" );
	/* First to w-1 columns */
	for( i=0; i<w-1; ++i )
	{
		colIdx = i*h;
		nextC = colIdx+h;
		/* First to h-1 pixels in column */
		for( j=0; j<h-1; ++j )
			if( connected[colIdx+j] == 1 )
			{
				/* Next pixel in column */
				if( connected[colIdx+j+1] > 0 )
					out[colIdx+j+1] = TRUE;
				/* Adjacent pixel in next column */
				if( connected[nextC+j] > 0 )
					out[nextC+j] = TRUE;
			}
	}

	mexPrintf( "Backwards propagation pass\n" );
	/* Last to second columns */
	for( i=w-1; i>0; --i )
	{
		colIdx = i*h;
		prevC = colIdx-h;
		/* Last to second pixels in column */
		for( j=h; j>0; --j )
			if( connected[colIdx+j] == TRUE )
			{
				/* Prev pixel in column */
				if( connected[colIdx+j-1] > 0 )
					out[colIdx+j-1] = TRUE;
				/* Adjacent pixel in next column */
				if( connected[prevC+j] > 0 )
					out[prevC+j] = TRUE;
			}
	}

	for( i=0; i<size; ++i  )
	{
		if( out[i] > 0 && out[i] < 1  )
		{
			out[i] = FALSE;
		}
	}

	mxFree( connected );

    return;
}

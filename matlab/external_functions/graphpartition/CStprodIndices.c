/* mex -largeArrayDims COPTIMFLAGS="-Ofast -DNDEBUG" CFLAGS="\$CFLAGS -Wall" CStprodIndices.c */

#include "mex.h"
#include "math.h"
#include <string.h>
#include <stdint.h>
#include <pthread.h>

extern void CStprodIndices_raw(
   /* inputs */
   uint64_t *memory,
   uint32_t *Xdim,
   uint64_t *XfirstSubscripts,
   uint64_t *XlastSubscripts,
   uint32_t *tprodInd,
   uint64_t *tprodSizes,
   uint64_t *Ysubscripts,
   uint64_t *Xindices,
   uint64_t *Yindices,
   uint64_t *counts,
   uint64_t *XcurrentSubscripts,
   uint64_t *YScurrentSubscripts
   /* outputs */,
   uint64_t *Ynnz,
   uint64_t *YSnnz
   /* sizes */,
   mwSize nMem,
   mwSize nX,
   mwSize nN,
   mwSize nYS,
   mwSize nY,
   mwSize nSub,
   mwSize nInd);

void mexFunction( int nlhs, mxArray *plhs[],
                  int nrhs, const mxArray *prhs[])
{
   /* inputs */
   uint64_t *memory;
   uint32_t *Xdim;
   uint64_t *XfirstSubscripts;
   uint64_t *XlastSubscripts;
   uint32_t *tprodInd;
   uint64_t *tprodSizes;
   uint64_t *Ysubscripts;
   uint64_t *Xindices;
   uint64_t *Yindices;
   uint64_t *counts;
   uint64_t *XcurrentSubscripts;
   uint64_t *YScurrentSubscripts;
   /* outputs */
   uint64_t *Ynnz;
   uint64_t *YSnnz;
   /* sizes */
   mwSize nMem;
   mwSize nX;
   mwSize nN;
   mwSize nYS;
   mwSize nY;
   mwSize nSub;
   mwSize nInd;

   /* Process inputs */

   /* Check # inputs */
   if(nrhs!=12) {
      mexErrMsgIdAndTxt("CStprodIndices:nrhs", "12 inputs required, %d found.",nrhs);
      return; }

   /* input memory */
   nMem=mxGetM(prhs[0]);
   if (mxGetN(prhs[0])!=1)
       mexErrMsgIdAndTxt("CStprodIndices:prhs","input 1 (memory) should have %d (=1) cols, %d found.",1,mxGetN(prhs[0]));
   if (!mxIsUint64(prhs[0]))
       mexErrMsgIdAndTxt("CStprodIndices:prhs","input 1 (memory) should have type uint64");
   memory=mxGetData(prhs[0]);
   /* input Xdim */
   nX=mxGetM(prhs[1]);
   if (mxGetN(prhs[1])!=1)
       mexErrMsgIdAndTxt("CStprodIndices:prhs","input 2 (Xdim) should have %d (=1) cols, %d found.",1,mxGetN(prhs[1]));
   if (!mxIsUint32(prhs[1]))
       mexErrMsgIdAndTxt("CStprodIndices:prhs","input 2 (Xdim) should have type uint32");
   Xdim=mxGetData(prhs[1]);
   /* input XfirstSubscripts */
   if (mxGetM(prhs[2])!=nX)
       mexErrMsgIdAndTxt("CStprodIndices:prhs","input 3 (XfirstSubscripts) should have %d (=nX) rows, %d found.",nX,mxGetM(prhs[2]));
   if (mxGetN(prhs[2])!=1)
       mexErrMsgIdAndTxt("CStprodIndices:prhs","input 3 (XfirstSubscripts) should have %d (=1) cols, %d found.",1,mxGetN(prhs[2]));
   if (!mxIsUint64(prhs[2]))
       mexErrMsgIdAndTxt("CStprodIndices:prhs","input 3 (XfirstSubscripts) should have type uint64");
   XfirstSubscripts=mxGetData(prhs[2]);
   /* input XlastSubscripts */
   if (mxGetM(prhs[3])!=nX)
       mexErrMsgIdAndTxt("CStprodIndices:prhs","input 4 (XlastSubscripts) should have %d (=nX) rows, %d found.",nX,mxGetM(prhs[3]));
   if (mxGetN(prhs[3])!=1)
       mexErrMsgIdAndTxt("CStprodIndices:prhs","input 4 (XlastSubscripts) should have %d (=1) cols, %d found.",1,mxGetN(prhs[3]));
   if (!mxIsUint64(prhs[3]))
       mexErrMsgIdAndTxt("CStprodIndices:prhs","input 4 (XlastSubscripts) should have type uint64");
   XlastSubscripts=mxGetData(prhs[3]);
   /* input tprodInd */
   nN=mxGetM(prhs[4]);
   if (mxGetN(prhs[4])!=1)
       mexErrMsgIdAndTxt("CStprodIndices:prhs","input 5 (tprodInd) should have %d (=1) cols, %d found.",1,mxGetN(prhs[4]));
   if (!mxIsUint32(prhs[4]))
       mexErrMsgIdAndTxt("CStprodIndices:prhs","input 5 (tprodInd) should have type uint32");
   tprodInd=mxGetData(prhs[4]);
   /* input tprodSizes */
   nYS=mxGetM(prhs[5]);
   if (mxGetN(prhs[5])!=1)
       mexErrMsgIdAndTxt("CStprodIndices:prhs","input 6 (tprodSizes) should have %d (=1) cols, %d found.",1,mxGetN(prhs[5]));
   if (!mxIsUint64(prhs[5]))
       mexErrMsgIdAndTxt("CStprodIndices:prhs","input 6 (tprodSizes) should have type uint64");
   tprodSizes=mxGetData(prhs[5]);
   /* input Ysubscripts */
   nY=mxGetM(prhs[6]);
   nSub=mxGetN(prhs[6]);
   if (!mxIsUint64(prhs[6]))
       mexErrMsgIdAndTxt("CStprodIndices:prhs","input 7 (Ysubscripts) should have type uint64");
   Ysubscripts=mxGetData(prhs[6]);
   /* input Xindices */
   if (mxGetM(prhs[7])!=nX)
       mexErrMsgIdAndTxt("CStprodIndices:prhs","input 8 (Xindices) should have %d (=nX) rows, %d found.",nX,mxGetM(prhs[7]));
   nInd=mxGetN(prhs[7]);
   if (!mxIsUint64(prhs[7]))
       mexErrMsgIdAndTxt("CStprodIndices:prhs","input 8 (Xindices) should have type uint64");
   Xindices=mxGetData(prhs[7]);
   /* input Yindices */
   if (mxGetM(prhs[8])!=nInd)
       mexErrMsgIdAndTxt("CStprodIndices:prhs","input 9 (Yindices) should have %d (=nInd) rows, %d found.",nInd,mxGetM(prhs[8]));
   if (mxGetN(prhs[8])!=1)
       mexErrMsgIdAndTxt("CStprodIndices:prhs","input 9 (Yindices) should have %d (=1) cols, %d found.",1,mxGetN(prhs[8]));
   if (!mxIsUint64(prhs[8]))
       mexErrMsgIdAndTxt("CStprodIndices:prhs","input 9 (Yindices) should have type uint64");
   Yindices=mxGetData(prhs[8]);
   /* input counts */
   if (mxGetM(prhs[9])!=nInd)
       mexErrMsgIdAndTxt("CStprodIndices:prhs","input 10 (counts) should have %d (=nInd) rows, %d found.",nInd,mxGetM(prhs[9]));
   if (mxGetN(prhs[9])!=1)
       mexErrMsgIdAndTxt("CStprodIndices:prhs","input 10 (counts) should have %d (=1) cols, %d found.",1,mxGetN(prhs[9]));
   if (!mxIsUint64(prhs[9]))
       mexErrMsgIdAndTxt("CStprodIndices:prhs","input 10 (counts) should have type uint64");
   counts=mxGetData(prhs[9]);
   /* input XcurrentSubscripts */
   if (mxGetM(prhs[10])!=nX)
       mexErrMsgIdAndTxt("CStprodIndices:prhs","input 11 (XcurrentSubscripts) should have %d (=nX) rows, %d found.",nX,mxGetM(prhs[10]));
   if (mxGetN(prhs[10])!=1)
       mexErrMsgIdAndTxt("CStprodIndices:prhs","input 11 (XcurrentSubscripts) should have %d (=1) cols, %d found.",1,mxGetN(prhs[10]));
   if (!mxIsUint64(prhs[10]))
       mexErrMsgIdAndTxt("CStprodIndices:prhs","input 11 (XcurrentSubscripts) should have type uint64");
   XcurrentSubscripts=mxGetData(prhs[10]);
   /* input YScurrentSubscripts */
   if (mxGetM(prhs[11])!=nYS)
       mexErrMsgIdAndTxt("CStprodIndices:prhs","input 12 (YScurrentSubscripts) should have %d (=nYS) rows, %d found.",nYS,mxGetM(prhs[11]));
   if (mxGetN(prhs[11])!=1)
       mexErrMsgIdAndTxt("CStprodIndices:prhs","input 12 (YScurrentSubscripts) should have %d (=1) cols, %d found.",1,mxGetN(prhs[11]));
   if (!mxIsUint64(prhs[11]))
       mexErrMsgIdAndTxt("CStprodIndices:prhs","input 12 (YScurrentSubscripts) should have type uint64");
   YScurrentSubscripts=mxGetData(prhs[11]);

   /* Process outputs */

   /* Check # outputs */
   if(nlhs!=2) {
      mexErrMsgIdAndTxt("CStprodIndices:nrhs", "2 outputs required, %d found.",nlhs);
      return; }

   /* output Ynnz */
   { mwSize dims[]={1,1};
     plhs[0] = mxCreateNumericArray(2,dims,mxUINT64_CLASS,mxREAL);
     Ynnz=mxGetData(plhs[0]); }
   /* output YSnnz */
   { mwSize dims[]={1,1};
     plhs[1] = mxCreateNumericArray(2,dims,mxUINT64_CLASS,mxREAL);
     YSnnz=mxGetData(plhs[1]); }

   /* Call function */
#if 1
   CStprodIndices_raw(memory, Xdim, XfirstSubscripts, XlastSubscripts, tprodInd, tprodSizes, Ysubscripts, Xindices, Yindices, counts, XcurrentSubscripts, YScurrentSubscripts, Ynnz, YSnnz, nMem, nX, nN, nYS, nY, nSub, nInd);
#endif

}
#if 1
#include "CStprodIndices_raw.c"
#endif


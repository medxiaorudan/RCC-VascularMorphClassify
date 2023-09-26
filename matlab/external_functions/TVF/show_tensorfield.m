function show_tensorfield( T )
%SHOW_TENSORFIELD displays in a new figure the tensor field
%   supplied.
%
%   T is a MxMx2x2 tensor field, the field is displayed in a
%   new figure.
%
%   Returns nothing
%
    [e1,e2,l1,l2] = TL_calc_tensor_to_ev(T);
    h = size(e1,1);
    w = size(e1,2);
    wh = (h-1)/2;
    ww = (w-1)/2;
    [x,y] = meshgrid(-ww:1:ww,wh:-1:-wh);
    figure,quiver(x,y,e1(:,:,1).*l1,e1(:,:,2).*l1);
end
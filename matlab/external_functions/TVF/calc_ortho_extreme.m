function [ re ] = calc_ortho_extreme( T,r,epsilon )
%CALC_ORTHO_EXTREME examines the orthogonal or "normal" on the curve
%   and finds the maxima along the line. R is the length to check
%   along the normal axis. Epsilon is the width in radians to check, 
%   i.e. pi/8
%
    [e1,e2,l1,l2] = convert_tensor_ev(T);
    q = l1-l2;
    [h w] = size(l1);
    re = zeros(h,w,'double');
    
    
    [X,Y] = meshgrid(-r:1:r,-r:1:r);
    t = atan2(Y,X);
    l = sqrt(X.^2 + Y.^2);
    q1 = zeros(2*r+h, 2*r+w);
    q1((r+1):(h+r), (r+1):(w+r)) = q;
    D = find(q1>0);
    [h w] = size(q1);
    
    for i=1:size(D,1)
        [y,x] = ind2sub(h, D(i));
        X2 = l.*cos(t + atan2(e1(y-r,x-r,2),e1(y-r,x-r,1)));
        Y2 = l.*sin(t + atan2(e1(y-r,x-r,2),e1(y-r,x-r,1)));
        t2 = abs(atan2(Y2,X2));
        t2(t2 > pi/2) = pi - t2(t2 > pi/2);
        
        t2(t2 <= epsilon) = 1;
        t2(t2 ~= 1) = 0;
        t2(l > r) = 0;
        
        z = q1((y-r):(y+r),(x-r):(x+r)).*t2;
        z = max(z > q1(y,x));
        if max(z(:)) == 0
            re(y-r,x-r) = 1;
        end
    end
end
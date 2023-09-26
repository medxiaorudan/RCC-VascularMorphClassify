function [ T ] = read_dot_edge_file( filen )
%READ_DOT_EDGE_FILE reads in the file and outputs a tensor
%   field based on the edge input.  
%
    fid = fopen(filen);
    n = fgets(fid);
    n = str2num(n);
    buf = zeros(n,3,'double');
    for i=1:n
        z = fgets(fid);
        if z ~= -1
            [q,r] = strtok(z);
            buf(i,1) = str2num(q);
            [q,r] = strtok(r);
            buf(i,2) = str2num(strtok(q));
            [q,r] = strtok(r);
            buf(i,3) = str2double(strtok(q));
        else
            fprintf('blank line found\n');
        end
    end
    h = max(buf(:,1));
    w = max(buf(:,2));
    
    T = zeros(h,w,2,2);
    
    for i=1:n
        x = cos(buf(i,3)*pi/180 + 90*pi/180);
        y = sin(buf(i,3)*pi/180 + 90*pi/180);
        T(h+1-buf(i,1),buf(i,2),1,1) = x^2;
        T(h+1-buf(i,1),buf(i,2),1,2) = x*y;
        T(h+1-buf(i,1),buf(i,2),2,1) = x*y;
        T(h+1-buf(i,1),buf(i,2),2,2) = y^2;
    end
end
function ov = overlay_binary(img, binary, edge)
    ov = zeros(size(img));
    
    if ndims(img) == 2
        if edge
            binimg = (binary - imerode(binary,ones(3,3))) > 0;
        else
            binimg = binary;
        end
        img_temp = img;
        img_temp(binimg) = 0;
        ov(:,:,1) = img_temp + binimg;
        ov(:,:,2) = img_temp;
        ov(:,:,3) = img_temp;
    else
        if edge
            binimg = (binary - imerode(binary,ones(3,3,3))) > 0;
        else
            binimg = binary;
        end
        
        img_temp = img;
        a = img_temp(:,:,1);
        a(binimg) = 0;
        
        b = img_temp(:,:,2);
        b(binimg) = 0;
        
        c = img_temp(:,:,3);
        c(binimg) = 0;
        
        ov(:,:,1) = a;
        ov(:,:,2) = b + binimg;
        ov(:,:,3) = c + binimg;
        
    end
end
        
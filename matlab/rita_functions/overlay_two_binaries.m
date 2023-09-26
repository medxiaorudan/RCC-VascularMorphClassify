function ov = overlay_two_binaries(img, binary1, binary2, edges12)
    ov = zeros(size(img));
    edge1 = edges12(1); edge2 = edges12(2);
    if ndims(img) == 2
        if edge1
            binimg1 = (binary1 - imerode(binary1,ones(3,3))) > 0;
        else
            binimg1 = binary1;
        end
        if edge2
            binimg2 = (binary2 - imerode(binary2,ones(3,3))) > 0;
        else
            binimg2 = binary2;
        end
        img_temp = img;
        img_temp(binimg1) = 0;
        img_temp(binimg2) = 0;
        ov(:,:,1) = img_temp + binimg1;
        ov(:,:,2) = img_temp;
        ov(:,:,3) = img_temp + binimg2;
    else
        if edge1
            binimg1 = (binary1 - imerode(binary1,ones(3,3,3))) > 0;
        else
            binimg1 = binary1;
        end
        if edge2
            binimg2 = (binary2 - imerode(binary2,ones(3,3,3))) > 0;
        else
            binimg2 = binary2;
        end
        
        img_temp = img;
        a = img_temp(:,:,1);
        a(binimg1) = 0;
        a(binimg2) = 0;
        
        b = img_temp(:,:,2);
        b(binimg1) = 0;
        b(binimg2) = 0;
        
        c = img_temp(:,:,3);
        c(binimg1) = 0;
        c(binimg2) = 0;
        
        ov(:,:,1) = a + binimg1;
        ov(:,:,2) = b + binimg1;
        ov(:,:,3) = c + binimg2;
        
    end
end
        
function ov = overlay(img, binary, c)

ov1 = img(:, :, 1);
ov2 = img(:, :, 2);
ov3 = img(:, :, 3);

ov1(binary) = c(1);
ov2(binary) = c(2);
ov3(binary) = c(3);

ov = zeros(size(img));
ov(:, :, 1) = ov1;
ov(:, :, 2) = ov2;
ov(:, :, 3) = ov3;
    
end
        
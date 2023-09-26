function resc = rescale01(img)
    resc = (img - min(img(:))) / (max(img(:)) - min(img(:)));

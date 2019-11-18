function dist = ssd_image_distance(img_1, img_2)
    diff = int8(img_1) - int8(img_2);
    dist = sum(diff(:).^2);
end
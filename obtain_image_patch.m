
function [valid, image_patch] = obtain_image_patch(row, col, patch_width, image)
    valid       = false;
    image_patch = [];
    [height, width, d] = size(image);

    start_col   = col - patch_width;
    start_row   = row - patch_width;
    end_col     = start_col + patch_width * 2;
    end_row     = start_row + patch_width * 2;

    if (start_col > 0) && (start_row > 0) && ...
       (end_col < width) && (end_row < height)
        valid       = true;
        image_patch = image(start_row : end_row, start_col : end_col, :);
    end
end
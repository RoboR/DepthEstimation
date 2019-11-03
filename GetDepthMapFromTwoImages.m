function [depth_map] = GetDepthMapFromTwoImages(left_image, right_image, patch_size)
    RIGHT_IMG_STEP  = 5;
    SEARCH_DIST     = 200;
    MAX_DEPTH       = SEARCH_DIST;

    [height, width, z]  = size(left_image);
    depth_map           = ones([height, width, 1], 'uint8');
    patch_width         = floor(patch_size / 2);

    for left_row = 1 : height
        for left_col = 1 : width
            % Obtain left image patch
            [valid_left, left_patch] = obtain_image_patch(left_row, left_col, patch_width, left_image);

            if valid_left == false
                continue
            end

            % Obtain right image patch
            min_img_dist    = intmax;
            min_right_col   = left_col;
            right_start     = max(0, left_col - SEARCH_DIST / 2);
            right_end       = min(width, left_col + SEARCH_DIST / 2);
            right_row       = left_row;

            for right_col = right_start : RIGHT_IMG_STEP : right_end
                [valid_right, right_patch] = obtain_image_patch(right_row, right_col, patch_width, right_image);
                    if valid_right == true
                        dist = ssd_image_distance(left_patch, right_patch);
                        if dist < min_img_dist
                            min_img_dist    = dist;
                            min_right_col   = right_col;
                        end
                    end
            end

            depth = int8(abs(min_right_col - left_col) / MAX_DEPTH * 255);
            depth_map(left_row, left_col) = depth;
        end
    end

    % Pad missing sides
    for row = 1 : patch_width
        depth_map(row, 1 : width)           = depth_map(patch_width + 1, 1 : width);
        depth_map(height - row, 1 : width)  = depth_map(height - patch_width - 1, 1 : width);
    end
    for col = 1 : patch_width
        depth_map(1 : height, col)          = depth_map(1 : height, patch_width + 1);
        depth_map(1 : height, width - col)  = depth_map(1 : height, width - patch_width - 1);
    end
end


function dist = ssd_image_distance(img_1, img_2)
    diff = int8(img_1) - int8(img_2);
    dist = sum(diff(:).^2);
end

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
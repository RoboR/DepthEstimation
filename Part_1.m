clc;
clear;
addpath(genpath('./GCMex'))

FG_COLOR            = uint8([0; 0; 255]);        % blue
BG_COLOR            = uint8([245; 210; 110]);    % yellow
PRIOR_SMOOTHNESS    = 50;
DATA_SMOOTHNESS     = 200;


raw_image                   = imread("input/bayes_in.jpg");
[height, width, z]          = size(raw_image);
nodes_n                     = width * height;
segclass                    = zeros(nodes_n, 1);
pairwise                    = sparse(nodes_n, nodes_n);
depthMax                    = 2; % binary
unary                       = zeros(depthMax, nodes_n);
[X, Y]                      = meshgrid(0 : depthMax - 1, 0 : depthMax - 1);
labelcost                   = (X - Y) .* (X - Y);

for row = 0 : height - 1
    for col = 0 : width - 1
        node_idx    = 1 + row * width + col;
        value_d     = raw_image(row + 1, col + 1, :);
                
        % right neighbour
        if (col + 2) <= width            
            right_val   = raw_image((row + 1), (col + 1 + 1), :);
            right_dist  = pixel_distance_func(value_d(:), right_val(:));
            prior_right  = 1;
            if (right_dist < PRIOR_SMOOTHNESS)
                prior_right = 0;
            end
            pairwise(node_idx, (col + 2) + row * width) = prior_right;
        end

        % bottom neightbour
        if row + 2 <= height 
            bottom_val   = raw_image((row + 1 + 1), (col + 1), :);
            bottom_dist  = pixel_distance_func(value_d(:), bottom_val(:));
            prior_bottom = 1;
            if (bottom_dist < PRIOR_SMOOTHNESS)
                prior_bottom = 0;
            end
            pairwise(node_idx, (col + 1) + (row + 1) * width) = prior_bottom;
        end
        
        % top neighbour
        if row > 0
            top_val   = raw_image((row + 1 -1), (col + 1), :);
            top_dist  = pixel_distance_func(value_d(:), top_val(:));
            prior_top = 1;
            if (top_dist < PRIOR_SMOOTHNESS)
                prior_top = 0;
            end
            pairwise(node_idx, 1 + col + (row - 1) * width) = prior_top;
        end

        % left neighbour
        if col > 0
            left_val   = raw_image((row + 1), (col + 1 -1), :);
            left_dist  = pixel_distance_func(value_d(:), left_val(:));
            prior_left = 1;
            if (left_dist < PRIOR_SMOOTHNESS)
                prior_left = 0;
            end
            pairwise(node_idx, col + row * width) = prior_left;
        end

        fg_d = pixel_distance_func(value_d(:), FG_COLOR);
        if (fg_d < DATA_SMOOTHNESS)
            unary(:, node_idx) = [1 0]';
        else
            unary(:, node_idx) = [0 1]';
        end

    end
end

[labels E Eafter] = GCMex(segclass, single(unary), pairwise, single(labelcost), 0);

% Denoise the image based on labels is 0 (background) or 1(foreground)
filter_image = zeros([height, width, z], 'uint8');
for row = 0 : height - 1
    for col = 0 : width - 1
        node_idx       = 1 + row * width + col;
        pixel_val   =  BG_COLOR;
        if labels(node_idx) == 1
            pixel_val = FG_COLOR;
        end
        
        filter_image(row+1, col+1, :) = pixel_val;
    end
end

subplot(1,2,1), imshow(raw_image), title("Raw Image");
subplot(1,2,2), imshow(filter_image), title("Filter Image");


function dist = pixel_distance_func(pixel_1, pixel_2)
    [r, h, d]   = size(pixel_1);
    pixel_diff  = int8(pixel_1) - int8(pixel_2);
    dist        = sum(abs(pixel_diff));
end
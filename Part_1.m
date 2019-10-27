clc;
clear;
addpath(genpath('./GCMex'))

SOURCE_COLOR    = uint8([0; 0; 255]);        % blue
SINK_COLOR      = uint8([245; 210; 110]);    % yellow
PRIOR_SMOOTHNESS = 200;
DATA_SMOOTHNESS = 50;

raw_image                   = imread("input/bayes_in.jpg");
% raw_image                   = imread("input/Untitled.jpg");
[height_h, width_w, z]      = size(raw_image);
nodes_n                     = width_w * height_h;
segclass                    = zeros(nodes_n, 1);
pairwise                    = sparse(nodes_n, nodes_n);
data_term_n                 = 2; % binary
unary                       = zeros(data_term_n, nodes_n);
[X, Y]                      = meshgrid(1:data_term_n, 1:data_term_n);
labelcost                   = min(4, (X - Y) .* (X - Y));


for row = 0 : height_h - 1
    for col = 0 : width_w - 1
        pixel   = 1 + row * width_w + col;
        value_d = raw_image(row + 1, col + 1, :);
                
        % right neighbour
        if (col + 1) < width_w            
            right_val   = raw_image((row + 1), (col + 1 + 1), :);
            right_dist  = pixel_distance_func(value_d(:), right_val(:));
            if (right_dist < DATA_SMOOTHNESS)
                pairwise(pixel, (1 + col + 1) + row * width_w) = 1; 
            end
        end

        % bottom neightbour
        if row + 1 < height_h 
            bottom_val   = raw_image((row + 1 + 1), (col + 1), :);
            bottom_dist  = pixel_distance_func(value_d(:), bottom_val(:));
            if (bottom_dist < DATA_SMOOTHNESS)
                pairwise(pixel, (1 + col) + (row + 1) * width_w) = 1; 
            end
        end
        
        if row-1 >= 0, pairwise(pixel, 1+col+(row-1)*width_w) = 1; end 
        if col-1 >= 0, pairwise(pixel, 1+(col-1)+row*width_w) = 1; end 

        % foreground
        fg_d = pixel_distance_func(value_d(:), SOURCE_COLOR);        
        if (fg_d > PRIOR_SMOOTHNESS)
            unary(:, pixel) = [0 1]';
        else
            unary(:, pixel) = [1 0]';
        end

    end
end

[labels E Eafter] = GCMex(segclass, single(unary), pairwise, single(labelcost), 0);

% Denoise the image based on labels is 0 (background) or 1(foreground)
filter_image = zeros([height_h, width_w, z], 'uint8');
for row = 0 : height_h - 1
    for col = 0 : width_w - 1
        pixel       = 1 + row * width_w + col;
        pixel_val   =  SINK_COLOR;
        if labels(pixel) == 1
            pixel_val = SOURCE_COLOR;
        end
        
        filter_image(row+1, col+1, :) = pixel_val;
    end
end

subplot(1,2,1), imshow(raw_image), title("Raw Image");
subplot(1,2,2), imshow(filter_image), title("Filter Image");


function dist = pixel_distance_func(pixel_1, pixel_2)
    [r, h, d]   = size(pixel_1);
    pixel_diff  = int8(pixel_1) - int8(pixel_2);
    dist        = sum(abs(pixel_diff)) / d;
end
clc;
clear;
format long g
% 
% left_image  = imread("input/test00.jpg");
% right_image = imread("input/test09.jpg");

left_image  = imread("input/00.jpg");
right_image = imread("input/09.jpg");

cal_1       = camera_calibration(1);
K1          = cal_1.K;
R1          = cal_1.R;
T1          = cal_1.T;
cal_2       = camera_calibration(2);
K2          = cal_1.K;
R2          = cal_2.R;
T2          = cal_2.T;
C1          = -transpose(R1) * T1;
C2          = -transpose(R2) * T2;
  
alpha       = K2 * R2 * transpose(R1) * inv(K1);
beta        = K2 * R2 * (C1 - C2);


D_TOTAL = 500;
D_STEP = 1;

[height, width, z]  = size(left_image);
nodes_num           = width * height;
segclass            = zeros(nodes_num, 1);
pairwise            = sparse(nodes_num, nodes_num);
unary               = zeros(D_TOTAL, nodes_num);
[X, Y]              = meshgrid(0 : D_TOTAL - 1, 0 : D_TOTAL - 1);
LAMBDA              = 1 / (D_TOTAL * D_TOTAL);  % a value
labelcost           = floor(LAMBDA * ((X - Y) .* (X - Y)));

left_gray           = int8(rgb2gray(left_image));
right_gray          = int8(rgb2gray(right_image));

for row = 0 : height - 1
    for col = 0 : width - 1
        node_idx        = 1 + row * width + col;        
        left_img_pos    = [col row 1]';
        left_img_val    = (left_gray(row + 1, col + 1, :));

        for d =  0 : D_STEP : D_TOTAL - 1
            x_prime         = alpha * left_img_pos + 1 / (d * D_STEP) * beta;
            right_img_pos   = floor(x_prime / x_prime(3));
            right_x         = right_img_pos(1);
            right_y         = right_img_pos(2);
            data_term       = 200000;

            if right_x > 0 && right_x < width && right_y > 0 && right_y < height
                right_img_val   = (right_gray(right_y, right_x, :));
                data_term       = ((left_img_val - right_img_val) + d)^2;
            end
            unary(d + 1, node_idx) = data_term;
        end

        % right neighbour
        if (col + 2) <= width
            pairwise(node_idx, (col + 2) + row * width) = 1;
        end
        % bottom neightbour
        if row + 2 <= height
            pairwise(node_idx, (col + 1) + (row + 1) * width) = 1;
        end
        % top neighbour
        if row > 0
            pairwise(node_idx, 1 + col + (row - 1) * width) = 1;
        end
        % left neighbour
        if col > 0
            pairwise(node_idx, col + row * width) = 1;
        end
    end
end

[labels E Eafter] = GCMex(segclass, single(unary), pairwise, single(labelcost), 0);

depth_image = zeros([height, width, 1], 'uint8');
for row = 0 : height - 1
    for col = 0 : width - 1
        node_idx = 1 + row * width + col;
        depth_image(row + 1, col + 1) = labels(node_idx) / (D_TOTAL) * 255;
    end
end


subplot(3,3,1), imshow(left_image), title("Left Image");
subplot(3,3,2), imshow(right_image), title("Right Image");

subplot(3,3,4), imshow(depth_image), title("Depth Image");;
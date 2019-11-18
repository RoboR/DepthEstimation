function [depth_image] = GetDepthFromRectifyImageMRF(left_image, right_image, D_MAX)
    img_diff            = int8(rgb2gray(left_image)) - int8(rgb2gray(right_image));
    [height, width, z]  = size(img_diff);
    nodes_num           = width * height;
    segclass            = zeros(nodes_num, 1);
    pairwise            = sparse(nodes_num, nodes_num);
    unary               = zeros(D_MAX, nodes_num);
    [X, Y]              = meshgrid(0 : D_MAX - 1, 0 : D_MAX - 1);
    LAMBDA              = 1 / (D_MAX * D_MAX);  % a value
    labelcost           = floor(LAMBDA * ((X - Y) .* (X - Y)));
    

    for row = 0 : height - 1
        for col = 0 : width - 1
            node_idx    = 1 + row * width + col;
            diff_val    = img_diff(row + 1, col + 1);

            for d = 0 : D_MAX - 1
                data_term = (diff_val + d)^2;
                unary(d + 1, node_idx) = data_term;
            end

            % right neighbour
            if (col + 2) <= width
                pairwise(node_idx, (col + 2) + row * width) = 1;
            end
            % bottom neightbour
            if row + 2 <= height
                pairwise(node_idx, (col + 1) + (row + 1) * width) = 1;;
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
            depth_image(row + 1, col + 1) = labels(node_idx) / D_MAX * 255;
        end
    end
end

clc;
clear;

image_left  = imread("input/im2.png");
image_right = imread("input/im6.png");

depth_patch_5   = GetDepthMapFromTwoImages(image_left, image_right, 5);
depth_patch_25  = GetDepthMapFromTwoImages(image_left, image_right, 25);
depth_patch_50  = GetDepthMapFromTwoImages(image_left, image_right, 30);

subplot(3,1,1), imshow(depth_patch_5), title("Depth Image: patch 5");
subplot(3,1,2), imshow(depth_patch_25), title("Depth Image: patch 25");
subplot(3,1,3), imshow(depth_patch_50), title("Depth Image: patch 50");
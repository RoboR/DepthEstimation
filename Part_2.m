clc;
clear;
addpath(genpath('./GCMex'))
 
left_image          = imread("input/im2.png");
right_image         = imread("input/im6.png");

depth_patch_5   = GetDepthMapFromRectifyImages(left_image, right_image, 5);
depth_patch_25  = GetDepthMapFromRectifyImages(left_image, right_image, 25);
depth_patch_50  = GetDepthMapFromRectifyImages(left_image, right_image, 30);

depth_mrf_25    = GetDepthFromRectifyImageMRF(left_image, right_image, 25);
depth_mrf_50    = GetDepthFromRectifyImageMRF(left_image, right_image, 50);
depth_mrf_100   = GetDepthFromRectifyImageMRF(left_image, right_image, 100);


subplot(3,3,1), imshow(left_image), title("Left Image");
subplot(3,3,2), imshow(right_image), title("Right Image");

subplot(3,3,4), imshow(depth_patch_5), title("Depth Image from patch size : 5");
subplot(3,3,5), imshow(depth_patch_25), title("Depth Image from patch size : 25");
subplot(3,3,6), imshow(depth_patch_50), title("Depth Image from patch size : 50");

subplot(3,3,7), imshow(depth_mrf_25), title("Depth Image from MRF : 25 dMax");
subplot(3,3,8), imshow(depth_mrf_50), title("Depth Image from MRF : 50 dMax");
subplot(3,3,9), imshow(depth_mrf_100), title("Depth Image from MRF : 100 dMax");

clc;clear;
img=imread('8.jpg');
img_hsv = rgb2hsv(img);
array2 = (img_hsv(:,:,1) > 0.075);
array3 = (img_hsv(:,:,1) < 0.115);
result = array2 .* array3;
img_filtered = medfilt2(result, [10 10]);
figure(1);
imshow(img_filtered);
figure(2);
imshow(result);
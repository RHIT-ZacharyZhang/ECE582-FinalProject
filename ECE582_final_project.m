clc;clear;close all;

%clarify variables 

detect_roof_confidence = 0;   %range 0 - 2
detect_clock_confidence = 0;             %range 0 -2
detect_the_guy_confidence = 0;           %range 0 or 3
total_confidence = 0;         %range 0 - 5, if total_confidence = 3 or 4, it is likely to 
                              %courhouse. if total_confidence>4, it is
                              %courthouse!
image_x = 1200;
image_y = 800;
color_weight = 0;


%read the image

img=imread('1.jpg');
[x_size y_size a] = size(img);
img_hsv = rgb2hsv(img);
figure(1)

%detect the color 
%imshow(img_hsv)
array2 = (img_hsv(:,:,1) > 0.09&img_hsv(:,:,2)>0.32);
array3 = (img_hsv(:,:,1) < 0.118&img_hsv(:,:,2)<0.45);
result_roof = array2 .* array3;
imshow(result_roof)
img_roof_filtered = medfilt2(result_roof, [8 8]);
figure(2);
imshow(img_roof_filtered);
%set roof flag
for x = 1:x_size
    for y = 1: y_size
        color_weight = result_roof(x,y)+color_weight;
    end
end
if(color_weight>20000)
    detect_roof_confidence = 2;
end

if(color_weight>15000&color_weight<20000)
    detect_roof_confidence = 1;
end



%detect clock
grey_pic = rgb2gray(img);
imshow(grey_pic)
[centers, radii] = imfindcircles(grey_pic,[10 80],...
    'ObjectPolarity','bright');
viscircles(centers, radii);
%set clock_confidence
if(radii>10&radii<16)
    detect_clock_confidence = 2;
end

if(radii>16&radii<20)
    detect_colock_confidence = 1
end
%detect the guy!
character_image = imread('character.jpg');
boxImage_grey = rgb2gray(character_image);
figure;
imshow(boxImage_grey);
title('Image of a Box');
figure;
imshow(grey_pic);
title('Image of a Cluttered Scene');
boxPoints = detectSURFFeatures(boxImage_grey);
scenePoints = detectSURFFeatures(grey_pic);
figure;
imshow(boxImage_grey);
title('100 Strongest Feature Points from Box Image');
hold on;
plot(selectStrongest(boxPoints, 500));
figure;
imshow(grey_pic);
title('300 Strongest Feature Points from Scene Image');
hold on;
plot(selectStrongest(scenePoints, 100));
[boxFeatures, boxPoints] = extractFeatures(boxImage_grey, boxPoints);
[sceneFeatures, scenePoints] = extractFeatures(grey_pic, scenePoints);
boxPairs = matchFeatures(boxFeatures, sceneFeatures);
%Display putatively matched features.
matchedBoxPoints = boxPoints(boxPairs(:, 1), :);
matchedScenePoints = scenePoints(boxPairs(:, 2), :);
figure;
showMatchedFeatures(boxImage_grey, grey_pic, matchedBoxPoints, ...
 matchedScenePoints, 'montage');
title('Putatively Matched Points (Including Outliers)');
[tform, inlierBoxPoints, inlierScenePoints] = ...
 estimateGeometricTransform(matchedBoxPoints, matchedScenePoints,...
 'affine');
figure;
showMatchedFeatures(boxImage_grey, grey_pic, inlierBoxPoints, ...
 inlierScenePoints, 'montage');
title('Matched Points (Inliers Only)');
boxPolygon = [1, 1;... % top-left
 size(boxImage_grey, 2), 1;... % top-right
 size(boxImage_grey, 2), size(boxImage_grey, 1);... % bottom-right
 1, size(boxImage_grey, 1);... % bottom-left
 1, 1]; % top-left again to close the polygon
newBoxPolygon = transformPointsForward(tform, boxPolygon);
figure;
imshow(grey_pic);
hold on;
line(newBoxPolygon(:, 1), newBoxPolygon(:, 2), 'Color', 'y');
title('Detected Box');



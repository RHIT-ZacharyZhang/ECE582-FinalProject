clc;clear;close all
img = imread('9.jpg');
A=rgb2gray(img);
imshow(A)
[centers, radii] = imfindcircles(A,[1 30],'ObjectPolarity','bright');
viscircles(centers, radii);
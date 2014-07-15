clc
clear all
close all

W = (1/(31*31))*ones(31);
c = 2.3;
%reads image
A=imread('01_test.tif');
imshow(A);

%Green Channel extraction
gA=A(:,:,2);
imshow(gA);

%Match-Filter Kernel for thin vessel
sThin=1;
lThin=5;
kerThin=meshgrid(-3:3,1);
kerThin=(1/sqrt(2*pi))*exp(-(kerThin.^2)/2);

syms x;
exprThin=(1/sqrt(2*pi))*exp(-(x^2)/2);
mThin=int(exprThin,-3,3)/6;

%Match-Filter Kernel for thick vessel
sThick=1.5;
lThick=9;
kerThick=meshgrid(-4:4,1);
kerThick=(1/(sqrt(2*pi)*1.5))*exp(-(kerThick.^2)/(2*1.5*1.5));
syms y;
exprThick=(1/(sqrt(2*pi)*1.5))*exp(-(y.^2)/(2*1.5*1.5));
mThin=int(exprThick,y,-4.5,4.5)/9;
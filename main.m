clc
clear all
close all
%%
W = (1/(31*31))*ones(31);
c = 2.3;
%reads image
A=imread('01_test.tif');
%A=double(A);
figure,imshow(A,[]);
%%
%Green Channel extraction
gA=A(:,:,2);
figure,imshow(gA,[]);
%%
%Match-Filter Kernel for thin vessel
sThin=1;
lThin=5;
kerThin=meshgrid(-3:3,1);
kerThin=(1/sqrt(2*pi))*exp(-(kerThin.^2)/2);

% for calculating erf values use http://www.miniwebtool.com/error-function-calculator/?number=2.1213
%syms x;
%exprThin=(1/sqrt(2*pi))*exp(-(x^2)/2);
%mThin=int(exprThin,-3,3)/6; (7186705221432913*2^(1/2)*pi^(1/2)*erf((3*2^(1/2))/2))/108086391056891904
%erf((3*2^(1/2))/2)=0.9972999
mThin= 0.1662;
kerThin=kerThin-mThin;
% l=5
kerThin=repmat(kerThin,[5 1]);
%we got the kernel now we filter it in 8 directions
thinFilterimg=zeros(size(gA,1),size(gA,2),8);
for i=1:8
    MaskKerthin=imrotate(kerThin,(i-1)*45,'bicubic','crop');
    thinFilterimg(:,:,i)= imfilter(gA,MaskKerthin);
end
finalThin=max(thinFilterimg,[],3);
figure,imshow(finalThin,[]);
%%
uhThin=mean(mean(finalThin));


%Match-Filter Kernel for thick vessel
sThick=1.5;
lThick=9;
kerThick=meshgrid(-4:4,1);
kerThick=(1/(sqrt(2*pi)*1.5))*exp(-(kerThick.^2)/(4.5));
%syms y;
%exprThick=(1/(sqrt(2*pi)*1.5))*exp(-(y^2)/(4.5)); (4791136814288609*2^(1/2)*pi^(1/2)*0.9972999)/108086391056891904
%erf((3*2^(1/2))/2)=0.9972999
%mThick=int(exprThick,-4.5,4.5)/9;
mThick=0.1108;
kerThick=kerThick-mThick;
%l=9
kerThick=repmat(kerThick,[9 1]);
%we got the kernel and we now filter in 8 directions
thickFilterimg=zeros(size(gA,1),size(gA,2),8);
for l=1:8
    MaskKerthick=imrotate(kerThick,(l-1)*45,'bicubic','crop');
    thickFilterimg(:,:,l)= imfilter(gA,MaskKerthick);
end
finalThick= max(thickFilterimg,[],3);
figure,imshow(finalThick,[]);
%%
uhThick=mean(mean(finalThick));


%FDOG for thin vessels
sThinFDOG=1;
lThinFDOG=5;
kerThinFDOG=meshgrid(-3:3,1);
kerThinFDOG=kerThinFDOG.*((1/sqrt(2*pi))*exp(-(kerThinFDOG.^2)/2));
% l=5
kerThinFDOG=repmat(kerThinFDOG,[5 1]);
%we got the kernel now we filter it in 8 directions
thinFilterimgFDOG=zeros(size(gA,1),size(gA,2),8);
for m=1:8
    MaskKerFDOG=imrotate(kerThinFDOG,(m-1)*45,'bicubic','crop');
    thinFilterimgFDOG(:,:,m)= imfilter(gA,MaskKerFDOG);
end
finalThinFDOG=max(thinFilterimgFDOG,[],3);
finalThinFDOGmean= imfilter(finalThinFDOG,W);
finalThinFDOGmeannorm=finalThinFDOGmean./norm(finalThinFDOGmean(:));
%finalThinFDOGmeannorm= mat2gray(finalThinFDOGmean);
Tthin= (1+ finalThinFDOGmeannorm)*(2.3*uhThin);



%FDOG for thick vessels
sThickFDOG =1.5;
lThickFDOG=9;
kerThickFDOG=meshgrid(-4:4,1);
kerThickFDOG=kerThickFDOG.*((1/(sqrt(2*pi)*3.375))*exp(-(kerThickFDOG.^2)/(4.5)));
%l=9
kerThickFDOG=repmat(kerThickFDOG,[9 1]);
%we got the kernel and we now filter in 8 directions
thickFilterimgFDOG=zeros(size(gA,1),size(gA,2),8);
for f=1:8
    MaskKerFDOG=imrotate(kerThickFDOG,(f-1)*45,'bicubic','crop');
    thickFilterimgFDOG(:,:,f)= imfilter(gA,MaskKerFDOG);
end
finalThickFDOG= max(thickFilterimgFDOG,[],3);
finalThickFDOGmean=imfilter(finalThickFDOG,W);
finalThickFDOGmeannorm=finalThickFDOGmean./norm(finalThickFDOGmean(:));
%finalThickFDOGmeannorm=mat2gray(finalThickFDOGmean);
Tthick=(1+finalThickFDOGmeannorm)*(2.3*uhThick);

resultThin=uint8(finalThin)-uint8(Tthin);
resultThick=uint8(finalThick)-uint8(Tthick);
%imshow(resultThick+resultThin);

%MF-FDOG thin vessel
for r=1:size(resultThin,1)
    for t=1:size(resultThin,2)
        if resultThin(r,t)>=0
            resultThin(r,t) = 1;
        else 
            resultThin(r,t) =0;
        end
    end      
end 


%MF-FDOG thick vessel
for z=1:size(resultThick,1)
    for x=1:size(resultThick,2)
        if resultThick(z,x)>=0
            resultThick(z,x) = 1;
        else 
            resultThick(z,x) =0;
        end
    end      
end 

result=resultThin+resultThick;
figure,imshow(result,[]);
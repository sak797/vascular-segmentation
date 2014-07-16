clc
clear all
close all
%%
%Parameters
W = (1/(31*31))*ones(31);
c = 2.3;
sThin=1;
lThin=5;
sThick=1.5;
lThick=9;
sThinFDOG=sThin;
lThinFDOG=lThin;
sThickFDOG =sThick;
lThickFDOG=lThick;
direction=8;
%reads image
A=imread('im0002.ppm');
%A=double(A);
% figure,imshow(A,[]);

%Green Channel extraction
gA=A(:,:,2);
figure,imshow(gA,[]);
%%


%Match-Filter Kernel for thin vessel

kerThin=meshgrid(-3:3,1);
kerThin=(-1/(sqrt(2*pi)*sThin))*exp(-(kerThin.^2)/(2*(sThin^2)));

% for calculating erf values use http://www.miniwebtool.com/error-function-calculator/?number=2.1213
%syms x;
%exprThin=(1/sqrt(2*pi))*exp(-(x^2)/2);
%mThin=int(exprThin,-3,3)/6; (7186705221432913*2^(1/2)*pi^(1/2)*erf((3*2^(1/2))/2))/108086391056891904
%erf((3*2^(1/2))/2)=0.9972999
%mThin= 0.1662;
mThin = mean(kerThin);
kerThin=kerThin-mThin;
% l=5
kerThin=repmat(kerThin,[lThin 1]);

%we got the kernel now we filter it in 8 directions
thinFilterimg=zeros(size(gA,1),size(gA,2),direction);
% figure;
for i=1:direction
    MaskKerthin=imrotate(kerThin,(i-1)*(180/direction),'bicubic','crop');
    temp = imfilter(gA,MaskKerthin);
    temp=double(temp);
    temp = temp - min(temp(:));
    temp = temp./max(temp(:));
    temp = temp.*255;
    thinFilterimg(:,:,i) = temp;
%     subplot(2,4,i),imshow(MaskKerthin,[]);
end
finalThin=max(thinFilterimg,[],3);
% finalThin=sum(thinFilterimg,3)/3;
% figure,imshow(finalThin,[]);
%%
uhThin=mean(mean(finalThin));


%Match-Filter Kernel for thick vessel

kerThick=meshgrid(-4:4,1);
kerThick=(-1/(sqrt(2*pi)*sThick))*exp(-(kerThick.^2)/(2*(sThick^2)));
%syms y;
%exprThick=(1/(sqrt(2*pi)*1.5))*exp(-(y^2)/(4.5)); (4791136814288609*2^(1/2)*pi^(1/2)*0.9972999)/108086391056891904
%erf((3*2^(1/2))/2)=0.9972999
%mThick=int(exprThick,-4.5,4.5)/9;
%mThick=0.1108;
mThick=mean(kerThick);
kerThick=kerThick-mThick;
%l=9
kerThick=repmat(kerThick,[lThick 1]);
%we got the kernel and we now filter in 8 directions
thickFilterimg=zeros(size(gA,1),size(gA,2),direction);
for l=1:direction
    MaskKerthick=imrotate(kerThick,(l-1)*(180/direction),'bicubic','crop');
    temp=imfilter(gA,MaskKerthick);
    temp=double(temp);
    temp = temp - min(temp(:));
    temp = temp./max(temp(:));
    temp = temp.*255;
    thickFilterimg(:,:,l) = temp;
    %thickFilterimg(:,:,l)= imfilter(gA,MaskKerthick);
end
finalThick= max(thickFilterimg,[],3);
% finalThick=sum(thickFilterimg,3)/3;
% figure,imshow(finalThick,[]);
%%
uhThick=mean(mean(finalThick));

%MF of image
finalMF=max(finalThick,finalThin);
figure,imshow(finalMF,[]);
%FDOG for thin vessels

kerThinFDOG=meshgrid(-3:3,1);
kerThinFDOG=kerThinFDOG.*((1/(sqrt(2*pi)*(sThinFDOG^3)))*exp(-(kerThinFDOG.^2)/(2*(sThinFDOG^2))));
% l=5
kerThinFDOG=repmat(kerThinFDOG,[lThin 1]);
%we got the kernel now we filter it in 8 directions
thinFilterimgFDOG=zeros(size(gA,1),size(gA,2),direction);
for m=1:direction
    MaskKerFDOG=imrotate(kerThinFDOG,(m-1)*(180/direction),'bicubic','crop');
    temp= imfilter(gA,MaskKerFDOG);
    temp=double(temp);
    temp = temp - min(temp(:));
    temp = temp./max(temp(:));
    temp = temp.*255;
    thinFilterimgFDOG(:,:,m)=temp;
end
finalThinFDOG=max(thinFilterimgFDOG,[],3);
finalThinFDOGmean= imfilter(finalThinFDOG,W);
% figure,imshow(finalThinFDOGmean,[]);
%%
finalThinFDOGmeannorm=finalThinFDOGmean./norm(finalThinFDOGmean(:));

% figure,imshow(finalThinFDOGmeannorm,[]);
%%
%finalThinFDOGmeannorm= mat2gray(finalThinFDOGmean);
Tthin= (1+ finalThinFDOGmeannorm)*(c*uhThin);

%FDOG for thick vessels

kerThickFDOG=meshgrid(-4:4,1);
kerThickFDOG=kerThickFDOG.*((1/(sqrt(2*pi)*(sThickFDOG^3)))*exp(-(kerThickFDOG.^2)/(2*(sThickFDOG^2))));
%l=9
kerThickFDOG=repmat(kerThickFDOG,[lThick 1]);
%we got the kernel and we now filter in 8 directions
thickFilterimgFDOG=zeros(size(gA,1),size(gA,2),direction);
for f=1:direction
    MaskKerFDOG=imrotate(kerThickFDOG,(f-1)*(180/direction),'bicubic','crop');
    temp= imfilter(gA,MaskKerFDOG);
    temp=double(temp);
    temp = temp - min(temp(:));
    temp = temp./max(temp(:));
    temp = temp.*255;
    
    thickFilterimgFDOG(:,:,f)=temp;
end
finalThickFDOG= max(thickFilterimgFDOG,[],3);
finalThickFDOGmean=imfilter(finalThickFDOG,W);
% figure,imshow(finalThickFDOGmean,[]);
%%
finalThickFDOGmeannorm=finalThickFDOGmean./norm(finalThickFDOGmean(:));
% figure, imshow(finalThickFDOGmeannorm,[]);
%finalThickFDOGmeannorm=mat2gray(finalThickFDOGmean);
%%
Tthick=(1+finalThickFDOGmeannorm)*(c*uhThick);

%Mean normalized FDOG
Dm=max(finalThinFDOGmeannorm,finalThickFDOGmeannorm);
Tm=(1+Dm)*c*max(uhThin,uhThick);
figure,imshow(Dm,[]);
%FDOG of Image
T=max(Tthin,Tthick);

% resultThin=(finalThin)-(Tthin);
% resultThick=(finalThick)-(Tthick);
%imshow(resultThick+resultThin);

%MF-FDOG thin vessel
% resultThin=uint8(resultThin>=0);
% for r=1:size(resultThin,1)
%     for t=1:size(resultThin,2)
%         if resultThin(r,t)>=0
%             resultThin(r,t) = 1;
%         else 
%             resultThin(r,t) =0;
%         end
%     end      
% end 


%MF-FDOG thick vessel
% resultThick=uint8(resultThick>=0);
% for z=1:size(resultThick,1)
%     for x=1:size(resultThick,2)
%         if resultThick(z,x)>=0
%             resultThick(z,x) = 1;
%         else 
%             resultThick(z,x) =0;
%         end
%     end      
% end 
result=finalMF-Tm;
result=uint8(result>=0);
figure,imshow(result,[]);
result=finalMF-T;
result=uint8(result>=0);

% figure,imshow(resultThick,[])
% figure,imshow(resultThin,[])

% result=or(resultThin,resultThick);
% figure,imshow(result,[]);

% level=graythresh(result);
% result=im2bw(result,level);
% figure,imshow(result,[]);
% result=bwareaopen(result,50);
% figure,imshow(result,[]);
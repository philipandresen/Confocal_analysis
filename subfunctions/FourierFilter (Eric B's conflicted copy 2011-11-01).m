function [ imageout ] =FourierFilter(Imagein,lower,upper,include,channel,currentframe,edgefilter,ROImask)
%This function will take an input image, apply a fast fourier transform to
%it, it will eliminate a disk of the fourier space with radii of
%lower-upper and return an image with that disk of space reverse fourier
%transformed. Include can be either zero or one and will decide whether to
%return the removed disk of fourier space or the remainder
%of the image after the disk is removed. Channel dictates which channel of
%the image is to be transformed (red=1, green=2, blue=3). The returned
%image is the one transformed channel in grayscale. Edgefilter wil remove
%all data outside edges calculated on the original image.
if edgefilter>50; 
    msgbox('WARNING: And edge filter over 50 pixels in radius is hazardous for computing times. Aborting!'); 
    imageout=Imagein;
    return;
end;
FourierSpace=fft2(Imagein(:,:,channel,1)); %changed currentframe to 1. Currentframe is obsolete.
%include=0; 
    %1 means the range is filtered from the fourier transform.
    %0 means everything OUTSIDE the range is filtered from the transform.
[xw yw Bd]=size(Imagein);
maxcorner=(sqrt(xw^2+yw^2))/2+1;
[xx yy]=meshgrid(-(xw-1)/2:(xw-1)/2,-(yw-1)/2:(yw-1)/2);
    range=[lower,upper];  %[0.63,.96]
    mask=sqrt(xx.^2+yy.^2); %Circular filtering
    %mask=abs(xx)+abs(yy); %Diamond filtering
    mask=(mask>maxcorner*range(1) & mask<maxcorner*range(2));
    minimum=min(min(min(real(ifft2(FourierSpace)))));
    maximum=max(max(max(real(ifft2(FourierSpace)))));
    AA=whos('Imagein');
    totalmax=intmax(AA.class);
    valuerange=double(maximum-minimum)/double(totalmax);
    scalefactor=double(minimum)/double(totalmax);
%     disp({'Minimum:' num2str(minimum);'Maximum:' num2str(maximum);...
%         'Scalefactor:' num2str(scalefactor);'Rangevalue:' num2str(valuerange)})
    %edgemask=im2bw(imclose(Imagein,[1 1 1 1;1 1 1 1;1 1 1 1; 1 1 1 1]),scalefactor+0.1*valuerange^2);
    edgemask=im2bw(Imagein(:,:,channel,1),scalefactor+0.065*valuerange);
    edgemask=imclose(edgemask,strel('disk',5));
    
    if edgefilter>=1; 
        se=strel('disk',1);
        for i=1:edgefilter; edgemask=imerode(edgemask,se); end; 
    end;
    edgemask=immultiply(edgemask,ROImask);
    %at this point the mask is ready to filter the fourier transform.
    FilteredFourier=FourierSpace;
    FilteredFourier(mask==include)=0;
    if edgefilter>=0; imageout=immultiply(real(ifft2(FilteredFourier)),edgemask); end;
    if edgefilter<0; imageout=real(ifft2(FilteredFourier)); end;
    
    %for debug, we have a plot:
%      figure;
%      imagesc(immultiply(edgemask,ROImask))
end


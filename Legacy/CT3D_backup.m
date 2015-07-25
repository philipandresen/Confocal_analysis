addpath('subfunctions');
clc
%Load image
[a b c]=uigetfile({'*.*'},'Select a file to load', ...
    'Multiselect','off',cd);
if c==0;
    break;
end;
fname=a;
path=b;
lowerR=0.63;
upperR=0.96;
threshold=0.025;
edgemask=1;
channel=1;
numframes=length(imfinfo([path fname])); %find dimensionality of image
clusterid=1;
INFORMATION(1:1024,1:1024,1:numframes)=int16(0); %max supported size
%NO MORE THAN 127 clusters allowed! (int8)
for frame=1:numframes 
    disp(frame)
    %LOOP  HERE  %IDENTIFYING REGION PROPERTIES
    if numframes>1; 
        IMAGEINPUT=imread([path fname],frame); 
    else
        IMAGEINPUT=imread([path fname]);
    end;
    %handles=Update_All_Data(handles);
    %handles=fourier_update(handles);
    FILTEREDIMAGE=FourierFilter(IMAGEINPUT,lowerR,upperR,0,channel,1,edgemask);
    %handles=Update_Clusters(handles);
    IM2process=im2bw(FILTEREDIMAGE/255,threshold);
    STATS=regionprops(IM2process,IMAGEINPUT(:,:,channel,1),'all');
    for cluster=1:length(STATS) %Do for each cluster in the image
        if STATS(cluster).Area<10; continue; end;
        coords=cat(1,STATS(cluster).PixelList);
        INFORMATION(coords(:,1),coords(1,:),frame)=clusterid;
        clusterid=clusterid+1;
        if clusterid>32767
            disp('WARNING! INT8 DATA TYPE EXCEEDED! More than 32767 clusters. Consider changing to int32')
            break
        end;
        hold on;
        depth=zeros(size(coords(:,2)));
        depth(:)=frame;%random('uniform',0,255);
        col=[random('uniform',0,1) 0 0];
        plot3(coords(:,1),coords(:,2),depth,'.','color',col)
        drawnow
        hold off;
    end;
end;
       


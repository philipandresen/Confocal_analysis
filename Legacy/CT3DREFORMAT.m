clear;
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
lowerR=0.6;
upperR=0.96;
threshold=0.9;
edgemask=1;
col=[0 0 0];
channel=1;
FINFO=imfinfo([path fname]);
numframes=length(FINFO); %find dimensionality of image
INFORMATION(numframes,1).Area=0;
clusterid=1;
%INFORMATION(1:FINFO(1).Width,1:FINFO(1).Height,1:numframes)=int16(0); %max supported size
minframe=floor(numframes/2)-1;
maxframe=numframes;
%NO MORE THAN 127 clusters allowed! (int8)
for frame=minframe:maxframe %ID all clusters
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
    STATS=regionprops(IM2process,IMAGEINPUT(:,:,channel,1),'PixelList','Area');
    clusterarray=[];

    %Check all clusters in frame -1 and frame+1 for shared coords.
    
%     for cluster=1:length(STATS) %Do for each cluster in the image
%         clusterid=clusterid+1;
%         INFORMATION(frame,cluster).Area=STATS(cluster).Area;
%         INFORMATION(frame,cluster).PixelList=STATS(cluster).PixelList;
%         INFORMATION(frame,cluster).ClusterID=clusterid; %Cluter ID per pixel
%     end;
end;

clear IMAGEINPUT FILTEREDIMAGE FINFO IM2process;

%disp('Unique Cluster Ids BEFORE')
% UINF=length(unique([INFORMATION.ClusterID]));
clusterid=0;
for frame=minframe:maxframe
    disp(['frame: ' num2str(frame)])
    numclusters=size(STATS(frame));
    numclusters=numclusters(1);
    for cluster=1:numclusters %Do for each cluster in the image
        Clist=STATS(frame,cluster).PixelList;
        if isempty(Clist); continue; end;
        Plist=cat(1,STATS(frame,cluster).PixelList)
        s=size(Plist);
        depth=zeros(s(1),1)+frame;
        clusterid=clusterid+1;
        disp(size(depth))
        disp(size(cat(1,STATS(frame,cluster).PixelList)))
        CLUSTERS(clusterid).coords=[Plist depth];
    end;
end;

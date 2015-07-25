function [  ] = Zspan_F_CT3D(file,lowerR,upperR,threshold,ROImask,channel,edgemask,minframe,maxframe,handleoutput,reqframe,Creq)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

% fname=a;
% path=b;
%lowerR=0.6;
%upperR=0.96;
%threshold=0.9;
% edgemask=1;
disp(Creq)
figure;
col=[0 0 1];
% channel=1;
FINFO=imfinfo([file]);
numframes=length(FINFO); %find dimensionality of image
INFORMATION(numframes,1).Area=0;
clusterid=1;
%INFORMATION(1:FINFO(1).Width,1:FINFO(1).Height,1:numframes)=int16(0); %max supported size
%minframe=floor(numframes/2)-1;
%maxframe=numframes;
if minframe<1; minframe=1; end;
if maxframe>numframes; maxframe=numframes; end;
%NO MORE THAN 127 clusters allowed! (int8)
for frame=minframe:maxframe %ID all clusters
    set(handleoutput,'string',num2str(frame))
    drawnow;
    %LOOP  HERE  %IDENTIFYING REGION PROPERTIES
    if numframes>1; 
        IMAGEINPUT=imread([file],frame); 
    else
        IMAGEINPUT=imread([file]);
    end;
    %handles=Update_All_Data(handles);
    %handles=fourier_update(handles);
    FILTEREDIMAGE=FourierFilter(IMAGEINPUT,lowerR,upperR,0,channel,1,edgemask,ROImask);
    %handles=Update_Clusters(handles);
    IM2process=im2bw(FILTEREDIMAGE/255,threshold);
    STATS=regionprops(IM2process,IMAGEINPUT(:,:,channel,1),'PixelList','Area');
    clusterarray=[];

    %Check all clusters in frame -1 and frame+1 for shared coords.
    
    for cluster=1:length(STATS) %Do for each cluster in the image
        clusterid=clusterid+1;
        INFORMATION(frame,cluster).Area=STATS(cluster).Area;
        INFORMATION(frame,cluster).PixelList=STATS(cluster).PixelList;
        INFORMATION(frame,cluster).ClusterID=clusterid; %Cluter ID per pixel
    end;
end;
%%TESTING Zspan
%reqframe=11;
%Creq(reqframe).list=cat(1,INFORMATION(11,[1:4 6:8]).PixelList);
%disp(size(Creq(minframe).list))
%disp(Creq)
INFORMATION=Zspan(INFORMATION,Creq,minframe,maxframe,reqframe);
%disp(size(INFORMATION))
%ENdtest code
INFsize=size(INFORMATION);
numclusters=INFsize(2);
maxframe=INFsize(1);
%disp(numclusters)
%disp(size(INFORMATION))
clear STATS IMAGEINPUT FILTEREDIMAGE FINFO IM2process;

%disp('Unique Cluster Ids BEFORE')
UINF=length(unique([INFORMATION.ClusterID]));
col=[random('uniform',0,1) random('uniform',0,1) random('uniform',0,1)];
for frame=minframe:maxframe
    %col(1)=((frame-minframe)/(maxframe-minframe));
    %col(2)=((frame-minframe)/(maxframe-minframe));
    %col(3)=((frame-minframe)/(maxframe-minframe));
    %if frame==reqframe; col(1)=1; col(2)=0; col(3)=0; end;
    set(handleoutput,'string',['frame: ' num2str(frame)])
    drawnow;
    for cluster=1:numclusters %Do for each cluster in the image
        coords=cat(1,INFORMATION(frame,cluster).PixelList);
        if length(coords)<2; continue; end;

            %PLOTTING
            hold on; 
            depth=zeros(size(coords(:,2)));
            depth(:)=48*((frame-minframe)/(maxframe-minframe)); %0.3 is a good depth scale
            %col(1)=random('uniform',0,1);
            plot3(coords(:,1),coords(:,2),depth,'s','color',col,'MarkerFaceColor',col,'MarkerSize',14)
            hold off;
    end;
end;
%disp('Unique Cluster Ids BEFORE')
%disp(UINF)
set(handleoutput,'string','Complete')
    drawnow;

%disp('Unique Cluster Ids AFTER')
%length(unique([INFORMATION.ClusterID]));
%set(gca,'projection','perspective')
    axis tight;
    axis equal;
    grid on;
    drawnow
end


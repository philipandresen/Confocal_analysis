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
    
    for cluster=1:length(STATS) %Do for each cluster in the image
        clusterid=clusterid+1;
        INFORMATION(frame,cluster).Area=STATS(cluster).Area;
        INFORMATION(frame,cluster).PixelList=STATS(cluster).PixelList;
        INFORMATION(frame,cluster).ClusterID=clusterid; %Cluter ID per pixel
    end;
end;
numclusters=size(INFORMATION);
numclusters=numclusters(2);
clear STATS IMAGEINPUT FILTEREDIMAGE FINFO IM2process;

disp('Unique Cluster Ids BEFORE')
UINF=length(unique([INFORMATION.ClusterID]));

for frame=minframe:maxframe
    disp(['frame: ' num2str(frame)])
    for cluster=1:numclusters %Do for each cluster in the image
        coords=cat(1,INFORMATION(frame,cluster).PixelList);
        if length(coords)<2; continue; end;
        %CONVERGING CLUSTERS
%         clc
%         disp('Searching for adjacent clusters')
%         disp(['frame: ' num2str(frame)])
%         disp(['cluster: ' num2str(cluster)])
%         matchup=...
%             sum(ismember(cat(1,INFORMATION(frame-1,:).PixelList),...
%             cat(1,INFORMATION(21,:).PixelList),'rows'));
%         POSSIBLE WORKAROUND:
% matchid=[INFORMATION(...
%     ismember(...
%     cat(1,INFORMATION(frame-1,:).PixelList),...
%     cat(1,INFORMATION(frame,cluster).PixelList)...
%     ,'rows')).ClusterID];
% Coords=cat(1,INFORMATION(ismember([INFORMATION.ClusterID],matchid)).PixelList);
% if length(Coords)<2; continue; end;
% hold on
% plot(Coords(:,1),Coords(:,2),'o','color',[1 0 0])
% plot(coords(:,1),coords(:,2),'o','color',[0 1 0])
% hold off
% drawnow;
        for belowcluster=1:numclusters %check all clusters above
            coBelow=cat(1,INFORMATION(frame,belowcluster).PixelList);
            if sum(ismember(coBelow,coords))>1 %If you share any coordinates
                INFORMATION(frame,cluster).ClusterID=...
                    INFORMATION(frame,belowcluster).ClusterID;%Make the same cluster
            end;
        end;
        for abovecluster=1:numclusters %check all clusters above
            coAbove=cat(1,INFORMATION(frame,abovecluster).PixelList);
            if sum(ismember(coAbove,coords))>1 %If you share any coordinates
                INFORMATION(frame,abovecluster).ClusterID=...
                    INFORMATION(frame,cluster).ClusterID;%Make the same cluster
            end;
        end;
%         consolidated=length(INFORMATION([INFORMATION.ClusterID]==INFORMATION(frame,cluster).ClusterID));
%         disp([num2str(consolidated) ' Clusters consolidated with unique ID'])
%         hold on
%         plot(frame,consolidated)
%         hold off
%         drawnow;
            %PLOTTING
%             hold on; 
%             depth=zeros(size(coords(:,2)));
%             depth(:)=frame; %0.3 is a good depth scale
%             col(1)=random('uniform',0,1);
%             plot3(coords(:,1),coords(:,2),depth,'.','color',col)
%             hold off;
    end;
end;
disp('Unique Cluster Ids BEFORE')
disp(UINF)

disp('Unique Cluster Ids AFTER')
length(unique([INFORMATION.ClusterID]))
%     axis tight;
%     axis equal;
%     grid on;
%     drawnow
    %clear INFORMATION;
       
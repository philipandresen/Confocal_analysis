function [ MegaCluster ] = Zspace_Megacluster(handles)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

%% Initialize needed inputs
file=[handles.path handles.fname];
switch handles.numspecies
    case 1
        minframe=handles.stackrange(1);
        maxframe=handles.stackrange(2);
    case 2
        minframe=handles.stackrange(1);
        maxframe=handles.stackrange2(2);
end;
FINFO=imfinfo(file);
numframes=length(FINFO);
if (minframe<1)|(minframe>maxframe); minframe=1; end; %#ok<OR2>
if maxframe>numframes; maxframe=numframes; end;
lowerR=handles.lowerR;
upperR=handles.upperR;
threshold=handles.threshold;
ROImask=handles.ROImask;
channel=handles.channel;
edgemask=handles.edgemask;
prog=0;
stackrange=handles.stackrange;
stackrange2=handles.stackrange2;

%% Compile frame by frame data
wbar=waitbar(prog,'Analysing Cross sections');
for frame=minframe:maxframe
    prog=(frame-minframe)/(maxframe-minframe);
    waitbar(prog,wbar,['Analysing Cross Section ' num2str(frame)])
    %% Load data into STATS
    %load each frame of the file unless it has only one frame.
    %disp(frame)
    if numframes>1;
        IMAGEINPUT=imread(file,frame);
    else
        IMAGEINPUT=imread(file);
    end;
    %filter the image using the user specified parameters
    FILTEREDIMAGE=FourierFilter(IMAGEINPUT,lowerR,upperR,0,channel,1,edgemask,ROImask);
    %Apply the threshold to the filtered image and apply region props.
    IM2process=im2bw(FILTEREDIMAGE/255,threshold);
    STATS=regionprops(IM2process,IMAGEINPUT(:,:,channel,1),'all');
    %Experimental filtering
    maxval=max(max(IMAGEINPUT(:,:,channel,1)));
    minval=min(min(IMAGEINPUT(:,:,channel,1)));
    threshval=minval+(maxval-minval)/8;
    STATS([[STATS.Area]<5])=[];
    STATS([[STATS.MeanIntensity]<threshval])=[];
    %end experimental filtering
    %% Begin segmenting data
    %disp(STATS)
    Info(frame,1:length(STATS))=STATS(:); 
end;

[Info(:,:).free]=deal(true); %enable all clusters for mask use.
[Info(cellfun('isempty',{Info.Area})).free]=deal(0);
%disp(sum([[Info.free]==deal(0)])) %#ok<*NBRAK>
%disp(sum([[Info.free]==deal(1)]))

OriginalLength=sum([[Info.free]==deal(0)])+sum([[Info.free]==deal(1)]);
%cindex=0;
Creq(1).list=[];
Creq(maxframe+1).list=[];
cid=0;
prog=0; 
%figure;
%argh=axes;
%% Select initial cluster requirement by Creq Frame

for reqframe=minframe:maxframe
    %disp('Choosing a new base frameset for clusters')
    %Here's the idea: Select your creqframe at frame 1, then zero out all
    %the pixel lists until the frame is empty, then check the next frame
    %for Creqs untis that one is empty. Eventually, you should run out of
    %clusters and as you move through each frame you should have fewer to
    %select.
    Volume=0; %#ok<*NASGU>
    surface_area=0;
    value=0;
    args=length(Info(reqframe,:));
    for reqcluster=1:length(Info(reqframe,:))
        prog=((1)/(maxframe-minframe))*(reqcluster)/(args)+(reqframe-minframe)/(maxframe-minframe);
        waitbar(prog,wbar,'Correlating slices...')
        %Make sure the cluster you are about use as a mask isn't already dead.
        if Info(reqframe,reqcluster).free==1;
            Info(reqframe,reqcluster).free=0; 
            [Creq(:).list]=deal([]);%%clear your cluster masks before starting a new cluster.
            Creq(1).list=[];
            Creq(maxframe+1).list=[];
            Creq(reqframe).list=Info(reqframe,reqcluster).PixelList;
            if isempty([Creq.list]); continue; end;  
            cid=cid+1; %New cluster ID tag
            MegaCluster(cid).color=[0 0 0];%Default color
            MegaCluster(cid).color2=[1 1 1];
            MegaCluster(cid).species=0; %default species
            MegaCluster(cid).obj='d';
            switch handles.numspecies %Set cluster color===================
                case 1
                    MegaCluster(cid).color=[random('uniform',0,1) random('uniform',0,1) random('uniform',0,1)];
                    MegaCluster(cid).color2=MegaCluster(cid).color;
                    z_corr_factor=stackrange(1);
                    MegaCluster(cid).species=1;
                    MegaClsuter(cid).obj='s';
                case 2
                    if sum((reqframe<stackrange)==[0 1])==2;
                        MegaCluster(cid).color=[0 1 0];
                        MegaCluster(cid).color2=[random('uniform',0,1) random('uniform',0,1) random('uniform',0,1)];
                        Megacluster(cid).species=1;
                        z_corr_factor=stackrange(1);
                        disp(z_corr_factor)
                        MegaCluster(cid).obj='s';
                    end;
                    if sum((reqframe<stackrange2)==[0 1])==2;
                        MegaCluster(cid).color=[1 0 0];
                        MegaCluster(cid).color2=[random('uniform',0,1) random('uniform',0,1) random('uniform',0,1)];
                        Megacluster(cid).species=2;
                        z_corr_factor=stackrange2(1);
                        disp(z_corr_factor)
                        MegaCluster(cid).obj='o';
                    end;
            end%===========================================================
            MegaCluster(cid).xx=[];
            MegaCluster(cid).yy=[];
            MegaCluster(cid).zz=[];
            
            %at this point we have our one cluster requirement. Find ALL
            %THE LINKED CLUSTERS!
            xx=[];
            yy=[];
            zz=[];
            Volume=0;
            surface_area=0;
            value=0;
            for randomindex=1:2 %The second number here is the number of sweeps on every run
                %% going up:
                lower=minframe;
                if randomindex==1; lower=reqframe; end;
                for frame=lower:maxframe-1
                    if isempty(Creq(frame).list); continue; end;
                    for cluster=1:length(Info(frame,:))-1
                        %Make sure the cluster you are about to check isn't already dead.
                        if Info(frame+1,cluster).free==1;
                            %if isempty(Info(frame+1,cluster).Area); disp('CONTINUE'); continue; end;
                            common=intersect(Info(frame+1,cluster).PixelList,Creq(frame).list,'rows');
                            if ~isempty(common);
                                Info(frame+1,cluster).free=0;
                                Creq(frame+1).list=unique(cat(1,Creq(frame+1).list,Info(frame+1,cluster).PixelList),'rows');
                                xx=[xx;Info(frame+1,cluster).PixelList(:,1)];
                                yy=[yy;Info(frame+1,cluster).PixelList(:,2)];
                                zz=[zz;zeros(length(Info(frame+1,cluster).PixelList(:,1)),1)+frame+1-z_corr_factor];
                                Volume=Volume+Info(frame+1,cluster).Area;
                                value=value+sum([Info(frame+1,cluster).PixelValues]);
                                surface_area=surface_area+...
                                    Info(frame+1,cluster).Perimeter+...
                                    abs(length(Info(frame+1,cluster).PixelList)-...
                                    size(common,1));
                                MegaCluster(cid).xx=xx;
                                MegaCluster(cid).yy=yy;
                                MegaCluster(cid).zz=zz;
                                MegaCluster(cid).Volume=Volume;
                                MegaCluster(cid).Value=value/Volume;
                                MegaCluster(cid).surface_area=surface_area;
                                MegaCluster(cid).cid=cid;
                                %plot3(xx,yy,zz,'color',col,'Parent',argh)
                                %drawnow
                                %axis equal
                                %disp(length(Creq(frame+1).list));
                            end;
                        end;
                    end;
                end;
                %% going down
                for pseudoframe=1:(maxframe-minframe)-1
                    frame=maxframe-pseudoframe;
                    %disp(frame);
                    if isempty(Creq(frame).list); continue; end;
                    for cluster=1:length(Info(frame,:))-1
                        %Make sure the cluster you are about to check isn't already dead.
                        if Info(frame-1,cluster).free==1;
                            %if isempty(Info(frame-1,cluster).Area); disp('CONTINUE'); continue; end;
                            common=intersect(Info(frame-1,cluster).PixelList,Creq(frame).list,'rows');
                            if ~isempty(common);
                                Info(frame-1,cluster).free=0;
                                Creq(frame-1).list=unique(cat(1,Creq(frame-1).list,Info(frame-1,cluster).PixelList),'rows');
                                xx=[xx;Info(frame-1,cluster).PixelList(:,1)];
                                yy=[yy;Info(frame-1,cluster).PixelList(:,2)];
                                zz=[zz;zeros(length(Info(frame-1,cluster).PixelList(:,1)),1)+frame-1-z_corr_factor];
                                Volume=Volume+Info(frame-1,cluster).Area;
                                value=value+sum([Info(frame-1,cluster).PixelValues]);
                                surface_area=surface_area+...
                                    Info(frame-1,cluster).Perimeter+...
                                    abs(length(Info(frame-1,cluster).PixelList)-...
                                    size(common,1));
                                MegaCluster(cid).xx=xx;
                                MegaCluster(cid).yy=yy;
                                MegaCluster(cid).zz=zz; %#ok<*AGROW>
                                MegaCluster(cid).Volume=Volume;
                                MegaCluster(cid).Value=value/Volume;
                                MegaCluster(cid).surface_area=surface_area;
                                MegaCluster(cid).cid=cid;
                                %plot3(xx,yy,zz,'color',col,'Parent',argh)
                                %drawnow
                                %axis equal
                                %disp(length(Creq(frame+1).list));
                            end;
                        end;
                    end;
                end;%==========================================================
            end;%This end corresponds to the 'number of sweeps' for loop.
        end;
    end;
end
figure

%Tst this code, trim megacluster
%MegaCluster=MegaCluster([MegaCluster.Volume]~=0);
%cid=size(MegaCluster,2);

ax=axes;
maxcoord=max(cat(1,cat(1,MegaCluster.xx),cat(1,MegaCluster.yy)))*handles.mikestopix;
mincoord=min(cat(1,cat(1,MegaCluster.xx),cat(1,MegaCluster.yy)))*handles.mikestopix;
zmin=min(cat(1,MegaCluster.zz))*handles.mikestopix;
zmax=max(cat(1,MegaCluster.zz))*handles.mikestopix;
zrange=(zmax-zmin);
axis([mincoord maxcoord mincoord maxcoord zmin-zrange*2.5 zmin+zrange*2.5 0 1])
%teh above line sets the axis to span all image space, and then scale z
hold(ax,'on');
Rind=0; %This index is used in the data refinement

%% plot the data!
for i=1:cid
    if ~isempty(MegaCluster(i).Volume); 
        if MegaCluster(i).Volume>handles.volumelimit;%Limit output data volume requirement
            Rind=Rind+1;
            Refined(Rind)=MegaCluster(i); 
            Refined(Rind).cid=Rind;
        else
            continue;
        end;
    end;
    col=MegaCluster(i).color;
    col3=MegaCluster(i).color2;
    obj=MegaCluster(i).obj;
    %col=[random('uniform',0,1) random('uniform',0,1) random('uniform',0,1)];
    %col=[MegaCluster(i).Volume/max([MegaCluster.Volume]) 1 random('uniform',0,1)];
    %xnoise=random('uniform',0,1,size(MegaCluster(i).xx));
    %ynoise=random('uniform',0,1,size(MegaCluster(i).yy));
    %znoise=random('uniform',0,1,size(MegaCluster(i).zz));
    xx=MegaCluster(i).xx;
    yy=MegaCluster(i).yy;
    zz=MegaCluster(i).zz;
    uz=unique(zz);
    for j=1:length(uz)
        col2=col*(j/length(unique(zz)));
        col4=col3*(j/length(unique(zz)));
        %col2=col;
        x=xx([MegaCluster(i).zz]==deal(uz(j)));
        y=yy([MegaCluster(i).zz]==deal(uz(j)));
        z=zz([MegaCluster(i).zz]==deal(uz(j)));
        xnoise=random('uniform',0,1,size(x));
        ynoise=random('uniform',0,1,size(y));
        znoise=random('uniform',0,1,size(z));
        hand(i,j)=plot3(...
            handles.mikestopix*(x+xnoise),...
            handles.mikestopix*(y+ynoise),...
            handles.vmikestopix*(z+znoise),...
            obj,'color',col4,'MarkerSize',10,'MarkerFaceColor',col2,'parent',ax);
        prog=(1/cid)*(j/length(uz))+i/cid;
        waitbar(prog,wbar,'Plotting features...')
        drawnow;
    end;
end;
close(wbar)
hold(ax,'off')
axis(ax,'tight','equal');
grid(ax,'on')
camproj(ax,'perspective')
disp(['Total # of clusters reduced to: ' num2str(cid) ' from ' num2str(OriginalLength)])

%% Save data
numclusters=cid;
mikestopix=handles.mikestopix;
vmikestopix=handles.vmikestopix;
MegaCluster=Refined;
save('Megacluster_data','MegaCluster','mikestopix','vmikestopix','numclusters')
INFO=[MegaCluster.Volume;MegaCluster.surface_area;MegaCluster.cid;MegaCluster.Value]';
    set(handles.uitable1,'Data',INFO)
%clear Info MegaCluster xx yy zz Creq

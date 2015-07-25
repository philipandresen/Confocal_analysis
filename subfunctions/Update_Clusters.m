function [ handles ] = Update_Clusters(handles)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here
if handles.autoid==1; %RECALCULATE EVERYTHING IF AUTOUPDATE IS ON
    handles.datamode=0;
    set(handles.progresstext,'string','Thresholding Image...')
    set(handles.ORG6,'Value',1);
    set(handles.regionpropsbutton,'Enable','on')
    drawnow;
    IM2process=im2bw(handles.FILTEREDIMAGE/255,handles.threshold);
    set(handles.progresstext,'string','Identifying features...')
    drawnow;
    handles.STATS=regionprops(IM2process,handles.IMAGEINPUT(:,:,handles.channel,handles.currentframe),'all');
    set(handles.progresstext,'string','Plotting requested data...')
    maxval=max(max(handles.IMAGEINPUT(:,:,handles.channel,handles.currentframe)));
    minval=min(min(handles.IMAGEINPUT(:,:,handles.channel,handles.currentframe)));
    threshval=minval+(maxval-minval)/10;
    handles.STATS([[handles.STATS.Area]<10])=[];
    handles.STATS([[handles.STATS.MeanIntensity]<threshval])=[];
    drawnow;
    handles=update_cluster_plot(handles);
    INFO=[handles.STATS.Eccentricity;...
        handles.STATS.Orientation;...
        handles.STATS.MeanIntensity;...
        handles.STATS.Area;handles.STATS.Perimeter;[1:length(handles.STATS)];...
        handles.STATS.MajorAxisLength;handles.STATS.MinorAxisLength;...
        handles.STATS.Solidity]';
    set(handles.uitable1,'Data',INFO)
    handles.INFO=INFO;
    set(handles.progresstext,'string','Complete')
    drawnow;
end;

end

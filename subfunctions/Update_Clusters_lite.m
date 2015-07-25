function [ handles ] = Update_Clusters_lite(handles)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here
if handles.autoid==1; %RECALCULATE EVERYTHING IF AUTOUPDATE IS ON
    set(handles.progresstext,'string','Thresholding Image...')
    drawnow;
    IM2process=im2bw(handles.FILTEREDIMAGE/255,handles.threshold);
    set(handles.progresstext,'string','Identifying features...')
    drawnow;
    handles.STATS=regionprops(IM2process,handles.IMAGEINPUT(:,:,handles.channel,handles.currentframe),'Area','PixelList','Orientation','MeanIntensity','PixelValues','Eccentricity','BoundingBox');
    set(handles.progresstext,'string','Plotting requested data...')
    drawnow;
    update_cluster_plot(handles);
    set(handles.progresstext,'string','Complete')
    drawnow;
end;

end

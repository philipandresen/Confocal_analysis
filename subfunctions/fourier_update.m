function [ handles] = fourier_update(handles)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here
set(handles.progresstextF,'string','Applying Fourier Filter');
drawnow;
handles.FILTEREDIMAGE=FourierFilter(handles.IMAGEINPUT,handles.lowerR,handles.upperR,0,handles.channel,handles.currentframe,handles.edgemask,handles.ROImask);
set(handles.progresstextF,'string','Complete');
drawnow;
set(handles.radiooriginal,'Enable','on')
set(handles.radiofilter,'Enable','on')
set(handles.radiofilterthresh,'Enable','on')
set(handles.radionone,'Enable','on')
set(handles.regionpropsbutton,'Enable','on')

end


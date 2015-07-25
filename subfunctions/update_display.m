function [ graphimage ] = update_display(graphtype,handles)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
graphimage=handles.IMAGEINPUT;
switch graphtype
    case handles.radiooriginal
        maxintens=max(max(handles.IMAGEINPUT(:,:,handles.channel,handles.currentframe)));
        graphimage=(handles.IMAGEINPUT(:,:,handles.channel,handles.currentframe));
    case handles.radiofilter
        graphimage=handles.FILTEREDIMAGE/255;
    case handles.radiofilterthresh
        graphimage=im2bw(handles.FILTEREDIMAGE/255,handles.threshold);
    case handles.radionone
        graphimage=zeros(size(handles.IMAGEINPUT));
    otherwise
        disp('Invalid selection!')
end;


end


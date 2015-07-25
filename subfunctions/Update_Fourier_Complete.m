function [ handles ] = Update_Fourier_Complete(handles)
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here
if handles.autoupdate==1;
        handles=fourier_update(handles);
        handles.graphimage=update_display(handles.graphtype,handles);
        imshow(handles.graphimage,'parent',handles.axes1)
end;

end


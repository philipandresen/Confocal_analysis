function [ handles ] = Update_All_Data( handles )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
if handles.autoupdate==1;
        set(handles.regionpropsbutton,'Enable','on')
        handles=fourier_update(handles);
        handles.graphimage=update_display(handles.graphtype,handles);
        imagesc(handles.graphimage,'parent',handles.axes1)
        handles=Update_Clusters(handles);
end;

end


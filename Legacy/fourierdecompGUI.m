function varargout = fourierdecompGUI(varargin)
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @fourierdecompGUI_OpeningFcn, ...
                   'gui_OutputFcn',  @fourierdecompGUI_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
function fourierdecompGUI_OpeningFcn(hObject, eventdata, handles, varargin) %#ok<*INUSL>
handles.output = hObject;
channeloptions={'Standard deviation' 'Mean Pixel value' 'Area' 'Random' 'on' 'off' 'Orientation' 'Eccentricity'};
set(handles.popupredchannel,'string',channeloptions)
set(handles.popupgreenchannel,'string',channeloptions)
set(handles.popupbluechannel,'string',channeloptions)
set(handles.popupchannel,'string',{'Channel 1 (Red)' 'Channel 2 (Green)' 'Channel 3 (Blue)'})
set(handles.radiooriginal,'Enable','off')
set(handles.radiofilter,'Enable','off')
set(handles.radiofilterthresh,'Enable','off')
set(handles.radionone,'Enable','off')
set(handles.frameslider,'Enable','off')
set(handles.regionpropsbutton,'Enable','off')
set(handles.slidertext,'string','Frame: 1')
handles.path=cd;
handles.channel=1;
handles.FILTEREDIMAGE=imread('TESTIMAGE.png');
handles.IMAGEINPUT=imread('TESTIMAGE.png');
handles.graphtype=handles.radiooriginal;
handles.threshold=0.025;
handles.autoupdate=0;
handles.autoid=0;
handles.currentframe=1;
handles.redgraph=1;
handles.greengraph=1;
handles.bluegraph=1;
handles.coords=[];
handles.rgb=[0 0 0];
handles.edgemask=1;
handles.stackrange(1)=1;
handles.stackrange(2)=1;
handles.INFO=[];
addpath('subfunctions');
% Update handles structure
guidata(hObject, handles);
function varargout = fourierdecompGUI_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;
function loadbutton_Callback(hObject, eventdata, handles) %#ok<*DEFNU>
[a b c]=uigetfile({'*.*'},'Select a file to load', ...
    'Multiselect','off',handles.path);
if c==1;
    colormap gray;
    handles.fname=a;
    handles.path=b;
    set(handles.radiooriginal,'Enable','off')
    set(handles.radiofilter,'Enable','off')
    set(handles.radiofilterthresh,'Enable','off')
    set(handles.radionone,'Enable','off')
    handles.IMAGEINPUT=imread([handles.path handles.fname]);
    imagesc(handles.IMAGEINPUT,'parent',handles.axes1)
    handles=Update_All_Data(handles);
    set(handles.frameslider,'Enable','off')
    set(handles.regionpropsbutton,'Enable','off')
    handles.numframes=length(imfinfo([handles.path handles.fname])); %find dimensionality of image
    if handles.numframes>1; 
        set(handles.frameslider,'Enable','on');
        set(handles.frameslider,'SliderStep',[1/(handles.numframes-1) 10/(handles.numframes-1)])
    end;
end;
guidata(hObject, handles);
function frameslider_Callback(hObject, eventdata, handles) %#ok<*INUSD>
set(handles.radiooriginal,'Enable','off')
set(handles.radiofilter,'Enable','off')
set(handles.radiofilterthresh,'Enable','off')
set(handles.radionone,'Enable','off')
handles.IMAGEINPUT=imread([handles.path handles.fname],floor(get(hObject,'Value')*(handles.numframes-1))+1);
imagesc(handles.IMAGEINPUT,'parent',handles.axes1)
set(handles.slidertext,'string',['Frame: ' num2str(floor(get(hObject,'Value')*(handles.numframes-1))+1)])
drawnow;
handles=Update_All_Data(handles);
guidata(hObject, handles);
function frameslider_CreateFcn(hObject, eventdata, handles)
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end
function popupbluechannel_Callback(hObject, eventdata, handles)
handles.bluegraph=get(hObject,'value');
handles=Update_Clusters(handles);
guidata(hObject, handles);
function popupbluechannel_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function popupgreenchannel_Callback(hObject, eventdata, handles)
handles.greengraph=get(hObject,'value');
handles=Update_Clusters(handles);
guidata(hObject, handles);
function popupgreenchannel_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function popupredchannel_Callback(hObject, eventdata, handles)
handles.redgraph=get(hObject,'value');
handles=Update_Clusters(handles);
guidata(hObject, handles);
function popupredchannel_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function upperfiltertext_Callback(hObject, eventdata, handles)
handles.upperR=str2double(get(hObject,'string'));
handles=Update_All_Data(handles);
guidata(hObject, handles);
function upperfiltertext_CreateFcn(hObject, eventdata, handles)
set(hObject,'string','0.96')
handles.upperR=str2double(get(hObject,'string'));
guidata(hObject, handles);
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function lowerfiltertext_Callback(hObject, eventdata, handles)
handles.lowerR=str2double(get(hObject,'string'));
handles=Update_All_Data(handles);
guidata(hObject, handles);
function lowerfiltertext_CreateFcn(hObject, eventdata, handles)
set(hObject,'string','0.63')
handles.lowerR=str2double(get(hObject,'string'));
guidata(hObject, handles);
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function thresholdtext_Callback(hObject, eventdata, handles)
handles.threshold=str2double(get(hObject,'string'));
handles=Update_All_Data(handles);
guidata(hObject, handles);
function thresholdtext_CreateFcn(hObject, eventdata, handles)
set(hObject,'string','0.025')
handles.threshold=str2double(get(hObject,'string'));
guidata(hObject, handles);
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function popupchannel_Callback(hObject, eventdata, handles)
handles.channel=get(handles.popupchannel,'value');
%Change channel above and update fourier below:
handles=Update_All_Data(handles);

guidata(hObject, handles);
function popupchannel_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function uipanel4_SelectionChangeFcn(hObject, eventdata, handles)
handles.graphtype=eventdata.NewValue;
handles.graphimage=update_display(handles.graphtype,handles);
imagesc(handles.graphimage,'parent',handles.axes1)
handles=Update_Clusters(handles);
guidata(hObject, handles);
function applybutton_Callback(hObject, eventdata, handles)
handles=fourier_update(handles);
handles.graphimage=update_display(handles.graphtype,handles);
imagesc(handles.graphimage,'parent',handles.axes1)
handles=Update_Clusters(handles);
guidata(hObject, handles);
function checkboxauto_Callback(hObject, eventdata, handles)
handles.autoupdate=get(hObject,'Value');
guidata(hObject, handles);
function regionpropsbutton_Callback(hObject, eventdata, handles)
BEF=handles.autoid;
handles.autoid=1;%oops, this is just to make the following function work.
handles=Update_Clusters(handles);
handles.autoid=BEF;%reset to whatever it was before.
guidata(hObject, handles);
function checkboxautoID_Callback(hObject, eventdata, handles)
handles.autoid=get(hObject,'value');
guidata(hObject, handles);
function edgemaskbox_Callback(hObject, eventdata, handles)
handles.edgemask=get(hObject,'value');
handles=Update_All_Data(handles);
guidata(hObject, handles);
function uitable1_CellSelectionCallback(hObject, eventdata, handles)
try %#ok<*TRYNC> 
    %the following block sometimes messes up when organizing the list
    cell=eventdata.Indices;
    data=get(hObject,'Data');
    inds=data(cell(:,1),end);
    %coords=cat(1,handles.STATS(inds).PixelList);
    %plot(coords(:,1),max(get(handles.axes1,'Ylim'))-coords(:,2),'.','color',[0 0 0],'parent',handles.axes2)
%     hold on
%     axis equal
%     set(handles.axes2,'Xlim',get(handles.axes1,'Xlim'))
%     set(handles.axes2,'Ylim',get(handles.axes1,'Ylim'))
%     hold off
    
    imagesc(handles.graphimage,'parent',handles.axes2)
    hold on
    hulls=[];
    for ii=1:length(inds);
        %rectangle('position',handles.STATS(inds(ii)).BoundingBox,'edgecolor','red','parent',handles.axes2)
        hull=handles.STATS(inds(ii)).ConvexHull;
        col=[handles.RGB(inds(ii),1) handles.RGB(inds(ii),2) handles.RGB(inds(ii),3)];
        plot(hull(:,1),hull(:,2),'color',col,'parent',handles.axes2)
        hulls=cat(1,hulls,hull);
    end;
    axis equal
    border=(max(hulls(:,1))-min(hulls(:,1)))/10;
    set(handles.axes2,'Xlim',[min(hulls(:,1))-border max(hulls(:,1))+border])
    set(handles.axes2,'Ylim',[min(hulls(:,2))-border max(hulls(:,2))+border])
    hold off
end;
guidata(hObject, handles);
function stack3dbutton_Callback(hObject, eventdata, handles)
F_CT3D([handles.path handles.fname],...
    handles.lowerR,handles.upperR,handles.threshold,...
    1,handles.edgemask,...
    handles.stackrange(1),handles.stackrange(2))
function minframesedit_Callback(hObject, eventdata, handles)
handles.stackrange(1)=str2double(get(hObject,'String'));
guidata(hObject, handles);
function minframesedit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to minframesedit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function maxframesedit_Callback(hObject, eventdata, handles)
handles.stackrange(2)=str2double(get(hObject,'String'));
guidata(hObject, handles);
function maxframesedit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to maxframesedit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function uipanel8_SelectionChangeFcn(hObject, eventdata, handles)
switch eventdata.NewValue
    case handles.ORG1
        set(handles.uitable1,'Data',sortrows(handles.INFO,-1));
    case handles.ORG2
        set(handles.uitable1,'Data',sortrows(handles.INFO,2));
    case handles.ORG3
        set(handles.uitable1,'Data',sortrows(handles.INFO,-3));
    case handles.ORG4
        set(handles.uitable1,'Data',sortrows(handles.INFO,-4));
    case handles.ORG5
        set(handles.uitable1,'Data',sortrows(handles.INFO,-5));
    case handles.ORG6
        set(handles.uitable1,'Data',sortrows(handles.INFO,6));
end;

% --- Executes when figure1 is resized.
function figure1_ResizeFcn(hObject, eventdata, handles)
figpos=get(gcf,'Position');
pos1=get(handles.uipanel1,'Position');
pos2=get(handles.uipanel2,'Position');
pos3=get(handles.uipanel3,'Position');
pos4=get(handles.uipanel4,'Position');
pos5=get(handles.uipanel5,'Position');
pos7=get(handles.uipanel7,'Position');
pos1(3)=figpos(3)-pos2(3)-pos7(3);
if pos1(3)<1; pos1(3)=5; end;
pos1(2)=pos5(2)+pos5(4);
pos1(4)=figpos(4)-pos1(2);
set(handles.uipanel1,'Position',pos1)
set(handles.axes1,'Position',[4 4 pos1(3)-4 pos1(4)-4])

pos2(1)=pos1(1)+pos1(3);
pos2(2)=pos1(2)+pos1(4)-pos2(4);
set(handles.uipanel2,'Position',pos2)

pos4(1)=pos1(1)+pos1(3);
pos4(2)=pos2(2)-pos4(4);
pos4(3)=pos2(3);
set(handles.uipanel4,'Position',pos4)

pos3(1)=pos1(1)+pos1(3);
pos3(2)=pos4(2)-pos3(4);
pos3(3)=pos4(3);
set(handles.uipanel3,'Position',pos3)

pos7(1)=pos1(1)+pos1(3)+pos2(3);
pos7(2)=pos5(2)+pos5(4);
pos7(4)=figpos(4)-pos5(4);
if pos7(4)-29.58-3>3;
    set(handles.uipanel7,'Position',pos7)
    set(handles.axes2,'Position',[5 pos7(4)-25.58 pos7(3)-5 25.58])
    set(handles.uipanel8,'Position',[1 pos7(4)-32.58 pos7(3)-5 5])
    set(handles.uitable1,'Position',[1 3 pos7(3)-5 pos7(4)-29.58-3]); 
end;


pos5(3)=pos2(1);
set(handles.uipanel5,'Position',pos5)
set(handles.frameslider,'Position',[pos5(1)+2,pos5(2)+1 pos5(3)-4 pos5(4)-2])
set(handles.slidertext,'Position',[pos5(1)+2,pos5(2)+0.1 pos5(3)-4 pos5(4)-3])
set(handles.uipanel10,'Position',[pos2(1) pos3(2)-pos5(4) pos2(3) pos5(4)])

% --- Executes on button press in exportdatabutton.
function exportdatabutton_Callback(hObject, eventdata, handles)
fname=['ORCID Data output ' datestr(today) '.xls'];
fpath=cd;
[fname fpath]=uiputfile([fpath '\' fname]);
A=get(handles.uitable1,'Data');
xlswrite([fpath fname],A)
% hObject    handle to exportdatabutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in exportimagebutton.
function exportimagebutton_Callback(hObject, eventdata, handles)
AA=figure;
copyobj(handles.axes2,AA);


% hObject    handle to exportimagebutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

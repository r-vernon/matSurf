function varargout = matSurf(varargin)
% MATSURF MATLAB code for matSurf.fig
%      MATSURF, by itself, creates a new MATSURF or raises the existing
%      singleton*.
%
%      H = MATSURF returns the handle to a new MATSURF or the handle to
%      the existing singleton*.
%
%      MATSURF('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in MATSURF.M with the given input arguments.
%
%      MATSURF('Property','Value',...) creates a new MATSURF or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before matSurf_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to matSurf_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help matSurf

% Last Modified by GUIDE v2.5 12-Jul-2018 10:02:06

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @matSurf_OpeningFcn, ...
                   'gui_OutputFcn',  @matSurf_OutputFcn, ...
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
% End initialization code - DO NOT EDIT

%--------------------------------------------------------------------------
% opening properties

% --- Executes just before matSurf is made visible.
function matSurf_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to matSurf (see VARARGIN)

% make sure freesurfer on the path
if ~exist('read_surf','file')
    addpath('/usr/local/freesurfer/matlab');
end

% add all subfunctions to path as well
if ~exist('load_fsSurface','file')
    addpath(genpath('/storage/Matlab_Visualisation/V2'));
end

% initialise the default colormaps
create_default_cmap(hObject);



% Choose default command line output for matSurf
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes matSurf wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = matSurf_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

%--------------------------------------------------------------------------
% surface panel

% --- Executes on button press in loadSurf.
function loadSurf_Callback(hObject, eventdata, handles)
% hObject    handle to loadSurf (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% set SUBJECTS_DIR and surface properties (todo -make this user input)
setappdata(hObject,'SUBJECTS_DIR','/home/richard/storage/Matlab_Visualisation/Data/R3517');
hemi = 'rh';
surfType = 'inflated';

% load the surface
load_fsSurface(hObject,hemi,surfType);

% load the corresponding curvature data
load_fsCurve(hObject,hemi);

% create the base overlay
sulcusCol = 0.4; % color for sulcus, can be triplet ([R,G,B]) or single value for grayscale
gyrusCol = 0.8;  % color for gyrus
curveOverlay(hObject,sulcusCol,gyrusCol);

% display it
hold(handles.brainSurface,'off');
display_fsSurface(hObject);
hold(handles.brainSurface,'on');

% --- Executes during object creation, after setting all properties.
function loadSurf_CreateFcn(hObject, eventdata, handles)
% hObject    handle to loadSurf (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

%--------------------------------------------------------------------------
% data panel

% --- Executes on button press in loadData.
function loadData_Callback(hObject, eventdata, handles)
% hObject    handle to loadData (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% --- Executes on selection change in selectData.
function selectData_Callback(hObject, eventdata, handles)
% hObject    handle to selectData (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns selectData contents as cell array
%        contents{get(hObject,'Value')} returns selected item from selectData


% --- Executes during object creation, after setting all properties.
function selectData_CreateFcn(hObject, eventdata, handles)
% hObject    handle to selectData (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on button press in showData.
function showData_Callback(hObject, eventdata, handles)
% hObject    handle to showData (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of showData

%--------------------------------------------------------------------------
% ROI panel

% --- Executes on button press in CreateROI.
function CreateROI_Callback(hObject, eventdata, handles)
% hObject    handle to CreateROI (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% --- Executes on button press in deleteROI.
function deleteROI_Callback(hObject, eventdata, handles)
% hObject    handle to deleteROI (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


%--------------------------------------------------------------------------
% camera panel

% --- Executes on button press in camRotate.
function camRotate_Callback(hObject, eventdata, handles)
% hObject    handle to camRotate (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of camRotate


% --- Executes on button press in camTrans.
function camTrans_Callback(hObject, eventdata, handles)
% hObject    handle to camTrans (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of camTrans


% --- Executes on button press in camZoom.
function camZoom_Callback(hObject, eventdata, handles)
% hObject    handle to camZoom (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of camZoom


% --- Executes on mouse press over axes background.
function brainSurface_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to brainSurface (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

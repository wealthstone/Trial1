function varargout = Mat_to_Octave(varargin)
% MAT_TO_OCTAVE MATLAB code for Mat_to_Octave.fig
%      MAT_TO_OCTAVE, by itself, creates a new MAT_TO_OCTAVE or raises the existing
%      singleton*.
%
%      H = MAT_TO_OCTAVE returns the handle to a new MAT_TO_OCTAVE or the handle to
%      the existing singleton*.
%
%      MAT_TO_OCTAVE('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in MAT_TO_OCTAVE.M with the given input arguments.
%
%      MAT_TO_OCTAVE('Property','Value',...) creates a new MAT_TO_OCTAVE or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before Mat_to_Octave_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to Mat_to_Octave_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help Mat_to_Octave

% Last Modified by GUIDE v2.5 07-Nov-2017 14:25:31

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @Mat_to_Octave_OpeningFcn, ...
                   'gui_OutputFcn',  @Mat_to_Octave_OutputFcn, ...
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


% --- Executes just before Mat_to_Octave is made visible.
function Mat_to_Octave_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to Mat_to_Octave (see VARARGIN)

% Choose default command line output for Mat_to_Octave
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes Mat_to_Octave wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = Mat_to_Octave_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in Gen_Rand.
function Gen_Rand_Callback(hObject, eventdata, handles)
% hObject    handle to Gen_Rand (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
Random=rand(10,10)*100;
%Random=num2str(Random);
Random_Table=array2table(Random);
set(handles.Disp_Rand,'data',Random_Table{:,:},'columnname',Random_Table.Properties.VariableNames)

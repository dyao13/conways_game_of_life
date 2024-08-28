function varargout = gui(varargin)
% GUI MATLAB code for gui.fig
%      GUI, by itself, creates a new GUI or raises the existing
%      singleton*.
%
%      H = GUI returns the handle to a new GUI or the handle to
%      the existing singleton*.
%
%      GUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in GUI.M with the given input arguments.
%
%      GUI('Property','Value',...) creates a new GUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before gui_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to gui_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help gui

% Last Modified by GUIDE v2.5 17-Jan-2024 14:40:05

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @gui_OpeningFcn, ...
                   'gui_OutputFcn',  @gui_OutputFcn, ...
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


% --- Executes just before gui is made visible.
function gui_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to gui (see VARARGIN)

% Choose default command line output for gui
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% set default values
setappdata(handles.stop_radiobutton, 'stop_status', 0);
setappdata(handles.playstop_togglebutton, 'play_status', 0);
setappdata(handles.framerate_popupmenu, 'frame_rate', 30);
setappdata(handles.generations_popupmenu, 'num_gens', 1023);

% UIWAIT makes gui wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = gui_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in importrle_pushbutton.
function importrle_pushbutton_Callback(hObject, eventdata, handles)

% read RLE file
file_name = getappdata(handles.inputfilename_edit, 'file_name');
A = RLE_decoder(file_name);

% pad array
A = padarray(A, [16, 16]);

% set inital matrix
setappdata(handles.loadmatrix_pushbutton, 'A0', A);

function inputfilename_edit_Callback(hObject, eventdata, handles)

% read file name; set file name
file_name = get(handles.inputfilename_edit, 'String');
setappdata(handles.inputfilename_edit, 'file_name', file_name);

% --- Executes during object creation, after setting all properties.
function inputfilename_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to inputfilename_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in generaterandommatrix_pushbutton.
function generaterandommatrix_pushbutton_Callback(hObject, eventdata, handles)

% set initial matrix to be random 64x64
A = randi([0, 1], 64);
setappdata(handles.loadmatrix_pushbutton, 'A0', A);

% name intial matrix to be 'soup'
setappdata(handles.inputfilename_edit, 'file_name', 'soup.rle');

% --- Executes on button press in loadmatrix_pushbutton.
function loadmatrix_pushbutton_Callback(hObject, eventdata, handles)

% set generation number = 0
setappdata(handles.loadmatrix_pushbutton, 'gen', 0);

% get initial matrix
A0 = getappdata(handles.loadmatrix_pushbutton, 'A0');
setappdata(handles.loadmatrix_pushbutton, 'A', A0);
A = getappdata(handles.loadmatrix_pushbutton, 'A');

% plot figure and title
axes(handles.axes)
mat2fig(A);
file_name = getappdata(handles.inputfilename_edit, 'file_name');
gen = getappdata(handles.loadmatrix_pushbutton, 'gen');
title_name = [file_name(1:end-4), ' generation ' num2str(gen)];
title(title_name);

% --- Executes on button press in step_pushbutton.
function step_pushbutton_Callback(hObject, eventdata, handles)

if getappdata(handles.stop_radiobutton, 'stop_status') ~= 1
    % get current matrix; update matrix; set new matrix
    A = getappdata(handles.loadmatrix_pushbutton, 'A');
    B = GOL(A);
    setappdata(handles.loadmatrix_pushbutton, 'A', B);
    
    % update generation number
    gen = getappdata(handles.loadmatrix_pushbutton, 'gen');
    gen = gen + 1;

    % plot figure and title
    axes(handles.axes);
    mat2fig(B);
    file_name = getappdata(handles.inputfilename_edit, 'file_name');
    setappdata(handles.loadmatrix_pushbutton, 'gen', gen);
    title_name = [ file_name(1:end-4), ' generation ' num2str(gen) ];
    title(title_name);
end

% --- Executes on button press in playstop_togglebutton.
function playstop_togglebutton_Callback(hObject, eventdata, handles)

if getappdata(handles.stop_radiobutton, 'stop_status') ~= 1
    % toggle play status on/off
    setappdata(handles.playstop_togglebutton, 'play_status', ~getappdata(handles.playstop_togglebutton, 'play_status'));

    % process outside of if play_stop toggle if statement to prevent errors;
    % get file name, generation number, and current matrix
    file_name = getappdata(handles.inputfilename_edit, 'file_name');
    file_name = file_name(1:end-4);
    gen = getappdata(handles.loadmatrix_pushbutton, 'gen');
    A = getappdata(handles.loadmatrix_pushbutton, 'A');

    % get frame rate and number of generations to run
    axes(handles.axes);
    frame_rate = getappdata(handles.framerate_popupmenu, 'frame_rate');
    num_gens = getappdata(handles.generations_popupmenu, 'num_gens');
    max_gen = gen + num_gens;

    % give intial guess for frame delay to prevent errors
    frame_delay = 1 / frame_rate - 0.03;

    if get(handles.playstop_togglebutton, 'Value') ~= 0
            
        % time compute time for one frame
        tic;

        % update matrix and generation number; plot figure and title
        A = GOL(A);
        mat2fig(A);
        gen = gen + 1;
        title([file_name, ' generation ' num2str(gen)])

        time = toc;
        
        % set delay time to match frame rate;
        % if compute time is slower than one frame, then run as fast as possible
        if time < 1/frame_rate
            frame_delay = 1 / frame_rate - time;
        else
            frame_delay = 0;
        end
    end

    % loop until number of generations is reached
    % or until the play/stop toggle button or stop radio button is pressed
    while gen < max_gen && getappdata(handles.playstop_togglebutton, 'play_status') == 1
        % update matrix and generation number; plot figure and title
        A = GOL(A);
        mat2fig(A);
        gen = gen + 1;
        title([file_name, ' generation ' num2str(gen)])

        % pause to match frame rate
        pause(frame_delay);
    end
    
    % set current matrix and current generation number
    setappdata(handles.loadmatrix_pushbutton, 'A', A);
    setappdata(handles.loadmatrix_pushbutton, 'gen', gen);
end

% --- Executes on selection change in framerate_popupmenu.
function framerate_popupmenu_Callback(hObject, eventdata, handles)

% read frame rate
options = cellstr(get(handles.framerate_popupmenu, 'String'));
raw_string = options{get(handles.framerate_popupmenu, 'Value')};
frame_rate = str2double(regexp(raw_string, '\d+', 'match'));

% if frame rate is not a number (ie., 'Frame Rate'), then choose 30 fps
if isempty(frame_rate)
    frame_rate = 30;
end

% set frame rate
setappdata(handles.framerate_popupmenu, 'frame_rate', frame_rate);

% --- Executes during object creation, after setting all properties.
function framerate_popupmenu_CreateFcn(hObject, eventdata, handles)
% hObject    handle to framerate_popupmenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in generations_popupmenu.
function generations_popupmenu_Callback(hObject, eventdata, handles)

% read number of generations
options = cellstr(get(handles.generations_popupmenu, 'String'));
raw_string = options{get(handles.generations_popupmenu, 'Value')};
num_gens = str2double(regexp(raw_string, '\d+', 'match'));

% if number of generations is not a number (ie., 'Generations'), then choose 1023 generations
if isempty(num_gens)
    num_gens = 1023;
end

% set number of generations
setappdata(handles.generations_popupmenu, 'num_gens', num_gens);

% --- Executes during object creation, after setting all properties.
function generations_popupmenu_CreateFcn(hObject, eventdata, handles)
% hObject    handle to generations_popupmenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in stop_radiobutton.
function stop_radiobutton_Callback(hObject, eventdata, handles)

% toggle stop status
stop_status = get(handles.stop_radiobutton, 'Value');
setappdata(handles.stop_radiobutton, 'stop_status', stop_status);

% change play status to stop play/stop
setappdata(handles.playstop_togglebutton, 'play_status', 0);

% --- Executes on button press in exportmovie_pushbutton.
function exportmovie_pushbutton_Callback(hObject, eventdata, handles)

if getappdata(handles.stop_radiobutton, 'stop_status') ~= 1
    % get matrix, generation number, frame rate, number of generations and file name
    A = getappdata(handles.loadmatrix_pushbutton, 'A');
    gen = getappdata(handles.loadmatrix_pushbutton, 'gen');
    frame_rate = getappdata(handles.framerate_popupmenu, 'frame_rate');
    num_gens = getappdata(handles.generations_popupmenu, 'num_gens');
    file_name = getappdata(handles.inputfilename_edit, 'file_name');
    file_name = file_name(1:end-4);
    
    % convert frame rate and last generation to strings for title
    fr = num2str(frame_rate);
    last_gen = num2str(gen+num_gens);
    
    % create movie title
    movie_name = getappdata(handles.inputfilename_edit, 'file_name');
    movie_name = convertStringsToChars(movie_name);
    movie_name = [ movie_name(1:end-4),'_gens', num2str(gen), '-', last_gen, '_', fr, 'fps.mp4' ];
    
    axes(handles.axes);
    
    % create VideoWriter object to write to mp4 file
    vidObj = VideoWriter(movie_name, 'MPEG-4');
    vidObj.FrameRate = frame_rate;
    
    capturePos = [325, 100, 350, 300];
    
    open(vidObj);
    
    % write frame 0
    mat2fig(A);
    title([ file_name, ' generation ' num2str(gen) ])
    frame = getframe(gcf, capturePos);
    writeVideo(vidObj, frame);
    gen = gen + 1;
    
    % write frame 1 - frame num_evo
    for i = 1:num_gens
        % stop if stop radio button is pressed
        if getappdata(handles.stop_radiobutton, 'stop_status') == 1
            special = 1;
            break
        end

        % update matrix; plot figure and title
        A = GOL(A);
        mat2fig(A);
        title([file_name, ' generation ' num2str(gen)])

        % write frame
        frame = getframe(gcf, capturePos);
        writeVideo(vidObj, frame);

        % update generation number
        gen = gen + 1;
    end
    
    close(vidObj);

    % rename movie file if stopped prematurely
    new_name = getappdata(handles.inputfilename_edit, 'file_name');
    new_name = convertStringsToChars(new_name);
    new_name = [ new_name(1:end-4),'_gens', num2str(getappdata(handles.loadmatrix_pushbutton, 'gen')), '-', num2str(gen), '_', fr, 'fps.mp4' ];
    status = movefile(movie_name, new_name);
    
    % set new matrix and generation number
    setappdata(handles.loadmatrix_pushbutton, 'A', A);
    setappdata(handles.loadmatrix_pushbutton, 'gen', gen);
end

% --- Executes on button press in clear_pushbutton.
function clear_pushbutton_Callback(hObject, eventdata, handles)

% stop simulation
setappdata(handles.playstop_togglebutton, 'play_status', 0);

% plot default plot
axes(handles.axes);
mat2fig([1, 1, 1, 0]);
xlim([0, 1]);
ylim([0, 1]);

% clear matrix and generation number
A = [];
setappdata(handles.loadmatrix_pushbutton, 'A', A);
setappdata(handles.loadmatrix_pushbutton, 'gen', 0);

% --- Executes on button press in exportframe_pushbutton.
function exportframe_pushbutton_Callback(hObject, eventdata, handles)

% get file_name; create image name
file_name = getappdata(handles.inputfilename_edit, 'file_name');
gen = getappdata(handles.loadmatrix_pushbutton, 'gen');
gen = num2str(gen);
image_name = [ file_name(1:end-4), '_gen', gen, '.png' ];

% save image as png file
exportgraphics(handles.axes, image_name);;

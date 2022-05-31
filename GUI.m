function varargout = GUI(varargin)

gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @GUI_OpeningFcn, ...
                   'gui_OutputFcn',  @GUI_OutputFcn, ...
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


% --- Executes just before GUI is made visible.
function GUI_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to GUI (see VARARGIN)

% Choose default command line output for GUI
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes GUI wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% ������������ʱ����һЩ�ؼ�
% set(handles.axes1,'visible','off');
% set(handles.text1,'visible','off');


% --- Outputs from this function are returned to the commandline.
function varargout = GUI_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in openvideo_button.
function openvideo_button_Callback
% hObject    handle to openvideo_button (see GCBO)(hObject, eventdata, handles)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% ��ȡ��Ƶ·��
[filename,pathname,filter] = uigetfile({'*.mp4;*.flv;*.avi;*.rmvb;*.f4v;*.mpeg;*.mkv'},'ѡ����Ƶ');
if filter == 0
    return
end
str = fullfile(pathname,filename);

% ��ȡ��Ƶ
filename = str;

% obj��һ������  
obj = VideoReader(filename);  
% ��Ƶ�ĵ�һ֡Ԥ����ʾ�ڽ���
Show_Frames=read(obj,1);

axes(handles.axes1);
imshow(Show_Frames);
set(handles.axes1,'visible','on');
axis off

% ��ʾtext1������
set(handles.text1,'String','��ʶ�����Ƶ');
set(handles.text1,'visible','on');

% ��obj�洢Ϊȫ�ֿؼ����õı���,setappdata��������
setappdata(0,'obj',obj);

% ����ȫ�ֿ��Ʊ���
global indicate_loop;
indicate_loop=1;


% --- Executes on button press in recog_button.
function recog_button_Callback(hObject, eventdata, handles)
% hObject    handle to recog_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% ��ȡobj
obj=getappdata(0,'obj');

% ��ȡ��Ƶ����
numFrames = obj.NumberOfFrames;
Framerate=obj.FrameRate; 
Height=obj.Height;
Width=obj.Width;

global indicate_loop;
indicate_loop=0;

%% ʶ����沿��

% ����Ƶ֡����
a1=str2num(get(handles.edit1,'String'));
a2=str2num(get(handles.edit2,'String'));
for i=a1:a2%numFrames
    original=read(obj,i);% ԭͼ
    R = original(:,:,1);  %  ��ȡRֵ�ľ���
    if max(max(R)) >120
        [m,n,s]=size(original);
        for i=1:m
            for j=1:n
                if original(i,j,1)<=190 
                    original(i,j,1)=0;
                    original(i,j,2)=0;
                    original(i,j,3)=0;
                end
                if original(i,j,1)<original(i,j,2)
                    original(i,j,1)=0;
                    original(i,j,2)=0;
                    original(i,j,3)=0;
                end
                if original(i,j,2)<original(i,j,3)
                    original(i,j,1)=0;
                    original(i,j,2)=0;
                    original(i,j,3)=0;
                end
                original(i,j,3)=0;
            end
        end
        
        axes(handles.axes4);
        imshow(original); 

        original_hsv = RGB2HSI(original); %��ͼ����д�RGB��HSI��ת���ָ�
        axes(handles.axes3);
        imshow(original_hsv);
        
        % ��ͼ��ת��Ϊ������ͼ��
        thresh = graythresh(original_hsv);   %�Զ�ȷ����ֵ����ֵ
        A = im2bw(original,thresh);     % thresh=0.5 ��ʾ���Ҷ���128���±�Ϊ��ɫ��128���ϵı�Ϊ��ɫ
        % �������
        se = strel('disk',2); 
        A = imclose(A,se); 
        % ��ʾת�������Ʋ���������ͼ��
        axes(handles.axes5);
        imshow(A);
        % ʹ����ֵ�˲�����ͼ�����ƽ������
        k=medfilt2(A,[9,9]);  % ��ͼ�������ֵ�˲� ��ͼ�����ƽ������
        % ��ʾ��ֵ�˲�ƽ������֮���ͼ��
        axes(handles.axes6);
        imshow(k);
        %��պ�ͼ�Σ����ɫΪ��ɫ
        k  = imfill(k,'holes');
        %�߽�Ѱ��
        [B,L] = bwboundaries(k,'noholes');
        % Ϊÿ���պ�ͼ��������ɫ��ʾ
        axes(handles.axes7)
        imshow(label2rgb(L, @jet, [.5 .5 .5]))
    %     for k = 1:length(B)
    %         boundary = B{k};
    %         plot(boundary(:,2), boundary(:,1), 'w', 'LineWidth', 2)
    %     end
        %�������
        stats = regionprops(L,'Area','Centroid');
        threshold = 0.6;
        set(handles.edit6,'String',length(B));
        % ѭ������ÿ���߽磬length(B)�Ǳպ�ͼ�εĸ���,����⵽�������������
        for i = 1:length(B)  % ��ȡ�߽�����
            boundary = B{i}; % �����ܳ�
            delta_sq = diff(boundary).^2;
            perimeter = sum(sqrt(sum(delta_sq,2))); 
            % �Ա��ΪK�Ķ����ȡ���
            area = stats(i).Area;  
            % Բ�ȼ��㹫ʽ4*PI*A/P^2
            metric = 4*pi*area/perimeter^2;
        end
        % �����ʾ
        if find(metric < threshold)
            set(handles.edit4,'String','�л���');
            metric_string = sprintf('%2.2f',min(metric)); 
            set(handles.edit3,'String',metric_string);
        else
            set(handles.edit4,'String','�޻���');
            set(handles.edit3,'String',[]);
        end
    else
        set(handles.text21,'String',sprintf('���ʶ���޻���'));
    end

end
fprintf('�������...\n');
% ��ʾtext1������
set(handles.text1,'String',sprintf('���ʶ�����'));
set(handles.text1,'visible','on');


% --- Executes on button press in quit_button.
function quit_button_Callback(hObject, eventdata, handles)
% hObject    handle to quit_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



function edit1_Callback(hObject, eventdata, handles)
% hObject    handle to edit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit1 as text
%        str2double(get(hObject,'String')) returns contents of edit1 as a double


% --- Executes during object creation, after setting all properties.
function edit1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit2_Callback(hObject, eventdata, handles)
% hObject    handle to edit2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit2 as text
%        str2double(get(hObject,'String')) returns contents of edit2 as a double


% --- Executes during object creation, after setting all properties.
function edit2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit3_Callback(hObject, eventdata, handles)
% hObject    handle to edit3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit3 as text
%        str2double(get(hObject,'String')) returns contents of edit3 as a double


% --- Executes during object creation, after setting all properties.
function edit3_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit4_Callback(hObject, eventdata, handles)
% hObject    handle to edit4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit4 as text
%        str2double(get(hObject,'String')) returns contents of edit4 as a double


% --- Executes during object creation, after setting all properties.
function edit4_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in openpicture_button.
function openpicture_button_Callback(hObject, eventdata, handles)
% hObject    handle to openpicture_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% ��ȡͼƬ·��
[filename,pathname,filter] = uigetfile({'*.bmp;*.jpg;*.png;*.svg'},'ѡ��ͼƬ');
if filter == 0
    return
end
% ���������ļ���
str = fullfile(pathname,filename);

% ��ȡͼƬ
filename = str;
picture = imread(filename);  
% ��ԭͼ��ʾ��GUI��
axes(handles.axes10);
imshow(picture);
set(handles.axes1,'visible','on');

% ��ʾtext21������
set(handles.text21,'String','��ʶ���ͼƬ');
set(handles.text21,'visible','on');

% ��obj�洢Ϊȫ�ֿؼ����õı���,setappdata��������
setappdata(0,'picture',picture);

% ����ȫ�ֿ��Ʊ���
global indicate_loop;
indicate_loop=1;


% --- Executes on button press in recogpicture_button.
function recogpicture_button_Callback(hObject, eventdata, handles)
% hObject    handle to recogpicture_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% ��ȡͼƬ
picture=getappdata(0,'picture');

global indicate_loop;
indicate_loop=0;

%% ʶ����沿��

original=picture;% ԭͼ
R = original(:,:,1);  %  ��ȡRֵ�ľ���
if max(max(R)) > 120
    set(handles.text21,'String',sprintf('���ʶ�������л���'));
    [m,n,s]=size(original);
    for i=1:m
        for j=1:n
            if original(i,j,1)<=190 
                original(i,j,1)=0;
                original(i,j,2)=0;
                original(i,j,3)=0;
            end
            if original(i,j,1)<original(i,j,2)
                original(i,j,1)=0;
                original(i,j,2)=0;
                original(i,j,3)=0;
            end
            if original(i,j,3)<original(i,j,3)
                original(i,j,1)=0;
                original(i,j,2)=0;
                original(i,j,3)=0;
            end
            original(i,j,3)=0;
        end
    end

    axes(handles.axes4);
    imshow(original); 

    original_hsv = RGB2HSI(original); %��ͼ����д�RGB��HSI��ת���ָ�
    axes(handles.axes3);
    imshow(original_hsv);

    % ��ͼ��ת��Ϊ������ͼ��
    thresh = graythresh(original_hsv);   %�Զ�ȷ����ֵ����ֵ
    A = im2bw(original,thresh);     % thresh=0.5 ��ʾ���Ҷ���128���±�Ϊ��ɫ��128���ϵı�Ϊ��ɫ
    % �������
    se = strel('disk',2); 
    A = imclose(A,se); 
    % ��ʾת�������Ʋ���������ͼ��
    axes(handles.axes5);
    imshow(A);
    % ʹ����ֵ�˲�����ͼ�����ƽ������
    k=medfilt2(A,[9,9]);  % ��ͼ�������ֵ�˲� ��ͼ�����ƽ������
    % ��ʾ��ֵ�˲�ƽ������֮���ͼ��
    axes(handles.axes6);
    imshow(k);
    %��պ�ͼ�Σ����ɫΪ��ɫ
    k  = imfill(k,'holes');
    %�߽�Ѱ��
    [B,L] = bwboundaries(k,'noholes');
    % Ϊÿ���պ�ͼ��������ɫ��ʾ
    axes(handles.axes7)
    imshow(label2rgb(L, @jet, [.5 .5 .5]))
    %     for k = 1:length(B)
    %         boundary = B{k};
    %         plot(boundary(:,2), boundary(:,1), 'w', 'LineWidth', 2)
    %     end
    %�������
    stats = regionprops(L,'Area','Centroid');
    threshold = 0.6;% ѭ������ÿ���߽磬length(B)�Ǳպ�ͼ�εĸ���,����⵽�������������
    set(handles.edit6,'String',length(B));
    for i = 1:length(B)  % ��ȡ�߽�����'
        boundary = B{i}; % �����ܳ�
        delta_sq = diff(boundary).^2;
        perimeter = sum(sqrt(sum(delta_sq,2))); 
        % �Ա��Ϊi�Ķ����ȡ���
        area = stats(i).Area;  
        % Բ�ȼ��㹫ʽ4*PI*A/P^2
        metric(i) = 4*pi*area/perimeter^2;
    end
    % �����ʾ
    if find(metric < threshold)
        set(handles.edit4,'String','�л���');
        metric_string = sprintf('%2.2f',min(metric)); 
        set(handles.edit3,'String',metric_string);
    else
        set(handles.edit4,'String','�޻���');
        set(handles.edit3,'String',[]);
    end
else
    set(handles.text21,'String',sprintf('���ʶ���޻���'));
end
fprintf('�������...\n');
% ��ʾtext1������
set(handles.text21,'String',sprintf('���ʶ�����'));
set(handles.text21,'visible','on');



function edit6_Callback(hObject, eventdata, handles)
% hObject    handle to edit6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit6 as text
%        str2double(get(hObject,'String')) returns contents of edit6 as a double


% --- Executes during object creation, after setting all properties.
function edit6_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

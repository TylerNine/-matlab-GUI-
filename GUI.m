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


% 在运行主界面时隐藏一些控件
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

% 读取视频路径
[filename,pathname,filter] = uigetfile({'*.mp4;*.flv;*.avi;*.rmvb;*.f4v;*.mpeg;*.mkv'},'选择视频');
if filter == 0
    return
end
str = fullfile(pathname,filename);

% 读取视频
filename = str;

% obj是一个对象  
obj = VideoReader(filename);  
% 视频的第一帧预览显示在界面
Show_Frames=read(obj,1);

axes(handles.axes1);
imshow(Show_Frames);
set(handles.axes1,'visible','on');
axis off

% 显示text1的内容
set(handles.text1,'String','待识别的视频');
set(handles.text1,'visible','on');

% 将obj存储为全局控件可用的变量,setappdata函数保持
setappdata(0,'obj',obj);

% 设置全局控制变量
global indicate_loop;
indicate_loop=1;


% --- Executes on button press in recog_button.
function recog_button_Callback(hObject, eventdata, handles)
% hObject    handle to recog_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% 获取obj
obj=getappdata(0,'obj');

% 获取视频参数
numFrames = obj.NumberOfFrames;
Framerate=obj.FrameRate; 
Height=obj.Height;
Width=obj.Width;

global indicate_loop;
indicate_loop=0;

%% 识别火焰部分

% 对视频帧处理
a1=str2num(get(handles.edit1,'String'));
a2=str2num(get(handles.edit2,'String'));
for i=a1:a2%numFrames
    original=read(obj,i);% 原图
    R = original(:,:,1);  %  提取R值的矩阵
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

        original_hsv = RGB2HSI(original); %对图像进行从RGB到HSI的转换分割
        axes(handles.axes3);
        imshow(original_hsv);
        
        % 将图像转换为二进制图像
        thresh = graythresh(original_hsv);   %自动确定二值化阈值
        A = im2bw(original,thresh);     % thresh=0.5 表示将灰度在128以下变为黑色，128以上的变为白色
        % 消除噪点
        se = strel('disk',2); 
        A = imclose(A,se); 
        % 显示转换二进制并消除噪点的图像
        axes(handles.axes5);
        imshow(A);
        % 使用中值滤波法对图像进行平滑处理
        k=medfilt2(A,[9,9]);  % 将图像进行中值滤波 对图像进行平滑处理
        % 显示中值滤波平滑处理之后的图像
        axes(handles.axes6);
        imshow(k);
        %填补闭合图形，填充色为白色
        k  = imfill(k,'holes');
        %边界寻找
        [B,L] = bwboundaries(k,'noholes');
        % 为每个闭合图形设置颜色显示
        axes(handles.axes7)
        imshow(label2rgb(L, @jet, [.5 .5 .5]))
    %     for k = 1:length(B)
    %         boundary = B{k};
    %         plot(boundary(:,2), boundary(:,1), 'w', 'LineWidth', 2)
    %     end
        %计算面积
        stats = regionprops(L,'Area','Centroid');
        threshold = 0.6;
        set(handles.edit6,'String',length(B));
        % 循环处理每个边界，length(B)是闭合图形的个数,即检测到的陶粒对象个数
        for i = 1:length(B)  % 获取边界坐标
            boundary = B{i}; % 计算周长
            delta_sq = diff(boundary).^2;
            perimeter = sum(sqrt(sum(delta_sq,2))); 
            % 对标记为K的对象获取面积
            area = stats(i).Area;  
            % 圆度计算公式4*PI*A/P^2
            metric = 4*pi*area/perimeter^2;
        end
        % 结果显示
        if find(metric < threshold)
            set(handles.edit4,'String','有火焰');
            metric_string = sprintf('%2.2f',min(metric)); 
            set(handles.edit3,'String',metric_string);
        else
            set(handles.edit4,'String','无火焰');
            set(handles.edit3,'String',[]);
        end
    else
        set(handles.text21,'String',sprintf('检测识别无火焰'));
    end

end
fprintf('处理完毕...\n');
% 显示text1的内容
set(handles.text1,'String',sprintf('检测识别完毕'));
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
% 读取图片路径
[filename,pathname,filter] = uigetfile({'*.bmp;*.jpg;*.png;*.svg'},'选择图片');
if filter == 0
    return
end
% 构建完整文件名
str = fullfile(pathname,filename);

% 读取图片
filename = str;
picture = imread(filename);  
% 将原图显示在GUI上
axes(handles.axes10);
imshow(picture);
set(handles.axes1,'visible','on');

% 显示text21的内容
set(handles.text21,'String','待识别的图片');
set(handles.text21,'visible','on');

% 将obj存储为全局控件可用的变量,setappdata函数保持
setappdata(0,'picture',picture);

% 设置全局控制变量
global indicate_loop;
indicate_loop=1;


% --- Executes on button press in recogpicture_button.
function recogpicture_button_Callback(hObject, eventdata, handles)
% hObject    handle to recogpicture_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% 获取图片
picture=getappdata(0,'picture');

global indicate_loop;
indicate_loop=0;

%% 识别火焰部分

original=picture;% 原图
R = original(:,:,1);  %  提取R值的矩阵
if max(max(R)) > 120
    set(handles.text21,'String',sprintf('检测识别疑似有火焰'));
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

    original_hsv = RGB2HSI(original); %对图像进行从RGB到HSI的转换分割
    axes(handles.axes3);
    imshow(original_hsv);

    % 将图像转换为二进制图像
    thresh = graythresh(original_hsv);   %自动确定二值化阈值
    A = im2bw(original,thresh);     % thresh=0.5 表示将灰度在128以下变为黑色，128以上的变为白色
    % 消除噪点
    se = strel('disk',2); 
    A = imclose(A,se); 
    % 显示转换二进制并消除噪点的图像
    axes(handles.axes5);
    imshow(A);
    % 使用中值滤波法对图像进行平滑处理
    k=medfilt2(A,[9,9]);  % 将图像进行中值滤波 对图像进行平滑处理
    % 显示中值滤波平滑处理之后的图像
    axes(handles.axes6);
    imshow(k);
    %填补闭合图形，填充色为白色
    k  = imfill(k,'holes');
    %边界寻找
    [B,L] = bwboundaries(k,'noholes');
    % 为每个闭合图形设置颜色显示
    axes(handles.axes7)
    imshow(label2rgb(L, @jet, [.5 .5 .5]))
    %     for k = 1:length(B)
    %         boundary = B{k};
    %         plot(boundary(:,2), boundary(:,1), 'w', 'LineWidth', 2)
    %     end
    %计算面积
    stats = regionprops(L,'Area','Centroid');
    threshold = 0.6;% 循环处理每个边界，length(B)是闭合图形的个数,即检测到的陶粒对象个数
    set(handles.edit6,'String',length(B));
    for i = 1:length(B)  % 获取边界坐标'
        boundary = B{i}; % 计算周长
        delta_sq = diff(boundary).^2;
        perimeter = sum(sqrt(sum(delta_sq,2))); 
        % 对标记为i的对象获取面积
        area = stats(i).Area;  
        % 圆度计算公式4*PI*A/P^2
        metric(i) = 4*pi*area/perimeter^2;
    end
    % 结果显示
    if find(metric < threshold)
        set(handles.edit4,'String','有火焰');
        metric_string = sprintf('%2.2f',min(metric)); 
        set(handles.edit3,'String',metric_string);
    else
        set(handles.edit4,'String','无火焰');
        set(handles.edit3,'String',[]);
    end
else
    set(handles.text21,'String',sprintf('检测识别无火焰'));
end
fprintf('处理完毕...\n');
% 显示text1的内容
set(handles.text21,'String',sprintf('检测识别完毕'));
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

function Image1=RGB2HSI(image)
%调用代码-------------------------------------------
%imageR=imread('animal.jpg');  
%RGB2HSI(image);
%--------------------------------------------------

image=im2double(image);
%从三维数组中提取三幅分量图像
R1=image(:,:,1);
G1=image(:,:,2);
B1=image(:,:,3);
I=(R1+G1+B1)/3;        %亮度分量，范围[0,1]
m=min(min(R1,G1),B1);
S=1-3*m./(R1+G1+B1);    %饱和度分量，范围[0,1]
theta=acos(((R1-G1)+(R1-B1))./(2*((R1-G1).^2+((R1-B1).*(G1-B1))).^(1/2))); %弧度 
H=theta;   %色度分量，以角度表示，范围是[0,1]（弧度除以2*pi后）
if B1>G1
    H=2*pi-theta;       
end     
if S==0
    H=0;
end
H=H/(2*pi);
Image1=cat(3,H,S,I);
% subplot(1,2,1),imshow(image);
% title('RGB原图')
% subplot(1,2,2),imshow(Image1);
% title('转换后的HSI图像')
end

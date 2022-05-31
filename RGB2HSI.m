function Image1=RGB2HSI(image)
%���ô���-------------------------------------------
%imageR=imread('animal.jpg');  
%RGB2HSI(image);
%--------------------------------------------------

image=im2double(image);
%����ά��������ȡ��������ͼ��
R1=image(:,:,1);
G1=image(:,:,2);
B1=image(:,:,3);
I=(R1+G1+B1)/3;        %���ȷ�������Χ[0,1]
m=min(min(R1,G1),B1);
S=1-3*m./(R1+G1+B1);    %���Ͷȷ�������Χ[0,1]
theta=acos(((R1-G1)+(R1-B1))./(2*((R1-G1).^2+((R1-B1).*(G1-B1))).^(1/2))); %���� 
H=theta;   %ɫ�ȷ������ԽǶȱ�ʾ����Χ��[0,1]�����ȳ���2*pi��
if B1>G1
    H=2*pi-theta;       
end     
if S==0
    H=0;
end
H=H/(2*pi);
Image1=cat(3,H,S,I);
% subplot(1,2,1),imshow(image);
% title('RGBԭͼ')
% subplot(1,2,2),imshow(Image1);
% title('ת�����HSIͼ��')
end

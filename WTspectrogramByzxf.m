function [ my_spectrogram ] = WTspectrogramByzxf(frame , fs, wavename)
%WTspectrogramByzxf�� �������źŵ�Ƶ��ͼͨ��С���任�ķ�ʽ����
%   frame ������ź�֡
%   fs ������źŲ�����
%   wavename С������
if nargin<1, selfdemo; return; end
if nargin<2, fs=16000; end
if nargin<3, wavename='cmor3-3'; end
frameSize=length(frame);
totalscal=64/2; %�߶����еĳ��ȣ���scal�ĳ���
wcf=centfrq(wavename); %С��������Ƶ��
cparam=2*wcf*totalscal; %Ϊ�õ����ʵĳ߶�������Ĳ���
a=1:totalscal;
scal=cparam./a; %�õ������߶ȣ���ʹת���õ�Ƶ������Ϊ�Ȳ�����
Freq=scal2frq(scal,wavename,1/fs);
coefs=cwt(frame,scal,wavename);
PowerDb=20*log(abs(coefs));
frameTime=0:1/fs:(frameSize-1)/fs;
set(gcf,'Position',[20 100 600 500]);
my_spectrogram=mesh(frameTime,Freq,PowerDb);
view(0,90);
colormap(jet);axis xy;title('Ƶ��ͼ-С��');
ylabel('Ƶ��/Hz');xlabel('ʱ��/s');
end
% ====== Self demo
function selfdemo
waveFile='what_movies_have_you_seen_recently.wav';
[y, fs]=audioread(waveFile);
startIndex=12000;
frameSize=512;
frame=y(startIndex:startIndex+frameSize-1);wavename='cmor3-3';
WTspectrogramByzxf(frame , fs, wavename);
end


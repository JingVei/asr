function [epInSampleIndex, epInFrameIndex, soundSegment, zeroOneVec, frameVar] = epdByWaveletZXF(wObj, epdPrm, plotOpt)
% epdByWaveletZXF: 根据小波BARK子带方差来进行端点检测
%
%	Usage:
%		[epInSampleIndex, epInFrameIndex, soundSegment, zeroOneVec, frameVar] = epdByWaveletZXF(wObj, epdPrm, plotOpt)
%
%	Description:
%		[epInSampleIndex, epInFrameIndex, soundSegment, zeroOneVec, frameVar] = epdByWaveletZXF(wObj, epdPrm, plotOpt)
%			epInSampleIndex: two-element end-points in sample index
%			epInFrameIndex: two-element end-points in frame index
%			soundSegment: segment of voice activity
%			zeroOneVec: zero-one vector for each frame
%			frameVar: var
%			wObj: wave object
%			epdPrm: parameters for EPD
%			plotOpt: 0 for silence operation, 1 for plotting
%
%	Example:
%		waveFile='SingaporeIsAFinePlace.wav';
%		wObj = myAudioRead(waveFile);
%		epdPrm=epdPrmSet2Wavelet(wObj.fs);
%		plotOpt = 1;
%		[epInSampleIndex, epInFrameIndex, soundSegment] = epdByWaveletZXF(wObj, epdPrm, plotOpt);


if nargin<1, selfdemo; return; end
if ischar(wObj), wObj=myAudioRead(wObj); end	% 判断是否输入是路径
if nargin<2 || isempty(epdPrm), epdPrm=epdPrmSet2Wavelet(wObj.fs); end
if nargin<3, plotOpt=0; end

y=wObj.signal; fs=wObj.fs; nbits=wObj.nbits;
if size(y, 2)~=1, error('Wave is not mono!'); end

frameSize=epdPrm.frameSize;
overlap=epdPrm.overlap;
[C,L]=wavedec(y,epdPrm.num,epdPrm.Wname);% 离散小波分解
yl=wrcoef('d',C,L,epdPrm.Wname,epdPrm.num);% 重构信号
frameMat=buffer2(yl, frameSize, overlap);	% 分帧
frameNum=size(frameMat, 2);			% 帧数
frameVar=var(frameMat);

frameVar=frameVar/max(frameVar); 	% 归一化
temp=sort(frameVar);
index=round(frameNum*epdPrm.vhMinMaxPercentile/100); if index==0, index=1; end
vhMin=temp(index);
vhMax=temp(frameNum-index+1);			% To avoid unvoiced sounds
vhTh=(vhMax-vhMin)*epdPrm.vhRatio+vhMin;
%fprintf('vhMin=%g, vhMax=%g, vhTh=%g\n', vhMin, vhMax, vhTh);

epdPrm.fs=fs;
[epInSampleIndex, epInFrameIndex, soundSegment, zeroOneVec]=epdBySingleCurve(frameVar, epdPrm, 0);
%keyboard;

% ====== Plotting
if plotOpt==1
	subplot(3,1,1);
	time=(1:length(y))/fs;
	frameTime=frame2sampleIndex(1:frameNum, frameSize, overlap)/fs;
	plot(time, y);
	for i=1:length(soundSegment)
		line(frameTime(soundSegment(i).beginFrame)*[1 1], 2^nbits/2*[-1, 1], 'color', 'g');
		line(frameTime(soundSegment(i).endFrame)*[1 1], 2^nbits/2*[-1, 1], 'color', 'm');
	end
	axisLimit=[min(time) max(time) -2^nbits/2, 2^nbits/2];
	if -1<=min(y) && max(y)<=1
		axisLimit=[min(time) max(time) -1, 1];
	end
	axis(axisLimit);
	ylabel('Amplitude');
	title('Waveform');
	
	subplot(3,1,2);
	plot(frameTime, frameVar, '.-');
	legend('Var');
	axis tight;
	ylabel('Var');
	title('Var');

	subplot(3,1,3);
	plot(frameTime, frameVar, '.-');
	axis tight;
	line([min(frameTime), max(frameTime)], vhTh*[1 1], 'color', 'r');
	line([min(frameTime), max(frameTime)], vhMin*[1 1], 'color', 'c');
	line([min(frameTime), max(frameTime)], vhMax*[1 1], 'color', 'k');
	for i=1:length(soundSegment)
		line(frameTime(soundSegment(i).beginFrame)*[1 1], [0, max(frameVar)], 'color', 'g');
		line(frameTime(soundSegment(i).endFrame)*[1 1], [0, max(frameVar)], 'color', 'm');
	end
	ylabel('Var');
	title('Var');
	
	U.y=double(y); U.fs=fs;
	if max(U.y)>1, U.y=U.y/(2^nbits/2); end
	if ~isempty(epInSampleIndex)
        U.voicedY=[];
        for i=1:length(soundSegment)
		U.voicedY=[U.voicedY;U.y(soundSegment(i).beginSample:soundSegment(i).endSample)];
        end
	else
		U.voicedY=[];
	end
	set(gcf, 'userData', U);
	uicontrol('string', 'Play all', 'callback', 'U=get(gcf, ''userData''); sound(U.y, U.fs);');
	uicontrol('string', 'Play detected', 'callback', 'U=get(gcf, ''userData''); sound(U.voicedY, U.fs);', 'position', [100, 20, 100, 20]);
end

% ====== Self demo
function selfdemo
mObj=mFileParse(which(mfilename));
strEval(mObj.example);

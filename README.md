#asr

提取鸟声的特征信号所进行的端点检测与去噪处理

Author ：Jay K.  
E-mail   : Jwjier@gmail.com

通过`audioread`函数或者`matlab导入向导`将语音信号导入至工作区中。  [信号文件](/测试.wav)  

读取的语音信号信噪比非常低，鸟叫声基本被噪声湮没首先编写语谱图程序`WTspectrogramByzxf`，通过`频谱`观察语音信号。下图：

![Time-Domain Waveforms](fig/时域波形.jpg)

![Fourier transform](fig/傅里叶变换Db.jpg)

![Wavelet transform](/Users/Jier/Desktop/code/asr/fig/频谱图.jpg)

选择其中的语音由0~0.8S之间的语音,可以看出语音的波形上比较难分辨鸟叫声与噪声的。如果单纯的对信号进行傅里叶变换是没有办法提取时间信息的。通过观察小波频谱我们可以看到在0.1S～0.5S左右频谱出现的变化，也就是说在0.1S的时候语音信号产生了变化。通过对比音频信号，我们可以听到在0.1S～0.5S附近确实存在鸟叫声。那么我们可以通过对小波数据来进行端点检测，来截取比较精准的鸟叫声片段。

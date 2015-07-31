function x = impulsestring(T,f,fs)
%Generate impulse string
%输入:
%   <double>T: 信号长度, 单位(秒)
%   <double>f: 冲激串频率
%   <double>fs: 采样频率
%输出:
%   <column vector>x: length(x)==round(T*fs), sum(x)==round(T*f)

x = zeros(round(T*fs),1);   % initialize x(n)
NS = round(T*f);            % NS
for i=0:NS-1
    x(round(i*fs/f)+1) = 1;   % x(k) = 1 if (k-i*N == 0) else 0
end

end


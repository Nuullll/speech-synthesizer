function A = changetone(a,df,fs)
%A = changetong(a,df,fs)
%输入:
%   <vector>a: 传递函数的分母, 用于求极点
%   <double>df: 频率变化量
%   <double>fs: 采样频率
%输出:
%   <row vector>A: 变频后新系统传递函数的分母

p = roots(a);    % get poles
for k=1:length(p)
    p(k) = rotatez(p(k),sign(rem(angle(p(k)),pi))*2*pi*df/fs);    % rotate
    % use rem() in case angle equals pi
end
A = poly(p);    % get poly

end


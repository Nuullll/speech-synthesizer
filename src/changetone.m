function A = changetone(a,df,fs)
%A = changetong(a,df,fs)
%����:
%   <vector>a: ���ݺ����ķ�ĸ, �����󼫵�
%   <double>df: Ƶ�ʱ仯��
%   <double>fs: ����Ƶ��
%���:
%   <row vector>A: ��Ƶ����ϵͳ���ݺ����ķ�ĸ

p = roots(a);    % get poles
for k=1:length(p)
    p(k) = rotatez(p(k),sign(rem(angle(p(k)),pi))*2*pi*df/fs);    % rotate
    % use rem() in case angle equals pi
end
A = poly(p);    % get poly

end


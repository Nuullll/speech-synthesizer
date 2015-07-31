function x = impulsestring(T,f,fs)
%Generate impulse string
%����:
%   <double>T: �źų���, ��λ(��)
%   <double>f: �弤��Ƶ��
%   <double>fs: ����Ƶ��
%���:
%   <column vector>x: length(x)==round(T*fs), sum(x)==round(T*f)

x = zeros(round(T*fs),1);   % initialize x(n)
NS = round(T*f);            % NS
for i=0:NS-1
    x(round(i*fs/f)+1) = 1;   % x(k) = 1 if (k-i*N == 0) else 0
end

end


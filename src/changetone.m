function A = changetone(a,rf)
%A = changetong(a,rf)
%输入:
%   <vector>a: 传递函数的分母, 用于求极点
%   <double>rf: 变频比
%输出:
%   <row vector>A: 变频后新系统传递函数的分母

p = roots(a);    % get poles
for k=1:length(p)
    p(k) = rotatez(p(k),(rf-1)*angle(p(k)));    % rotate
end
A = poly(p);    % get poly

end


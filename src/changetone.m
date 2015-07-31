function A = changetone(a,rf)
%A = changetong(a,rf)
%����:
%   <vector>a: ���ݺ����ķ�ĸ, �����󼫵�
%   <double>rf: ��Ƶ��
%���:
%   <row vector>A: ��Ƶ����ϵͳ���ݺ����ķ�ĸ

p = roots(a);    % get poles
for k=1:length(p)
    p(k) = rotatez(p(k),(rf-1)*angle(p(k)));    % rotate
end
A = poly(p);    % get poly

end


function y = normalize(x)
%Normalize amplitude of input sequence to [-1,1]

y = x/max(abs(x));

end


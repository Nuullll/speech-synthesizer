x = zeros(8000,1);
cursor = 1;
m = 1;          % index of slice
while m <= 100
    x(cursor) = 1;
    cursor = cursor + 80 + 5*mod(m,50);     % next cursor
    m = ceil(cursor/80);                    % locate next cursor
end
figure;
stem(0:8000-1,x);
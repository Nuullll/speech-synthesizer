[Z,P,~]=tf2zp(b,a);
[Z_t,P_t,~]=tf2zp(b,a_t);
figure;
[Hz1,Hp1,Hl1] = zplane(Z,P);
hold on;
[Hz2,Hp2,Hl2] = zplane(Z_t,P_t);
hold off;
xlim([-1.4 1.4]);
set(findobj(Hz2, 'Type', 'line'), 'Color', 'r')
set(findobj(Hp2, 'Type', 'line'), 'Color', 'r')
legend([Hp1,Hp2],'原系统','变调系统');
title('旋转极点');
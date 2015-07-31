[H,F]=freqz(b,a,512,fs);
[H_t,F_t]=freqz(b,a_t,512,fs);
figure;
subplot 211
plot(F,20*log10(abs(H)));hold on;
grid on;
xlabel('Frequency (Hz)');ylabel('Magnitude (dB)');
plot(F,20*log10(abs(H_t)),'r');hold off;
legend('原系统','变调系统');
title('幅频特性');
subplot 212
plot(F,angle(H));hold on;
grid on;
hold off;
plot(F_t,angle(H)/pi*180);hold on;
grid on;
xlabel('Frequency (Hz)');ylabel('Phase (degrees)');
plot(F_t,angle(H_t)/pi*180,'r');hold off;
legend('原系统','变调系统');
title('相频特性');
clear
a = arduino();
s = servo(a, 'D5', 'MinPulseDuration', 800*10^-6, 'MaxPulseDuration', 2300*10^-6);
writePosition(s, 0);
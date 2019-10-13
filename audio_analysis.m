clear, clc, close all
% get a section of the sound file
[x, fs] = audioread('song.mp3');    % load an audio file
x = x(:, 1);                        % get the first channel
N = length(x);                      % signal length
t = (0:N-1)/fs;                     % time vector


[bass_b,bass_a,bass_F,bass_H] = bp_butter(10,30,150,300);
[mid_b, mid_a ,mid_F ,mid_H ] = bp_butter(250,750,2000,3000);
[high_b,high_a,high_F,high_H] = bp_butter(2500,3500,5000,6000);


plot(bass_F,bass_H,mid_F,mid_H,high_F,high_H);
xlim([-1,5000]);ylim([-80,2.5]);
xlabel('Frequency (Hz)');ylabel('Magnitude (dB)');
title('Butterworth Band-Pass Filter Response at Low Frequencies');


%

%filt_x = filter(bass_b,bass_a,x);

nfft = 512;
thresh_scale = 2;
avg_len = 64;
figure
power   = 0;
avg     = 0;
ratio   = 1;
thresh  = 0;


for samp = nfft:nfft:N
    filt_x        = filter(mid_b,mid_a,x(samp+1-nfft:samp));
    power(end+1)  = sum(filt_x.^2)/nfft;
    avg(end+1)    = avg(end)*((avg_len-1)/avg_len) + power(end)*(1/avg_len);
    thresh(end+1) = avg(end)*(2-log2(1+avg(end)*10));
end
t_plot = t(1:nfft:end);
plot(t_plot,power,t_plot,avg,t_plot,thresh)
legend('Bass Energy','Moving Average','Adaptive Threshold');
%%
for ii = 1:length(bass_b)
    fprintf('%.15f ',bass_b(ii))
end
fprintf('\n\n')
for ii = 1:length(bass_a)
    fprintf('%.15f ',bass_a(ii))
end
fprintf('\n')
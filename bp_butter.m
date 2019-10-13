function [band_b,band_a,F,H] = bp_butter(stop1,pass1,pass2,stop2)

    %%General Filter Characteristics
    fs          = 44.1e3; %kHz

    %specifications for lowpass filter
    low_wp = pass2/(fs/2);
    low_ws = stop2/(fs/2);
    low_rp = 0.5;
    low_rs = 20;

    %specifications for highpass filter
    high_wp = pass1/(fs/2);
    high_ws = stop1/(fs/2);
    high_rp = 0.5;
    high_rs = 10;

    %%Butterworth Filter Design

    %find filter characteristics for lowpass filter 
    [low_N, low_wn] = buttord(low_wp,low_ws,low_rp,low_rs);

    %design lowpass filter
    [low_b,low_a] = butter(low_N,low_wn);

    %find filter characteristics for highpass filter 
    [high_N, high_wn] = buttord(high_wp,high_ws,high_rp,high_rs);

    %design highpass filter
    [high_b,high_a] = butter(high_N,high_wn, 'high');

    %convolve tfs
    band_b = conv(low_b,high_b);
    band_a = conv(low_a,high_a);

    %Plotting
    %w = (logspace(log10(0.1),log10(fs/2-1000),512)/(fs/2))*pi;

    [H_band,W_band] = freqz(band_b,band_a,2048);
    F = fs*W_band/2/pi;
    H = 20*log10(H_band);



end


function f_max = fmax_detect(t, x)
%FMAX_DETECT  F_max from spectral peaks that stand clear of the noise floor.
% Hann window to contain leakage, then keep local maxima above both 5 % of
% the largest peak and 10x the median spectrum level (the noise floor).
    N  = length(x);
    fs = (N - 1) / (t(end) - t(1));                 % true grid rate (999 Hz here)
    w  = 0.5 - 0.5*cos(2*pi*(0:N-1)/(N-1));
    X  = abs(fft((x - mean(x)) .* w));
    X  = X(1:floor(N/2)+1);
    f_axis = (0:floor(N/2)) * fs / N;
    thr = max(0.05*max(X), 10*median(X));
    isPeak = [false, X(2:end-1) > X(1:end-2) & X(2:end-1) >= X(3:end), false];
    f_max = max(f_axis(isPeak & X > thr));
end

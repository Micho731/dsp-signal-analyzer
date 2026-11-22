function [t, x, f_true, has_noise] = make_signal(seed)
%MAKE_SIGNAL  Same random signal recipe as generateRandomSignal in dsp_project.m:
% 1-5 sinusoids (A 0.5-3, f 1-50 Hz integer, random phase) on a 1000-point
% grid over 1 s, plus white noise (amplitude 0.1-0.5) half of the time.
    if nargin > 0, rand('seed', seed); randn('seed', seed); end %#ok<RAND>
    t = linspace(0, 1, 1000);
    K = randi([1, 5]);
    x = zeros(size(t)); f_true = zeros(1, K);
    for k = 1:K
        A = round(100*(0.5 + 2.5*rand()))/100;      % = round(.., 2) in MATLAB
        f = randi([1, 50]);
        phi = round(100*2*pi*rand())/100;
        x = x + A*sin(2*pi*f*t + phi);
        f_true(k) = f;
    end
    has_noise = rand() > 0.5;
    if has_noise
        x = x + round(100*(0.1 + 0.4*rand()))/100*randn(size(t));
    end
end

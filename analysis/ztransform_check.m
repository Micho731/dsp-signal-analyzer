%% Z-plane: tone frequencies recovered from the poles of an AR model
% Same model as computeZTransform in dsp_project.m. A sum of K sinusoids is
% an AR(2K) process with its poles on the unit circle at +-2*pi*f/Fs; the
% app fits order 2K + 10 so the extra poles absorb noise inside the circle.
% Runs in MATLAB or GNU Octave, no toolboxes.

clear; clc; close all;

% --- 1. frequency recovery over 2000 random signals ---
M = 2000; errs = []; radii = [];
for m = 1:M
    [t, x, f_true, noisy] = make_signal(m);
    f_true = unique(f_true); K = numel(f_true);
    fs = max(4*max(f_true), 20); ts = 0:1/fs:1;
    xs = interp1(t, x, ts, 'linear', 'extrap');
    [~, p] = ar_poles(xs, min(2*K + 10, floor(numel(xs)/3)));
    p = p(imag(p) > 0);
    if numel(p) < K, continue; end
    [~, idx] = sort(abs(p), 'descend'); p = p(idx(1:K));
    f_est = sort(angle(p)*fs/(2*pi)).';
    errs(end+1, :) = [max(abs(f_est - f_true)), noisy]; %#ok<AGROW>
    radii = [radii; abs(p), noisy*ones(K,1)]; %#ok<AGROW>
end
for g = 0:1
    sel = errs(:,2) == g; lbl = 'clean'; if g, lbl = 'noisy'; end
    fprintf('AR model, %s: %d signals, every tone within 1 Hz in %.1f %%, median worst-case error %.2f Hz, median pole radius %.3f\n', ...
        lbl, sum(sel), 100*mean(errs(sel,1) <= 1), median(errs(sel,1)), median(radii(radii(:,2)==g, 1)));
end

% --- 2. worked example ---
t = linspace(0, 1, 1000);
f0 = [7 19 33]; A0 = [1.5 1.0 0.8];
x = A0(1)*sin(2*pi*f0(1)*t + 0.4) + A0(2)*sin(2*pi*f0(2)*t + 1.9) + A0(3)*sin(2*pi*f0(3)*t + 3.1);
fs = 120; ts = 0:1/fs:1; xs = interp1(t, x, ts, 'linear', 'extrap');
[~, p_ar] = ar_poles(xs, 6);
pe = p_ar(imag(p_ar) > 0);
fprintf('Example (7, 19, 33 Hz at Fs = 120 Hz): poles at %s Hz, radii %s\n', ...
    mat2str(sort(angle(pe)*fs/(2*pi)).', 4), mat2str(sort(abs(pe)).', 4));

figure('Position', [100 100 520 500]);
th = linspace(0, 2*pi, 400);
plot(cos(th), sin(th), 'k--'); hold on; axis equal; grid on; box on;
ptrue = exp(1j*2*pi*[f0 -f0]/fs);
plot(real(ptrue), imag(ptrue), 'o', 'Color', [0.3 0.3 0.3], 'MarkerSize', 12);
plot(real(p_ar), imag(p_ar), 'rx', 'MarkerSize', 10, 'LineWidth', 2);
for k = 1:3
    text(1.08*cos(2*pi*f0(k)/fs), 1.08*sin(2*pi*f0(k)/fs), sprintf('%d Hz', f0(k)));
end
xlim([-1.4 1.4]); ylim([-1.4 1.4]); xlabel('Real'); ylabel('Imaginary');
title('AR(6) poles of 7 + 19 + 33 Hz, Fs = 120 Hz');
saveas(gcf, '../media/zplane_ar.png');

figure('Position', [100 100 760 520]);
subplot(2,1,1);
plot(t, x, 'b', 'LineWidth', 1.2); hold on;
stem(ts, xs, 'r', 'filled', 'MarkerSize', 3);
xlim([0 0.5]); grid on; box on; xlabel('Time (s)'); ylabel('Amplitude');
title(sprintf('7 + 19 + 33 Hz, sampled at Fs = %d Hz', fs));
subplot(2,1,2);
Nf = numel(xs); Xs = abs(fft(xs)) / Nf * 2; fx = (0:Nf-1) * fs / Nf;
stem(fx(1:floor(Nf/2)+1), Xs(1:floor(Nf/2)+1), 'filled', 'MarkerSize', 3);
grid on; box on; xlabel('Frequency (Hz)'); ylabel('|X(f)|'); title('Single-sided FFT of the samples');
saveas(gcf, '../media/example_signal_fft.png');

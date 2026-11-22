%% Aliasing: predicted folded frequency vs the FFT of the sampled signal
% Added in the 2026 review (not part of the original app).
% A 40 Hz tone is sampled the way the app does it (interp1 from the 1 kHz
% grid) at Fs = 20 ... 200 Hz. Theory: the tone shows up at
%   f_alias = | f0 - Fs * round(f0 / Fs) |
% Runs in MATLAB or GNU Octave, no toolboxes.

clear; clc; close all;
f0 = 40; t = linspace(0, 1, 1000); x = sin(2*pi*f0*t + 0.3);
Fs = 20:1:200; f_meas = zeros(size(Fs)); f_pred = abs(f0 - Fs.*round(f0./Fs));
for k = 1:numel(Fs)
    ts = 0:1/Fs(k):10;                              % 10 s for 0.1 Hz resolution
    xs = interp1(t, x, mod(ts, 1), 'linear');       % tone is periodic in 1 s
    N = numel(xs); X = abs(fft(xs));
    [~, i] = max(X(1:floor(N/2)+1)); f_meas(k) = (i-1)*Fs(k)/N;
end
ok = abs(f_meas - f_pred) <= 0.2;
fprintf('Predicted alias matches the FFT peak at %d of %d sampling rates (within 0.2 Hz)\n', sum(ok), numel(Fs));
fprintf('Mismatches at Fs = %s Hz\n', mat2str(Fs(~ok)));

figure('Position', [100 100 760 420]);
plot(Fs, f_pred, 'k-', 'LineWidth', 1.5); hold on;
plot(Fs, f_meas, 'r.', 'MarkerSize', 10);
plot([2*f0 2*f0], [0 45], 'b--');
text(2*f0 + 2, 43, 'Fs = 2 f_0 (Nyquist)', 'Color', 'b');
grid on; box on; xlabel('Sampling frequency Fs (Hz)'); ylabel('Apparent frequency (Hz)');
title('40 Hz tone: where it appears after sampling'); legend('theory |f_0 - Fs round(f_0/Fs)|', 'FFT of sampled signal', 'Location', 'southeast');
ylim([0 45]);
saveas(gcf, '../media/aliasing_check.png');

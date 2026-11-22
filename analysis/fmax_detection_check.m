%% F_max detection accuracy on 2000 random signals
% Uses the app's own signal recipe (make_signal) and its detector
% (fmax_detect, the same code as detectPeaks in dsp_project.m). A detection
% counts as correct when it lands within 2 Hz of the highest true tone.
% Runs in MATLAB or GNU Octave, no toolboxes.

clear; clc; close all;
M = 2000;
res = zeros(M, 3);     % [true f_max, detected, has_noise]
for m = 1:M
    [t, x, f_true, noisy] = make_signal(m);
    res(m, :) = [max(f_true), fmax_detect(t, x), noisy];
end
ok = abs(res(:,2) - res(:,1)) <= 2;
for g = 0:1
    sel = res(:,3) == g;
    lbl = 'clean'; if g, lbl = 'noisy'; end
    fprintf('%s signals (%d): correct %.1f %%, median error %.1f Hz\n', ...
        lbl, sum(sel), 100*mean(ok(sel)), median(abs(res(sel,2) - res(sel,1))));
end

noisy = res(:,3) == 1;
figure('Position', [100 100 620 480]);
plot(res(~noisy,1), res(~noisy,2), 'o', res(noisy,1), res(noisy,2), 'x'); hold on;
plot([0 55], [0 55], 'k--'); grid on; box on; xlim([0 55]); ylim([0 60]);
xlabel('True F_{max} (Hz)'); ylabel('Detected F_{max} (Hz)');
title('F_{max} detection on 2000 random signals');
legend('clean', 'noisy', 'ideal', 'Location', 'northwest');
saveas(gcf, '../media/fmax_detection.png');

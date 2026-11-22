function dsp_project()
    % DSP Signal Analyzer GUI
    % Generate a multi-tone signal, sample it, check aliasing, plot the FFT,
    % fit an all-pole (AR) model, show its poles, ROC and stability.
    
    % Create main figure
    fig = uifigure('Name', 'DSP Signal Analyzer', ...
                   'Color', [0.05 0.05 0.05], ...
                   'WindowState', 'maximized');
    
    % Main grid layout: 4 rows
    mainGrid = uigridlayout(fig, [4, 3]);
    mainGrid.RowHeight = {50, '1x', 150, 150};
    mainGrid.ColumnWidth = {300, '1x', '1x'};
    mainGrid.BackgroundColor = [0.05 0.05 0.05];
    
    % Store data
    data = struct();
    data.fs = [];
    data.t = []; data.x = [];
    data.t_sampled = []; data.x_sampled = [];
    data.b = []; data.a = []; data.f_max = [];
    fig.UserData = data;
    
    % ========== TOP BAR ==========
    topPanel = uipanel(mainGrid, 'BackgroundColor', [0.15 0.15 0.15], 'BorderType', 'none');
    topPanel.Layout.Row = 1; topPanel.Layout.Column = [1, 3];
    topGrid = uigridlayout(topPanel, [1, 2]);
    topGrid.ColumnWidth = {'fit', 100};
    topGrid.BackgroundColor = [0.15 0.15 0.15];
    uilabel(topGrid, 'Text', 'Sampling Frequency (Fs):', 'FontColor', [1 1 1], 'FontWeight', 'bold');
    fsEdit = uieditfield(topGrid, 'numeric', 'AllowEmpty', 'on', 'Value', [], 'BackgroundColor', [0.15 0.15 0.15], ...
                         'FontColor', [1 1 1], 'ValueChangedFcn', @(src, event) updateSamplingFreq(src, event, fig));
    % ========== LEFT CONTROL PANEL ==========
    leftPanel = uipanel(mainGrid, 'BackgroundColor', [0.15 0.15 0.15], 'BorderType', 'none');
    leftPanel.Layout.Row = [2, 4];
    leftPanel.Layout.Column = 1;
    leftPanel.Scrollable = 'on';
    
    leftGrid = uigridlayout(leftPanel, [6, 1]);
    leftGrid.RowHeight = {'fit', 'fit', 'fit', 'fit', '1x', 'fit'}; 
    leftGrid.Padding = [10, 10, 10, 10]; 
    leftGrid.RowSpacing = 10; 
    leftGrid.BackgroundColor = [0.15 0.15 0.15];
    
    % --- Signal Generation ---
    sigGenPanel = uipanel(leftGrid, 'Title', 'Signal Generation', 'BackgroundColor', [0.15 0.15 0.15], 'ForegroundColor', [1 1 1]);
    sigGenGrid = uigridlayout(sigGenPanel, [2, 1]);
    sigGenGrid.RowHeight = {35, 'fit'};
    sigGenGrid.BackgroundColor = [0.15 0.15 0.15];
    uibutton(sigGenGrid, 'Text', 'Generate RANDOM Signal', 'BackgroundColor', [0.25 0.6 0.35], 'FontColor', [1 1 1], ...
             'ButtonPushedFcn', @(src, event) generateRandomSignal(src, event, fig));
    sigDescLabel = uilabel(sigGenGrid, 'Text', '', 'FontColor', [1 1 1], 'FontSize', 9);
    
    % --- Sampling ---
    sampPanel = uipanel(leftGrid, 'Title', 'Sampling', 'BackgroundColor', [0.15 0.15 0.15], 'ForegroundColor', [1 1 1]);
    sampGrid = uigridlayout(sampPanel, [1, 1]);
    sampGrid.RowHeight = {35};
    sampGrid.BackgroundColor = [0.15 0.15 0.15];
    uibutton(sampGrid, 'Text', 'Sample Signal', 'BackgroundColor', [0.25 0.45 0.75], 'FontColor', [1 1 1], ...
             'ButtonPushedFcn', @(src, event) sampleSignal(src, event, fig));
    
    % --- DSP Analysis ---
    dspPanel = uipanel(leftGrid, 'Title', 'DSP Analysis', 'BackgroundColor', [0.15 0.15 0.15], 'ForegroundColor', [1 1 1]);
    dspGrid = uigridlayout(dspPanel, [4, 1]);
    dspGrid.RowHeight = {30, 30, 30, 30};
    dspGrid.RowSpacing = 5;
    dspGrid.BackgroundColor = [0.15 0.15 0.15];
    uibutton(dspGrid, 'Text', 'Compute Z-Transform', 'BackgroundColor', [0.85 0.55 0.25], 'FontColor', [1 1 1], 'ButtonPushedFcn', @(src, event) computeZTransform(src, event, fig));
    uibutton(dspGrid, 'Text', 'Plot ROC + Z-Plane',  'BackgroundColor', [0.85 0.55 0.25], 'FontColor', [1 1 1], 'ButtonPushedFcn', @(src, event) plotROC(src, event, fig));
    uibutton(dspGrid, 'Text', 'Plot FFT Spectrum',   'BackgroundColor', [0.85 0.55 0.25], 'FontColor', [1 1 1], 'ButtonPushedFcn', @(src, event) plotFFT(src, event, fig));
    uibutton(dspGrid, 'Text', 'Check Aliasing',      'BackgroundColor', [0.85 0.55 0.25], 'FontColor', [1 1 1], 'ButtonPushedFcn', @(src, event) checkAliasing(src, event, fig));
    
    % --- System Controls ---
    sysPanel = uipanel(leftGrid, 'Title', 'System Controls', 'BackgroundColor', [0.15 0.15 0.15], 'ForegroundColor', [1 1 1]);
    sysGrid = uigridlayout(sysPanel, [2, 1]);
    sysGrid.RowHeight = {30, 30};
    sysGrid.BackgroundColor = [0.15 0.15 0.15];
    uibutton(sysGrid, 'Text', 'Check Stability', 'BackgroundColor', [0.75 0.25 0.25], 'FontColor', [1 1 1], 'ButtonPushedFcn', @(src, event) checkStability(src, event, fig));
    uibutton(sysGrid, 'Text', 'Clear / Reset',   'BackgroundColor', [0.4 0.4 0.4],    'FontColor', [1 1 1], 'ButtonPushedFcn', @(src, event) clearAll(src, event, fig));
    
    % --- Spacer ---
    uilabel(leftGrid, 'Text', '');

    % ========== AXES & LOGS ==========
    axSig = uiaxes(mainGrid); axSig.Layout.Row = 2; axSig.Layout.Column = 2;
    axSig.Color = [0.18 0.18 0.18]; axSig.XColor = [1 1 1]; axSig.YColor = [1 1 1];
    grid(axSig, 'on');
    axSig.Title.String  = 'Signal Plot';  axSig.Title.Color  = [1 1 1];
    axSig.XLabel.String = 'Time (s)';     axSig.XLabel.Color = [1 1 1];
    axSig.YLabel.String = 'Amplitude';    axSig.YLabel.Color = [1 1 1];
    
    axZ = uiaxes(mainGrid); axZ.Layout.Row = 2; axZ.Layout.Column = 3;
    axZ.Color = [0.18 0.18 0.18]; axZ.XColor = [1 1 1]; axZ.YColor = [1 1 1];
    grid(axZ, 'on');
    axZ.Title.String  = 'Z-Plane / ROC';   axZ.Title.Color  = [1 1 1];
    axZ.XLabel.String = 'Real Part';        axZ.XLabel.Color = [1 1 1];
    axZ.YLabel.String = 'Imaginary Part';   axZ.YLabel.Color = [1 1 1];
    
    % Logs take Row 3
    logArea = uitextarea(mainGrid, 'Value', {'>> System Initialized.'}, ...
                         'BackgroundColor', [0 0 0], 'FontColor', [0 1 0], ...
                         'FontName', 'Courier New', 'FontSize', 14, 'Editable', 'off');
    logArea.Layout.Row = 3; logArea.Layout.Column = [2, 3];

    % FFT takes Row 4
    axFFT = uiaxes(mainGrid); axFFT.Layout.Row = 4; axFFT.Layout.Column = [2, 3];
    axFFT.Color = [0.18 0.18 0.18]; axFFT.XColor = [1 1 1]; axFFT.YColor = [1 1 1];
    grid(axFFT, 'on');
    axFFT.Title.String  = 'FFT Spectrum';     axFFT.Title.Color  = [1 1 1];
    axFFT.XLabel.String = 'Frequency (Hz)';   axFFT.XLabel.Color = [1 1 1];
    axFFT.YLabel.String = 'Magnitude';        axFFT.YLabel.Color = [1 1 1];
    
    % Store handles
    data.axSig = axSig; data.axZ = axZ; data.axFFT = axFFT;
    data.logArea = logArea; data.sigDescLabel = sigDescLabel; data.fsEdit = fsEdit;
    fig.UserData = data;
end

% ========== CALLBACKS ==========
function updateSamplingFreq(src, ~, fig)
    data = fig.UserData;
    data.fs = src.Value;
    fig.UserData = data;
    logMessage(fig, sprintf('>> Fs set to %.1f Hz', data.fs));
end

function generateRandomSignal(~, ~, fig)
    data = fig.UserData;
    t = linspace(0, 1, 1000);

    num_components = randi([1, 5]);
    x = zeros(size(t));
    desc_parts = {};

    for k = 1:num_components
        A   = round(0.5 + 2.5 * rand(), 2);
        f   = randi([1, 50]);
        phi = round(2 * pi * rand(), 2);
        x   = x + A * sin(2 * pi * f * t + phi);
        desc_parts{end+1} = sprintf('%.2f·sin(2π·%dt + %.2f)', A, f, phi);
    end

    if rand() > 0.5
        noise_amp = round(0.1 + 0.4 * rand(), 2);
        x = x + noise_amp * randn(size(t));
        desc_parts{end+1} = sprintf('%.2f·noise', noise_amp);
    end

    % Compute f_max from spectral peaks above the noise floor
    f_max = max(detectPeaks(t, x));

    % Save everything to data ONCE
    data.t = t;
    data.x = x;
    data.f_max = f_max;
    data.sigDescLabel.Text = strjoin(desc_parts, ' + ');
    fig.UserData = data;

    % Plot
    cla(data.axSig);
    plot(data.axSig, t, x, 'c', 'LineWidth', 1.5);
    data.axSig.Title.String  = 'Signal Plot'; data.axSig.Title.Color  = [1 1 1];
    data.axSig.XLabel.String = 'Time (s)';    data.axSig.XLabel.Color = [1 1 1];
    data.axSig.YLabel.String = 'Amplitude';   data.axSig.YLabel.Color = [1 1 1];
    drawnow;

    % Log
    logMessage(fig, sprintf('>> Random signal generated (%d components).', num_components));
    logMessage(fig, sprintf('>> Detected F_max = %.1f Hz.', f_max));
    logMessage(fig, sprintf('>> To avoid aliasing, set Fs > %.1f Hz (Nyquist = 2*F_max).', 2 * f_max));
    logMessage(fig, '>> Please enter your Fs above, then click Sample Signal.');
end

function sampleSignal(~, ~, fig)
    data = fig.UserData;
    if isempty(data.t), return; end

    if isempty(data.fs) || data.fs <= 0
        logMessage(fig, '>> ERROR: Please set a Sampling Frequency first.');
        return;
    end

    t_s = 0:(1/data.fs):max(data.t);
    x_s = interp1(data.t, data.x, t_s, 'linear', 'extrap');
    data.t_sampled = t_s; data.x_sampled = x_s;
    fig.UserData = data;
    
    hold(data.axSig, 'on'); 
    stem(data.axSig, t_s, x_s, 'r', 'LineWidth', 1.5, 'MarkerSize', 6, 'MarkerFaceColor', 'r'); 
    hold(data.axSig, 'off');
    data.axSig.Title.String  = 'Signal Plot'; data.axSig.Title.Color  = [1 1 1];
    data.axSig.XLabel.String = 'Time (s)';    data.axSig.XLabel.Color = [1 1 1];
    data.axSig.YLabel.String = 'Amplitude';   data.axSig.YLabel.Color = [1 1 1];
    
    logMessage(fig, sprintf('>> Signal sampled at Fs = %.1f Hz.', data.fs));
end

function computeZTransform(~, ~, fig)
    data = fig.UserData;
    if isempty(data.x_sampled), return; end

    % All-pole (AR) model fitted to the samples by forward-backward least
    % squares. A sum of K sinusoids is an AR(2K) process with poles on the
    % unit circle at angles +-2*pi*f/Fs; 10 extra poles absorb the noise.
    xs = data.x_sampled(:) - mean(data.x_sampled);
    N  = numel(xs);
    K  = max(1, numel(detectPeaks(data.t, data.x)));
    p  = min(2*K + 10, floor(N/3));
    if p < 2
        logMessage(fig, '>> ERROR: Too few samples for a model. Raise Fs.');
        return;
    end
    Xf = zeros(N-p, p); Xb = zeros(N-p, p);
    for k = 1:p
        Xf(:, k) = xs(p+1-k:N-k);
        Xb(:, k) = xs(1+k:N-p+k);
    end
    a = -([Xf; Xb] \ [xs(p+1:N); xs(1:N-p)]);
    data.a = [1, a.'];
    data.b = 1;
    fig.UserData = data;

    poles = roots(data.a);
    up = poles(imag(poles) > 0);
    [~, idx] = sort(abs(up), 'descend');
    up = up(idx(1:min(K, numel(up))));
    f_est = sort(angle(up) * data.fs / (2*pi));

    cla(data.axZ);
    stem(data.axZ, 0:length(data.a)-1, abs(data.a), 'filled', 'Color', [0.85 0.55 0.25]);
    data.axZ.Title.String  = sprintf('AR(%d) Coefficients of H(z) = 1/A(z)', p); data.axZ.Title.Color  = [1 1 1];
    data.axZ.XLabel.String = 'Coefficient Index (k)';    data.axZ.XLabel.Color = [1 1 1];
    data.axZ.YLabel.String = '|a_k|';                    data.axZ.YLabel.Color = [1 1 1];

    logMessage(fig, sprintf('>> AR(%d) model fitted to %d samples.', p, N));
    logMessage(fig, ['>> Tones from the poles (Hz): ' sprintf('%.1f  ', f_est)]);
end

function plotROC(~, ~, fig)
    data = fig.UserData;
    if isempty(data.a), return; end

    zeros_sys = roots(data.b); poles_sys = roots(data.a);
    cla(data.axZ); hold(data.axZ, 'on');
    theta = linspace(0, 2*pi, 100);
    plot(data.axZ, real(exp(1j*theta)), imag(exp(1j*theta)), 'w--');
    plot(data.axZ, real(zeros_sys), imag(zeros_sys), 'go', 'MarkerFaceColor', 'g');
    plot(data.axZ, real(poles_sys), imag(poles_sys), 'rx', 'LineWidth', 2);
    r_roc = max(abs(poles_sys));
    plot(data.axZ, r_roc*cos(theta), r_roc*sin(theta), ':', 'Color', [0.85 0.55 0.25], 'LineWidth', 1.5);
    hold(data.axZ, 'off');
    axis(data.axZ, 'equal'); xlim(data.axZ, [-1.5 1.5]); ylim(data.axZ, [-1.5 1.5]);
    data.axZ.Title.String  = 'Z-Plane / ROC';  data.axZ.Title.Color  = [1 1 1];
    data.axZ.XLabel.String = 'Real Part';       data.axZ.XLabel.Color = [1 1 1];
    data.axZ.YLabel.String = 'Imaginary Part';  data.axZ.YLabel.Color = [1 1 1];

    logMessage(fig, sprintf('>> Causal system: ROC is |z| > %.3f (dotted circle).', r_roc));
end

function plotFFT(~, ~, fig)
    data = fig.UserData;
    if isempty(data.x_sampled), return; end

    N = length(data.x_sampled);
    X = fft(data.x_sampled, N);
    f = (0:N-1) * data.fs / N;
    n_plot = floor(N/2) + 1;

    cla(data.axFFT);
    plot(data.axFFT, f(1:n_plot), abs(X(1:n_plot)), 'm-', 'LineWidth', 1.5);
    data.axFFT.Title.String  = 'FFT Spectrum';    data.axFFT.Title.Color  = [1 1 1];
    data.axFFT.XLabel.String = 'Frequency (Hz)';  data.axFFT.XLabel.Color = [1 1 1];
    data.axFFT.YLabel.String = 'Magnitude';        data.axFFT.YLabel.Color = [1 1 1];

    logMessage(fig, '>> FFT spectrum plotted.');
end

function checkAliasing(~, ~, fig)
    data = fig.UserData;

    if isempty(data.x) || isempty(data.t)
        logMessage(fig, '>> No signal to check. Generate a signal first.');
        return;
    end

    if isempty(data.fs) || data.fs <= 0
        logMessage(fig, '>> ERROR: Please set a Sampling Frequency first.');
        return;
    end

    significant = detectPeaks(data.t, data.x);

    if isempty(significant)
        logMessage(fig, '>> Could not determine signal bandwidth.');
        return;
    end

    f_max = max(significant);
    nyquist_required = 2 * f_max;

    if data.fs <= nyquist_required
        logMessage(fig, sprintf('>> WARNING: Aliasing! Fs = %.1f Hz <= 2*F_max = %.1f Hz (need > %.1f Hz)', ...
            data.fs, nyquist_required, nyquist_required));
    else
        logMessage(fig, sprintf('>> No Aliasing. Fs = %.1f Hz > 2*F_max = %.1f Hz', ...
            data.fs, nyquist_required));
    end
end

function checkStability(~, ~, fig)
    data = fig.UserData;
    if isempty(data.a), return; end

    p_mag = max(abs(roots(data.a)));
    if p_mag > 1.001
        msg = sprintf('>> Unstable (Max pole magnitude: %.3f > 1)', p_mag);
    elseif p_mag >= 0.99
        msg = sprintf(['>> Marginally stable (Max pole magnitude: %.3f, on the unit circle): ' ...
                       'the model rings forever, as a sum of sinusoids should.'], p_mag);
    else
        msg = sprintf('>> Stable (Max pole magnitude: %.3f < 1)', p_mag);
    end
    logMessage(fig, msg);
end

function clearAll(~, ~, fig)
    data = fig.UserData;
    cla(data.axSig); cla(data.axZ); cla(data.axFFT);

    % Restore axis labels after cla
    data.axSig.Title.String  = 'Signal Plot'; data.axSig.Title.Color  = [1 1 1];
    data.axSig.XLabel.String = 'Time (s)';    data.axSig.XLabel.Color = [1 1 1];
    data.axSig.YLabel.String = 'Amplitude';   data.axSig.YLabel.Color = [1 1 1];

    data.axZ.Title.String  = 'Z-Plane / ROC'; data.axZ.Title.Color  = [1 1 1];
    data.axZ.XLabel.String = 'Real Part';      data.axZ.XLabel.Color = [1 1 1];
    data.axZ.YLabel.String = 'Imaginary Part'; data.axZ.YLabel.Color = [1 1 1];

    data.axFFT.Title.String  = 'FFT Spectrum';   data.axFFT.Title.Color  = [1 1 1];
    data.axFFT.XLabel.String = 'Frequency (Hz)'; data.axFFT.XLabel.Color = [1 1 1];
    data.axFFT.YLabel.String = 'Magnitude';       data.axFFT.YLabel.Color = [1 1 1];

    data.t = []; data.x = []; data.t_sampled = []; data.x_sampled = [];
    data.a = []; data.b = []; data.fs = []; data.f_max = [];
    data.fsEdit.Value = [];
    data.sigDescLabel.Text = '';
    fig.UserData = data;

    logMessage(fig, '>> Data reset.');
end

function logMessage(fig, message)
    data = fig.UserData;
    data.logArea.Value{end+1} = message;
    scroll(data.logArea, 'bottom');
end

function f_peaks = detectPeaks(t, x)
    % Frequencies of spectral peaks that stand clear of the noise floor:
    % Hann window against leakage, then local maxima above 5 % of the
    % largest peak and 10x the median spectrum level.
    N  = length(x);
    fs = (N - 1) / (t(end) - t(1));
    w  = 0.5 - 0.5*cos(2*pi*(0:N-1)/(N-1));
    X  = abs(fft((x - mean(x)) .* w));
    X  = X(1:floor(N/2)+1);
    f_axis = (0:floor(N/2)) * fs / N;
    thr = max(0.05*max(X), 10*median(X));
    isPeak = [false, X(2:end-1) > X(1:end-2) & X(2:end-1) >= X(3:end), false];
    f_peaks = f_axis(isPeak & X > thr);
end

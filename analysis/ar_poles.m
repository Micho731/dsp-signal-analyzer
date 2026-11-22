function [a, poles] = ar_poles(x, p)
%AR_POLES  Order-p autoregressive model by forward-backward least squares.
% Model: x[n] = -a1 x[n-1] - ... - ap x[n-p], so H(z) = 1 / A(z) with
% A(z) = 1 + a1 z^-1 + ... + ap z^-p. A sum of K sinusoids is exactly an
% AR(2K) process with its poles ON the unit circle at angles +-2*pi*f/fs.
    x = x(:) - mean(x);
    N = length(x);
    Xf = zeros(N-p, p); Xb = zeros(N-p, p);
    for k = 1:p
        Xf(:, k) = x(p+1-k:N-k);      % forward: past samples
        Xb(:, k) = x(1+k:N-p+k);      % backward: future samples
    end
    yf = x(p+1:N); yb = x(1:N-p);
    a = -([Xf; Xb] \ [yf; yb]);
    a = [1; a].';
    poles = roots(a);
end

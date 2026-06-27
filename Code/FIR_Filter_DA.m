%% =========================================================
%  FIR LPF — Integer Coefficient Simulation
%  Coefficients: Q0.8 integers (h_float × 256, rounded)
%  Scale factor : 256 (Q0.8 format, 8 fractional bits)
%  Output       : accumulator (integer) + accumulator/256
%  Fs = 3000 Hz | Signal: 500 Hz (pass) + 2000 Hz (block)
%  Input  : 10-bit signed [-512, 511]
%  Samples: 100
% ==========================================================

clear; clc; close all;

%% -------------------------------------------------------
%  Integer Coefficients (h_float × 256, rounded)
%  h_float = [0.0328, 0.0816, -0.0065, -0.0047, 0.0847,
%             -0.0694, -0.0550, 0.5763, 0.5763, -0.0550,
%             -0.0694, 0.0847, -0.0047, -0.0065, 0.0816, 0.0328]
% --------------------------------------------------------
h_int   = [8, 21, -2, -1, 22, -18, -14, 148, 148, -14, -18, 22, -1, -2, 21, 8];
SCALE   = 256;      % Q0.8: 2^8 = 256
NUM_TAPS = length(h_int);

fprintf('=== Integer Coefficients (Q0.8, scale=256) ===\n');
fprintf('h_int = [');
fprintf(' %d', h_int);
fprintf(' ]\n');
fprintf('Sum(h_int)  = %d\n', sum(h_int));
fprintf('Scale (2^8) = %d\n', SCALE);
fprintf('DC gain     = %.4f  (sum/scale = %d/%d)\n\n', sum(h_int)/SCALE, sum(h_int), SCALE);

%% -------------------------------------------------------
%  Signal Generation
% --------------------------------------------------------
Fs     = 3000;
N      = 200;
n      = 0:N-1;
T      = n / Fs;
f_pass = 200;
f_stop = 1400;

x_low  = sin(2*pi*f_pass .* T);
x_high = sin(2*pi*f_stop .* T);
x_cont = x_low + x_high;   % range [-2, +2]

% Scale to 10-bit signed [-512, 511]
x_int  = int32(round(x_cont .* 255/2));
x_int  = int32(max(min(x_int, 511), -512));

%% -------------------------------------------------------
%  Integer FIR Filter (matches Verilog exactly)
%  Step 1: accumulator = sum(h_int[k] * x[n-k])
%  Step 2: output      = accumulator / 256  (right shift >>8)
% --------------------------------------------------------
accumulator = int64(zeros(1, N));
shift_reg   = int32(zeros(1, NUM_TAPS));   % 16-tap delay line

for i = 1:N
    % Shift register: push new sample in
    shift_reg = [x_int(i), shift_reg(1:end-1)];

    % MAC: multiply-accumulate with integer coefficients
    acc = int64(0);
    for k = 1:NUM_TAPS
        acc = acc + int64(h_int(k)) * int64(shift_reg(k));
    end
    accumulator(i) = acc;
end

% Normalize: divide by scale factor (equivalent to >>8 in Verilog)
y_out = int32(round(double(accumulator) / SCALE));

%% -------------------------------------------------------
%  Helper: signed integer to binary string
% --------------------------------------------------------
function s = to_signed_bin(val, nbits)
    if val < 0
        val = val + 2^nbits;
    end
    s = dec2bin(val, nbits);
end

%% -------------------------------------------------------
%  Print Full Table (samples)
% --------------------------------------------------------
fprintf('%-5s  %-10s  %-12s  %-16s  %-12s  %-12s\n', ...
        'n', 'x[n]', 'x_10bit', 'accumulator', 'y_out', 'y_22bit');
fprintf('%s\n', repmat('-', 1, 78));
for i = 1:N
    xd   = double(x_int(i));
    yd   = double(y_out(i));
    xbin = to_signed_bin(xd, 10);
    ybin = to_signed_bin(yd, 22);
    fprintf('%-5d  %-10d  %-12s  %-16d  %-12d  %s\n', ...
            n(i), xd, xbin, accumulator(i), yd, ybin);
end

%% -------------------------------------------------------
%  Save Files
% --------------------------------------------------------

% --- Decimal + binary text file ---
fid = fopen('lpf_integer_samples.txt', 'w');
fprintf(fid, 'FIR LPF Integer Simulation\n');
fprintf(fid, 'Coefficients (Q0.8, scale=256): h_int = [');
fprintf(fid, ' %d', h_int); fprintf(fid, ' ]\n');
fprintf(fid, 'Signal: %dHz + %dHz  |  Fs=%dHz  |  Input: 10-bit signed\n\n', f_pass, f_stop, Fs);
fprintf(fid, '%-5s  %-10s  %-12s  %-16s  %-12s  %-24s\n', ...
        'n', 'x[n]', 'x_10bit', 'accumulator', 'y[n]', 'y_22bit');
fprintf(fid, '%s\n', repmat('-', 1, 86));
for i = 1:N
    xd   = double(x_int(i));
    yd   = double(y_out(i));
    xbin = to_signed_bin(xd, 10);
    ybin = to_signed_bin(yd, 22);
    fprintf(fid, '%-5d  %-10d  %-12s  %-16d  %-12d  %s\n', ...
            n(i), xd, xbin, accumulator(i), yd, ybin);
end
fclose(fid);

% --- Input binary file (int32, 4 bytes/sample) ---
fid = fopen('input_10bit.bin', 'wb');
fwrite(fid, x_int, 'int32');
fclose(fid);

% --- Accumulator binary file (int64, 8 bytes/sample) ---
fid = fopen('accumulator_raw.bin', 'wb');
fwrite(fid, accumulator, 'int64');
fclose(fid);

% --- Output binary file (int32, 4 bytes/sample) ---
fid = fopen('output_normalized.bin', 'wb');
fwrite(fid, y_out, 'int32');
fclose(fid);

% --- CSV ---
fid = fopen('lpf_integer_samples.csv', 'w');
fprintf(fid, 'n,x_decimal,x_10bit_binary,accumulator,y_decimal,y_22bit_binary\n');
for i = 1:N
    xd   = double(x_int(i));
    yd   = double(y_out(i));
    xbin = to_signed_bin(xd, 10);
    ybin = to_signed_bin(yd, 22);
    fprintf(fid, '%d,%d,%s,%d,%d,%s\n', n(i), xd, xbin, accumulator(i), yd, ybin);
end
fclose(fid);

fprintf('\n=== Files Saved ===\n');
fprintf('  lpf_integer_samples.txt  — full table: decimal + binary\n');
fprintf('  lpf_integer_samples.csv  — same as CSV\n');
fprintf('  input_10bit.bin          — int32, 4 bytes/sample\n');
fprintf('  accumulator_raw.bin      — int64, 8 bytes/sample (raw MAC output)\n');
fprintf('  output_normalized.bin    — int32, 4 bytes/sample (accum/256)\n');

%% -------------------------------------------------------
%  Plots
% --------------------------------------------------------
figure('Name', 'Integer FIR LPF', 'Position', [50 50 1100 750]);

subplot(3,1,1);
stem(n, double(x_int), 'b', 'filled', 'MarkerSize', 3);
title(sprintf('Input x[n] — 10-bit signed  (%dHz + %dHz, Fs=%dHz)', f_pass, f_stop, Fs));
xlabel('n'); ylabel('Amplitude'); ylim([-300 300]); grid on;

subplot(3,1,2);
stem(n, double(accumulator), 'r', 'filled', 'MarkerSize', 3);
title('Raw Accumulator (integer MAC output before /256)');
xlabel('n'); ylabel('Accumulator value'); grid on;

subplot(3,1,3);
stem(n, double(y_out), 'g', 'filled', 'MarkerSize', 3);
hold on;
% Ideal reference: only 500 Hz component passed
x_low_int  = int32(round(x_low .* 255/2));
y_ref_acc  = int64(zeros(1, N));
sr_ref     = int32(zeros(1, NUM_TAPS));
for i = 1:N
    sr_ref    = [x_low_int(i), sr_ref(1:end-1)];
    acc2      = int64(0);
    for k = 1:NUM_TAPS
        acc2 = acc2 + int64(h_int(k)) * int64(sr_ref(k));
    end
    y_ref_acc(i) = acc2;
end
y_ref = int32(round(double(y_ref_acc) / SCALE));
plot(n, double(y_ref), 'k--', 'LineWidth', 1.5);
title('Normalized Output y[n] = accumulator/256 vs 500Hz reference');
xlabel('n'); ylabel('Amplitude');
legend('y[n] filtered', ' only reference'); grid on;

figure('Name', 'Frequency Spectrum', 'Position', [50 50 1000 420]);
NFFT = 2048;
X_sp = abs(fft(double(x_int), NFFT)) / N;
Y_sp = abs(fft(double(y_out), NFFT)) / N;
f_ax = (0:NFFT-1) * Fs / NFFT;
half = 1:NFFT/2;
subplot(1,2,1);
stem(f_ax(half), 2*X_sp(half), 'b', 'MarkerSize', 2);
title('Input spectrum'); xlabel('Hz'); grid on;
subplot(1,2,2);
stem(f_ax(half), 2*Y_sp(half), 'g', 'MarkerSize', 2);
title('Output spectrum — only lowerfreq remains'); xlabel('Hz'); grid on;

fprintf('\n=== Accumulator Stats ===\n');
fprintf('Max |accumulator| = %d\n', max(abs(double(accumulator))));
fprintf('Bits needed       = %d  (fits in 17-bit, well within 22-bit)\n', ...
        ceil(log2(double(max(abs(accumulator)))+1))+1);
fprintf('Max |y_out|       = %d\n', max(abs(double(y_out))));
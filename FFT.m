clear;
clc;

source_file = 'cadence_dac_output.csv';
fs = 100e6;
dc_bins = 3;

x = load(source_file);
N = length(x);
w = ds_hann(N).';

spec = fft(x .* w) / (N / 4);
spec(1:dc_bins) = 0;
spec(end-dc_bins+2:end) = 0;

[~, fin] = max(abs(spec(2:N/2+1)));

f = linspace(0, fs/2, N/2 + 1);
snr_dB = calculateSNR(spec(1:N/2+1), fin);

figure;
plot(f / 1e6, dbv(spec(1:N/2+1)));
axis([0 fs/(2e6) -120 0]);
grid on;
xlabel('Frequency (MHz)');
ylabel('dBFS/NBW');
title(['FFT of ', source_file], 'Interpreter', 'none');

s = sprintf('SNR = %4.1f dB', snr_dB);
text(0.55 * fs/(2e6), -90, s);

s = sprintf('NBW = %.5f', 1.5 / N);
text(0.55 * fs/(2e6), -110, s);

fprintf('FFT of %s\n', source_file);
fprintf('N = %d\n', N);
fprintf('fs = %.3f MHz\n', fs / 1e6);
fprintf('Detected tone bin = %d\n', fin);
fprintf('Detected tone frequency = %.6f MHz\n', fin * fs / N / 1e6);
fprintf('SNR = %.2f dB\n', snr_dB);

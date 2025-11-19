%% Record Stereo Audio and Analyze
% This script records stereo audio from the microphone, saves the left and right channels as separate WAV files, and analyzes their frequency content.
fs = 44100;
recSecs = 10;

recObj = audiorecorder(fs, 24, 2);
disp('Audio recording has started...')
recordblocking(recObj, recSecs);
disp('Recording has ended');
audioData = getaudiodata(recObj);

left = audioData(:,1); audiowrite('nov17_left1_song.mp3', left, fs);
right = audioData(:,2); audiowrite('nov17_right1_song.mp3', right, fs);
audiowrite('nov17_stereo1_song.mp3', audioData, fs);
sound(audioData, fs);

N = size(audioData, 1);
t = (0:N-1)/fs;


%% Load Recorded Audio Files
%[left, fs] = audioread('nov17_left1.wav');
%[right, fs] = audioread('nov17_right1.wav');
%[audioData, fs] = audioread('nov17_stereo1.wav');
%N = size(audioData, 1);
%t = (0:N-1)/fs;

%sound(left, fs); pause(length(left)/fs + 1);
%sound(right, fs); pause(length(right)/fs + 1);  
%sound(audioData, fs); pause(length(audioData)/fs + 1);

%% Plot Time Domain
[f_left, Xleft_db] = single_sided_fft_plot(left, fs);
[f_right, Xright_db] = single_sided_fft_plot(right, fs);
[f_stereo, Xstereo_db] = single_sided_fft_plot(audioData(:,1), fs);

figure('Name','Left Channel - Time','Units','normalized','Position',[0.1 0.1 0.8 0.6]);
subplot(2,1,1); plot(t, left); xlabel('Time (s)'); ylabel('Amplitude'); title('Left - time'); grid on;
subplot(2,1,2); plot(f_left, Xleft_db); xlabel('Frequency (Hz)'); ylabel('Magnitude (dB)'); title('Left - frequency'); grid on;

figure('Name','Right Channel - Time','Units','normalized','Position',[0.1 0.1 0.8 0.6]);
subplot(2,1,1); plot(t, right); xlabel('Time (s)'); ylabel('Amplitude'); title('Right - time'); grid on;
subplot(2,1,2); plot(f_right, Xright_db); xlabel('Frequency (Hz)'); ylabel('Magnitude (dB)'); title('Right - frequency'); grid on;

figure('Name','Stereo - Time','Units','normalized','Position',[0.1 0.1 0.8 0.6]);
subplot(2,1,1); plot(t, audioData(:,1), t, audioData(:,2)); xlabel('Time (s)'); ylabel('Amplitude'); title('Stereo - time'); legend('Left','Right'); grid on;
subplot(2,1,2); plot(f_stereo, Xstereo_db); xlabel('Frequency (Hz)'); ylabel('Magnitude (dB)'); title('Stereo - frequency'); grid on;

%% STFT Analysis
winlen = 2048;
hop = winlen/4;
nfft = winlen;
win = hann(winlen, 'periodic');

[S_left, f_left_stft, t_left_stft] = stft(left, fs, 'Window', win, 'OverlapLength', winlen - hop, 'FFTLength', nfft);
magl = abs(S_left);

[S_right, f_right_stft, t_right_stft] = stft(right, fs, 'Window', win, 'OverlapLength', winlen - hop, 'FFTLength', nfft);
magr = abs(S_right);

[S_stereo, f_stereo_stft, t_stereo_stft] = stft(audioData(:,1), fs, 'Window', win, 'OverlapLength', winlen - hop, 'FFTLength', nfft);
mags = abs(S_stereo);

figure('Name','Spectrograms','Units','normalized','Position',[0.1 0.1 0.8 0.6]);
subplot(3,1,1); imagesc(t_left_stft, f_left_stft, 20*log10(magl + eps)); axis xy; ylim([0 8000]); title('Left Channel Spectrogram'); xlabel('Time (s)'); ylabel('Frequency (Hz)'); colorbar;
grid on;
subplot(3,1,2); imagesc(t_right_stft, f_right_stft, 20*log10(magr + eps)); axis xy; ylim([0 8000]); title('Right Channel Spectrogram'); xlabel('Time (s)'); ylabel('Frequency (Hz)'); colorbar;
grid on;
subplot(3,1,3); imagesc(t_stereo_stft, f_stereo_stft, 20*log10(mags + eps)); axis xy; ylim([0 8000]); title('Stereo Spectrogram'); xlabel('Time (s)'); ylabel('Frequency (Hz)'); colorbar;
grid on;

%% Prepare music-only estimate

%% Record Stereo Audio and Analyze
% This script records stereo audio from the microphone, saves the left and right channels as separate WAV files, and analyzes their frequency content.
fs = 44100;
recSecs = 10;

recObj = audiorecorder(fs, 24, 2);
disp('Audio recording has started...')
recordblocking(recObj, recSecs);
disp('Recording has ended');
audioData = getaudiodata(recObj);

left = audioData(:,1); audiowrite('nov17_left1_song.wav', left, fs);
right = audioData(:,2); audiowrite('nov17_right1_song.wav', right, fs);
audiowrite('nov17_stereo1_song.wav', audioData, fs);
sound(audioData, fs);

N = size(audioData, 1);
t = (0:N-1)/fs;

%% Dock figures in MATLAB desktop
% Make all figures created after this line appear docked as tabs in the
% MATLAB desktop window. To revert during the session use
% `set(groot,'DefaultFigureWindowStyle','normal')`.
set(groot,'DefaultFigureWindowStyle','docked');

%% Load Recorded Audio Files
%[left, fs] = audioread('nov17_left1.wav');
%[right, fs] = audioread('nov17_right1.wav');
%[audioData, fs] = audioread('nov17_stereo1.wav');
%N = size(audioData, 1);
%t = (0:N-1)/fs;

%sound(left, fs); pause(length(left)/fs + 1);
%sound(right, fs); pause(length(right)/fs + 1);  
%sound(audioData, fs); pause(length(audioData)/fs + 1);

%% Combined UI: Tabbed window with all plots (works in VS Code figure window)
% Create a single `uifigure` with tabs so all plots appear in one window
% (this works even when not using the MATLAB Desktop).

% Compute FFTs (ensure the helper is available at end of file)
[f_left, Xleft_db] = single_sided_fft_plot(left, fs);
[f_right, Xright_db] = single_sided_fft_plot(right, fs);
[f_stereo, Xstereo_db] = single_sided_fft_plot(audioData(:,1), fs);

u = uifigure('Name','All Plots','Position',[100 100 1200 800]);
tg = uitabgroup(u,'Position',[5 5 1190 790]);

% Left channel tab (time + frequency)
t1 = uitab(tg,'Title','Left');
tl1 = tiledlayout(t1,2,1,'Padding','compact','TileSpacing','compact');
ax1 = nexttile(tl1); plot(ax1, t, left); xlabel(ax1,'Time (s)'); ylabel(ax1,'Amplitude'); title(ax1,'Left - time'); grid(ax1,'on');
ax2 = nexttile(tl1); plot(ax2, f_left, Xleft_db); xlabel(ax2,'Frequency (Hz)'); ylabel(ax2,'Magnitude (dB)'); title(ax2,'Left - frequency'); grid(ax2,'on');

% Right channel tab (time + frequency)
t2 = uitab(tg,'Title','Right');
tl2 = tiledlayout(t2,2,1,'Padding','compact','TileSpacing','compact');
ax3 = nexttile(tl2); plot(ax3, t, right); xlabel(ax3,'Time (s)'); ylabel(ax3,'Amplitude'); title(ax3,'Right - time'); grid(ax3,'on');
ax4 = nexttile(tl2); plot(ax4, f_right, Xright_db); xlabel(ax4,'Frequency (Hz)'); ylabel(ax4,'Magnitude (dB)'); title(ax4,'Right - frequency'); grid(ax4,'on');

% Stereo tab (both channels in time + stereo frequency)
t3 = uitab(tg,'Title','Stereo');
tl3 = tiledlayout(t3,2,1,'Padding','compact','TileSpacing','compact');
ax5 = nexttile(tl3); plot(ax5, t, audioData(:,1), t, audioData(:,2)); xlabel(ax5,'Time (s)'); ylabel(ax5,'Amplitude'); title(ax5,'Stereo - time'); legend(ax5,{'Left','Right'}); grid(ax5,'on');
ax6 = nexttile(tl3); plot(ax6, f_stereo, Xstereo_db); xlabel(ax6,'Frequency (Hz)'); ylabel(ax6,'Magnitude (dB)'); title(ax6,'Stereo - frequency'); grid(ax6,'on');

% Spectrograms tab (three spectrograms stacked)
t4 = uitab(tg,'Title','Spectrograms');
tl4 = tiledlayout(t4,3,1,'Padding','compact','TileSpacing','compact');
ax7 = nexttile(tl4); imagesc(ax7, t_left_stft, f_left_stft, 20*log10(magl + eps)); axis(ax7,'xy'); ylim(ax7,[0 8000]); title(ax7,'Left Channel Spectrogram'); xlabel(ax7,'Time (s)'); ylabel(ax7,'Frequency (Hz)'); colorbar(ax7);
ax8 = nexttile(tl4); imagesc(ax8, t_right_stft, f_right_stft, 20*log10(magr + eps)); axis(ax8,'xy'); ylim(ax8,[0 8000]); title(ax8,'Right Channel Spectrogram'); xlabel(ax8,'Time (s)'); ylabel(ax8,'Frequency (Hz)'); colorbar(ax8);
ax9 = nexttile(tl4); imagesc(ax9, t_stereo_stft, f_stereo_stft, 20*log10(mags + eps)); axis(ax9,'xy'); ylim(ax9,[0 8000]); title(ax9,'Stereo Spectrogram'); xlabel(ax9,'Time (s)'); ylabel(ax9,'Frequency (Hz)'); colorbar(ax9);

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

figure('Name', 'Spectrograms','NumberTitle','off','units','normalized', 'Position', [0.05 0.05 0.9 0.8]);
subplot(3,1,1); imagesc(t_left_stft, f_left_stft, 20*log10(magl + eps)); axis xy; ylim([0 8000]); title('Left Channel Spectrogram'); xlabel('Time (s)'); ylabel('Frequency (Hz)'); colorbar;
grid on;
subplot(3,1,2); imagesc(t_right_stft, f_right_stft, 20*log10(magr + eps)); axis xy; ylim([0 8000]); title('Right Channel Spectrogram'); xlabel('Time (s)'); ylabel('Frequency (Hz)'); colorbar;
grid on;
subplot(3,1,3); imagesc(t_stereo_stft, f_stereo_stft, 20*log10(mags + eps)); axis xy; ylim([0 8000]); title('Stereo Spectrogram'); xlabel('Time (s)'); ylabel('Frequency (Hz)'); colorbar;
grid on;

%% Prepare music-only estimate

%% Local functions
function [f_axis, xmag_db] = single_sided_fft_plot(sig, fs)
    N = length(sig);
    x = fft(sig);
    half = floor(N/2);
    f_axis = (0:half)*(fs/N);
    xmag = abs(x(1:half+1))/N;
    if half > 1
        xmag(2:end-1) = 2*xmag(2:end-1);
    end
    xmag_db = 20*log10(xmag + eps);
end

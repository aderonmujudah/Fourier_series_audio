fs = 44100;
nBits = 16;
nChannels = 1;
recObj = audiorecorder(fs, nBits, nChannels);

disp('start speaking...')
recordblocking(recObj, 5); % Record audio for 5 seconds
disp('end of recording.');

rec_audio = getaudiodata(recObj);

sound(rec_audio, fs); % Play the audio
plot(rec_audio);      % Visualise the waveform
xlabel('Sample number');
ylabel('Amplitude');
title('Time-domain waveform of audio');
audiowrite("rec_audio3.mp3", rec_audio, fs);
%% 

[rec_audio, fs] = audioread('rec_audio2.mp3');

N = length(rec_audio);
t = (0:N-1)/fs;

plot(t, rec_audio);
xlabel('Time (s)');
ylabel('Amplitude');
title('Time-domain waveform of recorded audio');
grid on;

%% 
x = fft(rec_audio);
N = length(rec_audio);
f = (0:N-1)*(fs/N);

x_mag = abs(x)/N;
plot(f(1:N/2), x_mag(1:N/2)*2);
xlabel('Frequency (Hz)');
ylabel('Magnitude');
title('Magnitude Spectrum of Audio Signal');
grid on;

f1 = 0;
f2 = 800;
mask = (f >= f1 & f <= f2);
x_filtered = x .* mask.';
filt_audio = ifft(x_filtered, "symmetric");
sound(filt_audio, fs);
%[b, a] = butter(4, [f1 f2]/(fs/2), 'bandpass');
%filtered_audio = filter(b, a, rec_audio);
audiowrite('onlyaudio2.mp3', filt_audio, fs);

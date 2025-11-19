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

audiowrite("rec_audio.mp3", rec_audio, fs);
function t = HelperComputePitchAndMFCC_mine(filename)
%HelperComputePitchAndMFCC Compute pitch and MFCC features
% This function performs the following actions on a binary file containing
% audio samples:
% 1. Read audio and convert it to double-precision.
% 2. Divide the audio into frames of size 30ms with overlap of 75%.
% 3. For each frame, determine if it contains voiced speech.
% 4. For voiced speech frames, compute pitch and 13 MFCCs.
%
% The output of this function is a table containing filename, pitch, MFCCs,
% and speaker name as columns. The structure is an array because each file
% will have these values for multiple frames. NaNs indicate that the frame
% was not voiced speech.
%
% This function HelperComputePitchAndMFCC is only in support of
% SpeakerIdentificationExample. It may change in a future release.

%   Copyright 2017 The MathWorks, Inc.

fs = 8e3;

% Read binary data (stored as int16)
fid = fopen(filename,'r');
xint = int16(fread(fid,[1,inf],'int16')).';
fclose(fid);

% Scale int16 to double
x = double(xint)*2^-15;

% Compute pitch and MFCC for frames of the file
[pitch, mfcc] = computePitchMFCC(x,fs);

filenamesplit = regexp(filename, filesep, 'split');
% filenamesplit{end-1}

% Output structure
s = struct();
s.Filename = repmat({filenamesplit{end}},size(pitch))
s.Pitch=pitch;
s.MFCC1 = mfcc(:,1);
s.MFCC2 = mfcc(:,2);
s.MFCC3 = mfcc(:,3);
s.MFCC4 = mfcc(:,4);
s.MFCC5 = mfcc(:,5);
s.MFCC6 = mfcc(:,6);
s.MFCC7 = mfcc(:,7);
s.MFCC8 = mfcc(:,8);
s.MFCC9 = mfcc(:,9);
s.MFCC10 = mfcc(:,10);
s.MFCC11 = mfcc(:,11);
s.MFCC12 = mfcc(:,12);
s.MFCC13 = mfcc(:,13);
s.Label = repmat({filenamesplit{end-1}},size(pitch));

t = struct2table(s);
end

function [pitch, mfcc] = computePitchMFCC(x,fs)

highCutoff = 600; % Pitch will not be higher than this
lowCutoff = 50;  % Pitch will not be lower than this
pwrThreshold = -50; % Frames with power below this threshold are likely to be silence
freqThreshold = 1000; % Frames with zero crossing rate above this threshold are likely to be silence or unvoiced speech
clipLevel = 68; % Center clip level for pitch detection

bpf = audiopluginexample.VarSlopeBandpassFilter(lowCutoff,highCutoff,'48','48');
interp4 = dsp.FIRInterpolator(8,designMultirateFIR(4,1));
interp8 = dsp.FIRInterpolator(8,designMultirateFIR(8,1));
interp12 = dsp.FIRInterpolator(8,designMultirateFIR(12,1));
interp16 = dsp.FIRInterpolator(8,designMultirateFIR(16,1));
interp20 = dsp.FIRInterpolator(8,designMultirateFIR(20,1));
mfccComputer = audioexample.MelFrequencyCepstralCoefficients('SampleRate',fs);

% Audio data will be divided into frames of 30 ms with 75% overlap
frameTime = 30e-3;
samplesPerFrame = floor(frameTime*fs); 
startIdx = 1;
stopIdx = samplesPerFrame;
increment = floor(0.25*samplesPerFrame);
pitch = [];
mfcc = [];
pPrev = nan;

while 1
    xFrame = x(startIdx:stopIdx,1); % 30ms frame
    p = nan;
    
    % Compute pitch
    if audiopluginexample.SpeechPitchDetector.isVoicedSpeech(xFrame,fs,...
            pwrThreshold,freqThreshold)
        xFiltered = bpf(xFrame);
        p = audiopluginexample.SpeechPitchDetector.autoCorrelationPitchDecision(...
            xFiltered,fs,clipLevel,frameTime,interp4,interp8,interp12,...
            interp16,interp20,highCutoff,lowCutoff);
        p = audiopluginexample.SpeechPitchDetector.penalizeJumps(pPrev,p,20);
    end
    pitch = [pitch; p];
    pPrev = p;
    
    % Compute MFCC
    if ~isnan(p)
        [c,logE] = mfccComputer(xFrame);
        c(1) = logE;
    else
        c = nan(13,1);
    end
    mfcc = [mfcc; c.'];

    startIdx = startIdx + increment;
    stopIdx = stopIdx + increment;
    if stopIdx > size(x,1)
        break;
    end
end

end
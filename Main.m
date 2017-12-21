% recording using audioDeviceReader i.e dealing one frame at a time.
% deviceReader = audioDeviceReader;  %default sample rate  - 44100 Hz
% disp('Begin Signal Input...')
% tic
% i = 0;
% while toc<1
%     mySignal = deviceReader();
%     i = i+1;
%     myProcessedSignal = process(mySignal);
%     deviceWriter(myProcessedSignal);
% end
% disp('End Signal Input')

% % recording the test signal using audiorecorder
        i = 1;
     Fs = 8000;
     filepart1='D:\Downloads\DC_PROJECT\test\test';
     filepart2='.wav';
     disp('Record now'); 
     obj_record = audiorecorder(Fs,8,1);   %an object is created 
     recordblocking(obj_record, 2);        %recording the data for 5 sec
     y=getaudiodata(obj_record);           %getting the recorded data in form of matrix
     disp('Recording Finished');
     filename=strcat(filepart1,num2str(i),filepart2);
     audiowrite(filename,y,Fs);
    
% ta = HelperComputePitchAndMFCC_mine(filename)
% % plotting the recorded signal
% timeVector = linspace(0,5,numel(y));
% plot(timeVector,y);
% axis([0 5 -1 1]);
% ylabel('Amplitude');
% xlabel('Time (s)');
% title('');

trainingDatabase = datastore('My_Recordings', 'IncludeSubfolders', true,...
    'FileExtensions', '.wav', 'Type', 'file', 'UniformRead', true, ...
    'ReadFcn', @HelperComputePitchAndMFCC_mine);

features = readall(trainingDatabase);
features = rmmissing(features);
head(features)   % Display the first few rows

m = mean(features{:,2:15}); 
s = std(features{:,2:15});
features{:,2:15} = (features{:,2:15}-m)./s;
head(features)   % Display the first few rows

%training the classifier
[trainedClassifier, validationAccuracy, confMatrix] = ...
    HelperTrainKNNClassifier_mine(features);
fprintf('\nValidation accuracy = %.2f%%\n', validationAccuracy*100);
heatmap(trainedClassifier.ClassNames, trainedClassifier.ClassNames, ...
    confMatrix);
title('Confusion Matrix');

%extract the features of the test speech
features_test = HelperComputePitchAndMFCC_mine(filename);
features_test = rmmissing(features_test);
features_test{:,2:15} = (features_test{:,2:15}-m)./s; 
head(features_test)   % Display the first few rows

result = HelperTestKNNClassifier(trainedClassifier, features_test)

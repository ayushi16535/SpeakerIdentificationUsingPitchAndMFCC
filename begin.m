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
     
     deviceWriter = audioDeviceWriter('SampleRate',16000);
     
     features_test = HelperComputePitchAndMFCC_mine(filename);
     features_test = rmmissing(features_test);
     features_test{:,2:15} = (features_test{:,2:15}-m)./s; 
     head(features_test)   % Display the first few rows

%result = HelperTestKNNClassifier_mine(trainedClassifier, features_test)
     T = features_test(:,2:end-1);
     predictedLabels = string(predict(trainedClassifier,T)); % Predict
     [predictedLabel, freq] = mode(predictedLabels) % Find most frequently predicted label
     if predictedLabel == "Female_ayushi"
         deviceWriter(audioread('Hello_ayushi.wav'));
     elseif predictedLabel == "Female_anshu"
         deviceWriter(audioread('Hello_anshu.wav'));
     else
         deviceWriter(audioread('Hello_unknown.wav'));
     end
     
     
         
      
         
     
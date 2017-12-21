% % Word recognition in MATLAB
% % Author : Dr. Selvaraaju Murugesan, LaTrobe University, Ausralia
% % Date : 09-07-2014

% % Use this file to record your work

% % You have to record your word ten times

% %  Change the filepart1 string for each word


w = warning ('off','all');
clc; clear;close all
Duration=2;
Fs=8000;
filepart1='anshu_sent3';
filepart2='.wav';
for i = 1:5
 
    disp('Record now'); 
    obj_record = audiorecorder(Fs,8,1);   %an object is created 
    recordblocking(obj_record, 5);        %recording the data for 5 sec
    y=getaudiodata(obj_record);           %getting the recorded data in form of matrix
    disp('Recording Finished');
    filename=strcat(filepart1,num2str(i),filepart2);
    audiowrite(filename,y,Fs);
end
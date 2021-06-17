clear all;


imagefolder = 'C:\Users\Benjamin Ong\Desktop\Year 3\FYP_temp\HOG\Video_complex_1_Output\All\';
out_folder = 'C:\Users\Benjamin Ong\Desktop\Year 3\FYP_temp\All_videos_out\'; 
filepattern = fullfile(imagefolder, '*.png');

imagefiles = dir(filepattern);
nfiles = length(imagefiles);

vid_name = 'HOG_Complex_1_OUT';
v = VideoWriter([out_folder,vid_name]);
v.FrameRate = 10;
open(v);

for ii=1:nfiles
    currentbasefilename = imagefiles(ii).name;
    currentfilename = fullfile(imagefolder, currentbasefilename);
    
    %run individual photo through model
    I = imread(currentfilename);
    writeVideo(v,I);
end
close(v)
%     
% open(v)
% v.FrameRate = 1;
% close(v)

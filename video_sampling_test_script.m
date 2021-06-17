clear all;

file_path = 'C:\Users\Benjamin Ong\Desktop\Year 3\FYP_temp\Datasets\Videos\Raw';
file_name = 'complex_4.mp4';
full_file_name = fullfile(file_path,file_name);
file_destination = 'C:\Users\Benjamin Ong\Desktop\Year 3\FYP_temp\Datasets\Videos\Sampled_Outputs\Video_sampled_complex_4';



v = VideoReader(full_file_name);
total_framez = v.Numframes;
% v.CurrentTime = 0.5;

%for loop for readin and saving first 10 frames
for iFrame = 1:total_framez
%     if mod(iFrame,10) == 0
%         frames = read(v, iFrame);
%         imwrite(frames, fullfile(file_destination, sprintf('%06d.jpg', iFrame)));
%     end
    thisframe=read(v,iFrame);
    figure(1);imagesc(thisframe);
    thisfile = fullfile(file_destination, sprintf('%06d.png', iFrame));
%     thisfile=sprintf('C:\Users\Benjamin Ong\Desktop\Year 3\FYP_temp\Datasets\Videos\Image_frames\frame_%04d.jpg',iFrame);
    imwrite(thisframe,thisfile);

end 
% frame_count = 10;

% while hasFrame(v)
%     if mod(frame_count,10) == 0
%         frames = read(v, frame_count);
%         tmp = int2str(frame_count);
%         out_name = [file_destination, '\', tmp, '.png'];
%         imwrite(frames, out_name);
%     end
%     
%     frame_count = frame_count+1;
% end

%playin the video by frames
% currAxes = axes;
% while hasFrame(v)
%     vidFrame = readFrame(v);
%     image(vidFrame, 'Parent', currAxes);
%     currAxes.Visible = 'off';
%     pause(1/v.FrameRate);
% end


%code to read file saved
% FileList = dir(fullfile(file_destination, '*.jpg'));
% for iFile = 1:length(FileList)
%   aFile = fullfile(file_destination, FileList(iFile).name);
%   img   = imread(aFile);
% end
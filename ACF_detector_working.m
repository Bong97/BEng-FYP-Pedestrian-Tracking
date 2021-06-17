clear all;
% imagefolder = 'C:\Users\Benjamin Ong\Desktop\Year 3\FYP_temp\Datasets\Images\PennFudanPed\PNGImages\';
% imagefolder = 'C:\Users\Benjamin Ong\Desktop\Year 3\FYP_temp\Datasets\Videos\Image_frames';
% out_folder = 'C:\Users\Benjamin Ong\Desktop\Year 3\FYP_temp\ACF\Output\'; 
imagefolder = 'C:\Users\Benjamin Ong\Desktop\Year 3\FYP_temp\Datasets\Videos\Sampled_Outputs\Video_sampled_mum_4';
out_folder = 'C:\Users\Benjamin Ong\Desktop\Year 3\FYP_temp\ACF\Video_Mum_4_Output\';

filepattern = fullfile(imagefolder, '*.png');
imagefiles = dir(filepattern);
% myexcel = 'C:\Users\Benjamin Ong\Desktop\Year 3\FYP_temp\ACF\Output\ACF_predicted_data.xlsx';

Detector = peopleDetectorACF;

nfiles = length(imagefiles);    % Number of files found
detected_count = 0;
not_detected_count = 0;
image_nameArray = {'image name'};
Detection_count_array_per_image = {'detection count per image'};
bboxes_list = [];
BB_list = [];

for ii=1:nfiles
    %get individual photo
    currentbasefilename = imagefiles(ii).name;
    currentfilename = fullfile(imagefolder, currentbasefilename);
    
    %run individual photo through model
    I = imread(currentfilename);
    [bboxes,scores] = detect(Detector,I); %this is the detection algorithm (HOG)
    
    [num_detected,tmp] = size(scores);
    image_nameArray = [image_nameArray, currentbasefilename];
    Detection_count_array_per_image = [Detection_count_array_per_image, num_detected];
    
    if isempty(scores)
        image_out_name = [out_folder,'Not_detected\', currentbasefilename];
        imwrite(I, image_out_name)
        bb = [-1, -1, -1, -1];
        bboxes_list = [bboxes_list;bb];
    else
        I = insertObjectAnnotation(I,'rectangle',bboxes,scores);
        image_out_name = [out_folder,'Detected\', currentbasefilename];
        imwrite(I, image_out_name)
        for k=1:size(bboxes,1)
            BB_temp = [ii,bboxes(k,:)];
            BB_list = [BB_list;BB_temp];
        end
    end
end
myexcel = 'C:\Users\Benjamin Ong\Desktop\Year 3\FYP_temp\ACF\Video_Mum_4_Output\ACF_predicted_mum_4_data.xlsx';

%write to excel
cell_array = [image_nameArray; Detection_count_array_per_image];
writecell(cell_array',myexcel)

BB_excel = 'C:\Users\Benjamin Ong\Desktop\Year 3\FYP_temp\ACF\Video_Mum_4_Output\ACF_predicted_mum_4_bb.xlsx';
writematrix(BB_list,BB_excel)
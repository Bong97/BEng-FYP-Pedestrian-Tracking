clear all;

% file names etc
% imagefolder = 'C:\Users\Benjamin Ong\Desktop\Year 3\FYP_temp\Datasets\Images\PennFudanPed\PNGImages\';
imagefolder = 'C:\Users\Benjamin Ong\Desktop\Year 3\FYP_temp\Datasets\Videos\Sampled_Outputs\Video_sampled_Mum_1';
out_folder = 'C:\Users\Benjamin Ong\Desktop\Year 3\FYP_temp\HOG\Video_Mum_1_Output\';
peopleDetector = vision.PeopleDetector;
filepattern = fullfile(imagefolder, '*.png');
imagefiles = dir(filepattern);
BB_list = [];

nfiles = length(imagefiles);    % Number of files found
image_nameArray = {'image name'};
Detection_count_array_per_image = {'detection count per image'};
bboxes_list = [];

for ii=1:nfiles
    %get individual photo
    currentbasefilename = imagefiles(ii).name;
    currentfilename = fullfile(imagefolder, currentbasefilename);
    I = imread(currentfilename);
    
    %run individual photo through model
    [bboxes,scores] = peopleDetector(I); %this is the detection algorithm (HOG)
    
    [num_detected,tmp] = size(scores);
    image_nameArray = [image_nameArray, currentbasefilename];
    Detection_count_array_per_image = [Detection_count_array_per_image, num_detected];
    

    if isempty(scores)
        image_out_name = [out_folder,'Not_detected\', currentbasefilename];
        imwrite(I, image_out_name)
%         bb = [-1, -1, -1, -1];
%         bboxes_list = [bboxes_list;bb];
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
myexcel = 'C:\Users\Benjamin Ong\Desktop\Year 3\FYP_temp\HOG\Video_Mum_1_Output\HOG_predicted_mum_1_data.xlsx';
%write to excel
cell_array = [image_nameArray; Detection_count_array_per_image];
writecell(cell_array',myexcel)

BB_excel = 'C:\Users\Benjamin Ong\Desktop\Year 3\FYP_temp\HOG\Video_Mum_1_Output\HOG_predicted_mum_1_bb.xlsx';
writematrix(BB_list,BB_excel)



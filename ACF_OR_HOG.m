clear all;

imagefolder = 'C:\Users\Benjamin Ong\Desktop\Year 3\FYP_temp\Datasets\Videos\Sampled_Outputs\Video_sampled_Mum_4';

filepattern = fullfile(imagefolder, '*.png');
imagefiles = dir(filepattern);

HOGDetector = vision.PeopleDetector;
ACFDetector = peopleDetectorACF;

nfiles = length(imagefiles);    % Number of files found
image_nameArray = {'image name'};
Detection_count_array_per_image = {'detection count per image'};
bboxes_list = [];
BB_list = [];

for ii=1:nfiles
    num_detected_for_image = 0;
    BB_HOG_AND_ACF = [];
    %get individual photo
    currentbasefilename = imagefiles(ii).name;
    currentfilename = fullfile(imagefolder, currentbasefilename);
    IM = imread(currentfilename);
    
    %run individual photo through each model to get BB and score
    [HOG_bbox,HOG_scores] = HOGDetector(IM); %this is the detection algorithm (HOG)
    [ACF_bbox,ACF_scores] = detect(ACFDetector,IM); %this is the detection algorithm (ACF)

    [HOG_num_detected,HOG_tmp] = size(HOG_scores);
    [ACF_num_detected,ACF_tmp] = size(ACF_scores);
    
    % the AND portion
    
    %if statement for case 1: more HOGs than ACFs
    if HOG_num_detected >= ACF_num_detected
        %iterate through HOG to find an ACF with a top left coord within
        %25% of hypotenuse of HOG
        for i=1:HOG_num_detected
            HOG_top_left_coord = [HOG_bbox(i,1), HOG_bbox(i,2)];
            HOG_Hyp_length = hypot(HOG_bbox(i,3), HOG_bbox(i,4));
            HOG_area = HOG_bbox(i,3) * HOG_bbox(i,4);
            ADDED = false;
            for j=1:ACF_num_detected
                ACF_top_left_coord = [ACF_bbox(j,1), ACF_bbox(j,2)];
                distance_between_HOG_ACF = norm(HOG_top_left_coord - ACF_top_left_coord);
                ACF_area = ACF_bbox(j,3) * ACF_bbox(j,4);
                if (distance_between_HOG_ACF <= HOG_Hyp_length*0.25)
                    if (ACF_area >= 0.5*HOG_area) || (ACF_area <= 1.5*HOG_area)
                        num_detected_for_image = num_detected_for_image + 1;
                        BB_1 = (HOG_bbox(i,1) + ACF_bbox(j,1))/2;
                        BB_2 = (HOG_bbox(i,2) + ACF_bbox(j,2))/2;
                        BB_3 = (HOG_bbox(i,3) + ACF_bbox(j,3))/2;
                        BB_4 = (HOG_bbox(i,4) + ACF_bbox(j,4))/2;
                        BB_HOG_AND_ACF_temp = [ii,BB_1, BB_2, BB_3, BB_4];
                        BB_HOG_AND_ACF = [BB_HOG_AND_ACF;BB_HOG_AND_ACF_temp];
                        ADDED = true;
                    end
                end
            end
            %after iterating through all of acf, if there is no similar
            %ones, add it without any averaging
            if ADDED == false
                for A=1:size(HOG_bbox,1)
                    BB_HOG_AND_ACF_temp = [ii,HOG_bbox(A,:)];
                    BB_HOG_AND_ACF = [BB_HOG_AND_ACF;BB_HOG_AND_ACF_temp];
                    num_detected_for_image = num_detected_for_image + 1;
                end
                ADDED = true;
            end
        end
    end
    if HOG_num_detected < ACF_num_detected
        %iterate through HOG to find an ACF with a top left coord within
        %25% of hypotenuse of HOG
        for i=1:ACF_num_detected
            ACF_top_left_coord = [ACF_bbox(i,1), ACF_bbox(i,2)];
            ACF_Hyp_length = hypot(ACF_bbox(i,3), ACF_bbox(i,4));
            ACF_area = ACF_bbox(i,3) * ACF_bbox(i,4);
            ADDED = false;
            for j=1:HOG_num_detected
                HOG_top_left_coord = [HOG_bbox(j,1), HOG_bbox(j,2)];
                distance_between_HOG_ACF = norm(HOG_top_left_coord - ACF_top_left_coord);
                HOG_area = HOG_bbox(j,3) * HOG_bbox(j,4);
                if (distance_between_HOG_ACF <= HOG_Hyp_length*0.25)
                    if (HOG_area >= 0.5*ACF_area) || (HOG_area <= 1.5*ACF_area)
                        num_detected_for_image = num_detected_for_image + 1;
                        BB_1 = (ACF_bbox(i,1) + HOG_bbox(j,1))/2;
                        BB_2 = (ACF_bbox(i,2) + HOG_bbox(j,2))/2;
                        BB_3 = (ACF_bbox(i,3) + HOG_bbox(j,3))/2;
                        BB_4 = (ACF_bbox(i,4) + HOG_bbox(j,4))/2;
                        BB_HOG_AND_ACF_temp = [ii,BB_1, BB_2, BB_3, BB_4];
                        BB_HOG_AND_ACF = [BB_HOG_AND_ACF;BB_HOG_AND_ACF_temp];
                        ADDED = true;
                    end
                end
            end
            if ADDED == false
                for A=1:size(ACF_bbox,1)
                    BB_HOG_AND_ACF_temp = [ii,ACF_bbox(A,:)];
                    BB_HOG_AND_ACF = [BB_HOG_AND_ACF;BB_HOG_AND_ACF_temp];
                    num_detected_for_image = num_detected_for_image + 1;
                end
                ADDED = true;
            end
        end
    end
    BB_list = [BB_list;BB_HOG_AND_ACF];
    label_str = [];
    for k=1:num_detected_for_image
        label_str{k} = ['Person: ' num2str(k)];
    end
    
    
    image_nameArray = [image_nameArray, currentbasefilename];
    Detection_count_array_per_image = [Detection_count_array_per_image, num_detected_for_image];
    
    
%     %writing for HOG
%     HOG_out_folder = 'C:\Users\Benjamin Ong\Desktop\Year 3\FYP_temp\ACF_OR_HOG\HOG_out\'; 
%     if isempty(HOG_scores)
%         image_out_name = [HOG_out_folder,'Not_detected\', currentbasefilename];
%         imwrite(IM, image_out_name);
%     else
%         HOG_IM = insertObjectAnnotation(IM,'rectangle',HOG_bbox,HOG_scores);
%         image_out_name = [HOG_out_folder,'Detected\', currentbasefilename];
%         imwrite(HOG_IM, image_out_name);
%     end
%     
%     %writing for ACF
%     ACF_out_folder = 'C:\Users\Benjamin Ong\Desktop\Year 3\FYP_temp\ACF_OR_HOG\ACF_out\'; 
% 
%     if isempty(ACF_scores)
%         image_out_name = [ACF_out_folder,'Not_detected\', currentbasefilename];
%         imwrite(IM, image_out_name);
%     else
%         ACF_IM = insertObjectAnnotation(IM,'rectangle',ACF_bbox,ACF_scores);
%         image_out_name = [ACF_out_folder,'Detected\', currentbasefilename];
%         imwrite(ACF_IM, image_out_name);
%     end
%     
    %writing for ACF_AND_HOG
    ACF_AND_HOG_out_folder = 'C:\Users\Benjamin Ong\Desktop\Year 3\FYP_temp\ACF_OR_HOG\ACF_OR_HOG_OUT\Video_Mum_4_Output\'; 

    if (num_detected_for_image == 0)
        image_out_name = [ACF_AND_HOG_out_folder,'Not_detected\', currentbasefilename];
        imwrite(IM, image_out_name)
    else
        BB_PASTE = BB_HOG_AND_ACF;
        BB_PASTE(:,1) = [];
        HOG_ACF_IM = insertObjectAnnotation(IM,'rectangle',BB_PASTE, label_str);
        image_out_name = [ACF_AND_HOG_out_folder,'Detected\', currentbasefilename];
        imwrite(HOG_ACF_IM, image_out_name);
    end
end
myexcel = 'C:\Users\Benjamin Ong\Desktop\Year 3\FYP_temp\ACF_OR_HOG\ACF_OR_HOG_OUT\Video_Mum_4_Output\ACF_OR_HOG_predicted_mum_4_data.xlsx';
cell_array = [image_nameArray; Detection_count_array_per_image];
writecell(cell_array',myexcel)

BB_excel = 'C:\Users\Benjamin Ong\Desktop\Year 3\FYP_temp\ACF_OR_HOG\ACF_OR_HOG_out\Video_Mum_4_Output\ACF_OR_HOG_predicted_mum_4_bb.xlsx';
% cell_array = [image_nameArray; Detection_count_array_per_image];
writematrix(BB_list,BB_excel)
clear all;


gtruth_data_path = 'C:\Users\Benjamin Ong\Desktop\Year 3\FYP_temp\Datasets\Videos\Labelled_videos\gtruth_BB_mum_1.xlsx';
predicted_data_BB = 'C:\Users\Benjamin Ong\Desktop\Year 3\FYP_temp\ACF_OR_HOG\ACF_OR_HOG_OUT\Video_Mum_1_Output\ACF_OR_HOG_predicted_Mum_1_bb.xlsx';
predicted_data = 'C:\Users\Benjamin Ong\Desktop\Year 3\FYP_temp\ACF_OR_HOG\ACF_OR_HOG_OUT\Video_Mum_1_Output\ACF_OR_HOG_predicted_Mum_1_data.xlsx';

[g_truth_BB,tmp_1,RAW_Gtruth_1]= xlsread(gtruth_data_path);
[predicted_persons,header,RAW_pred]= xlsread(predicted_data);
[predicted_persons_BB,~,~]= xlsread(predicted_data_BB);

[nfiles,n_col]= size(g_truth_BB);
[nfiles_pred,n_col_pred]= size(predicted_persons_BB);

total_true_positive = 0;
total_true_negative = 0;
total_false_negative = 0;
total_false_positive = 0;
total_Bad_BB_area = 0;
total_Bad_BB_location = 0;

track_record = zeros(1,nfiles);
True_positive_list = [];
True_negative_list = [];
false_negative_list = [];
false_positive_list = [];
Bad_bb_area_list = [];
Bad_bb_loc_list = [];

temp_list = [];
for i=1:nfiles
    im_num = i;
    %for this image, create list of gtruth BBs
%     g_truth_bb_1 = [g_truth_BB(i,2) g_truth_BB(i,3) g_truth_BB(i,4) g_truth_BB(i,5)];
%     g_truth_bb_2 = [g_truth_BB(i,6) g_truth_BB(i,7) g_truth_BB(i,8) g_truth_BB(i,9)];
%     g_truth_bbs = [g_truth_bb_1; g_truth_bb_2];
    g_truth_bbs = [g_truth_BB(i,1) g_truth_BB(i,2) g_truth_BB(i,3) g_truth_BB(i,4)];
    false_negative_count = 0;
    false_positive_count = 0;
    num_gtruth_BB_exist = 0;
    for t=1:size(g_truth_bbs,1) %find gtruth num exist for this image
        if g_truth_bbs(t,:) ~= [-1 -1 -1 -1]
            num_gtruth_BB_exist = num_gtruth_BB_exist + 1;

        end
    end
    temp_list = [temp_list; i,num_gtruth_BB_exist];        
    pred_list = [];
    pred_exist = 0;
    for j=1:nfiles_pred %create a list of predicted bbs that correspond to the current image and the num exist
        
        if predicted_persons_BB(j,1) == im_num
%             temp = [predicted_persons_BB(j,2) predicted_persons_BB(j,3) predicted_persons_BB(j,4) predicted_persons_BB(j,5)];
            temp = [predicted_persons_BB(j,1) predicted_persons_BB(j,2) predicted_persons_BB(j,3) predicted_persons_BB(j,4)];
            if temp == [-1 -1 -1 -1]
                pred_exist = pred_exist + 1;
            end
            pred_list = [pred_list;temp];
        end
    end
    
    %find True negative count
    if (num_gtruth_BB_exist == 0) && (pred_exist == 0)
        total_true_negative = total_true_negative + 1;
        True_negative_list = [True_negative_list; im_num];
    else
        %for each of the GTruth BBs
        for k=1:size(g_truth_bbs,1)
            %4 info needed for gtruth BB, the existence is done above
            True_BB_top_left = [g_truth_bbs(k,1), g_truth_bbs(k,2)];
            True_BB_area = g_truth_bbs(k,1) * g_truth_bbs(k,2);
            True_BB_hypot = hypot(g_truth_bbs(k,3), g_truth_bbs(k,4));
            found = 0;
            found_bool = false;
            used_list = [];
            %for each of the Gtruth BBs, Look through the Pred BB
            for j=1:size(pred_list,1)
                if found_bool == false
                    %3 basic informations of pred_BB, existence is done above
                    pred_BB = pred_list(j,:);
                    pred_BB_area = pred_BB(1,3) * pred_BB(1,4);
                    pred_BB_top_left = [pred_BB(1,1), pred_BB(1,2)];
                    already_used = false;
                    for counter=1:size(used_list,1)
                        if (used_list(counter,:) == pred_BB)
                            already_used = true;
                        end
                    end
                    if already_used == false
                        location_offset = norm(True_BB_top_left - pred_BB_top_left);
                        %if location is less than twice the hypotenuse of true BB
                        %
                        %if found a predicted bb that fits the requirements, store it
                        %as a used bb 
                        if (location_offset < True_BB_hypot/2) %good location difference
                            if (pred_BB_area < True_BB_area) && (pred_BB_area > True_BB_area/4) %good area 1
                                %if range is good but area too small or too big,
                                found = found + 1;
                                used_list = [used_list;pred_BB];
                                total_true_positive = total_true_positive + 1;
                                True_positive_list = [True_positive_list; im_num,found]; %a list of images and their respetive finds
                                track_record(i) = track_record(i) + 1;
                                found_bool = true;
                            elseif (pred_BB_area > True_BB_area) && (pred_BB_area < True_BB_area*4) %good area 2
                                found = found + 1;
                                used_list = [used_list;pred_BB];
                                total_true_positive = total_true_positive + 1;
                                True_positive_list = [True_positive_list; im_num,found];
                                track_record(i) = track_record(i) + 1;
                                found_bool = true;
                            elseif (pred_BB_area < True_BB_area/4) %area too small
                                total_Bad_BB_area = total_Bad_BB_area + 1;
                                Bad_bb_area_list = [Bad_bb_area_list; im_num];
                                %found = found + 1; %took this out to include
                                %the really small areas as false positives
                                false_positive_list = [false_positive_list; im_num];
                            elseif (pred_BB_area > True_BB_area*4) %area too big
                                total_Bad_BB_area = total_Bad_BB_area + 1;
                                Bad_bb_area_list = [Bad_bb_area_list; im_num];
                                found = found + 1;
                            end
                        %if location is not in that half hypot range but within 1.5x
                        %the hypot range, this is a bad location
                        elseif (location_offset > True_BB_hypot/2) && (location_offset < True_BB_hypot) %bad location difference
                            total_Bad_BB_location = total_Bad_BB_location + 1;
                            Bad_bb_loc_list = [Bad_bb_loc_list; im_num];
                            found = found + 1;
                        %elseif (location_offset > True_BB_hypot)
                        %this condition should be the only remaining option
                        end     
                    end %for the if already used == false check
                end %for the iterating through the list of predicted BBs in this image
            end
        end %for the iterating throught all the gtruth BBs for this image
        %after iterating though all the Gtruth BBs and predicted BBs
        %find number of left over Gtruth BBs or left over predicted BBs
        left_over_Gtruth_BBs = num_gtruth_BB_exist - found; %found is +1 for each unique bb with a good location
        left_over_pred_BBs = pred_exist - found; 
        false_negative_count = left_over_Gtruth_BBs;
        false_positive_count = left_over_pred_BBs;
    end
    if false_negative_count > 0
        total_false_negative = total_false_negative + false_negative_count;
        false_negative_list = [false_negative_list;im_num, false_negative_count];
    end
    if false_positive_count > 0
        total_false_positive = total_false_positive + false_positive_count;
        false_positive_list = [false_positive_list; im_num];
    end
end
counter_blank = 0;
true_track = [];
for i=1:nfiles
%     g_truth_bb_1 = [g_truth_BB(i,2) g_truth_BB(i,3) g_truth_BB(i,4) g_truth_BB(i,5)];
%     g_truth_bb_2 = [g_truth_BB(i,6) g_truth_BB(i,7) g_truth_BB(i,8) g_truth_BB(i,9)];
%     counter = 2;
    g_truth_bb_1 = [g_truth_BB(i,1) g_truth_BB(i,2) g_truth_BB(i,3) g_truth_BB(i,4)];
    if g_truth_bb_1 == [-1 -1 -1 -1]
        counter = counter - 1;
        counter_blank = counter_blank + 1;
    end
%     if g_truth_bb_2 == [-1 -1 -1 -1]
%         counter = counter - 1;
%         counter_blank = counter_blank + 1;

%     end
    true_track = [true_track, counter];
    
%     g_truth_bbs = [g_truth_bb_1; g_truth_bb_2];
    g_truth_bbs = g_truth_bb_1;
end
total_correct = total_true_positive + total_true_negative;
% myexcel = 'C:\Users\Benjamin Ong\Desktop\Year 3\FYP_temp\evaluation_results\ACF_OR_HOG_complex_4_track.xlsx';
out = [track_record; true_track];
% writematrix(out',myexcel)
total_labelled_people = sum(true_track,'all');


plot(track_record, 'red');
hold on;
plot(true_track, 'blue');
ylim([-0.5 2.5])

clear all;

%1) read data for HOG Simple_1
%2) reaed data for Gtruth HOG simple_1

gtruth_data_path = 'C:\Users\Benjamin Ong\Desktop\Year 3\FYP_temp\Datasets\Videos\Labelled_videos\gtruth_BB_mum_4.xlsx';
predicted_data = 'C:\Users\Benjamin Ong\Desktop\Year 3\FYP_temp\ACF_OR_HOG\ACF_OR_HOG_out\Video_Mum_4_Output\ACF_OR_HOG_predicted_mum_4_data.xlsx';
predicted_data_BB = 'C:\Users\Benjamin Ong\Desktop\Year 3\FYP_temp\ACF_OR_HOG\ACF_OR_HOG_out\Video_Mum_4_Output\ACF_OR_HOG_predicted_mum_4_bb.xlsx';

[g_truth_BB,tmp_1,RAW_Gtruth_1]= xlsread(gtruth_data_path);
[predicted_persons,header,RAW_pred]= xlsread(predicted_data);
[predicted_persons_BB,~,~]= xlsread(predicted_data_BB);

[nfiles,n_col]= size(g_truth_BB);
[nfiles_pred,n_col_pred]= size(predicted_persons_BB);

% %list of number of detections
% for i=1:nfiles
%     if g_truth_BB(i,:) ~= [-1,-1,-1,-1]
%         g_truth_number_of_detections(i) = 1;
%     else
%         g_truth_number_of_detections(i) = 0;
%     end
% end

%read from the true BBs, for each BB, if there is a predicted BB in the
%desired thresholds, this is a true positive

%for each true BB, if there is a true BB but NO predicted BBs AT ALL, then it is a
%false negative

%for each True BB that is [-1 -1 -1 -1], if there is a predicted BB, it is
%a false positive

%for each True BB, if there IS a BB, and there IS a predicted BB, but it is
%NOT in the THRESHOLD RANGE, it is either bad location or bad area

total_true_positive = 0;
total_true_negative = 0;
total_false_negative = 0;
total_false_positive = 0;
total_Bad_BB_area = 0;
total_Bad_BB_location = 0;

track_record = [];
True_positive_list = [];
True_negative_list = [];
false_negative_list = [];
false_positive_list = [];
Bad_bb_area_list = [];
Bad_bb_loc_list = [];

%iterate through each image in the true bb dataset
for i=1:nfiles
    %total correct predictions true positives
    
    True_BB = g_truth_BB(i,:);
    if True_BB == [-1,-1,-1,-1]
        does_exist = false;
    elseif True_BB ~= [-1 -1 -1 -1]
        does_exist = true;
    end
    found = false;
    %iterate thru predited BBs to find the image
    for j=1:nfiles_pred
        pred_BB = predicted_persons_BB(j,:);
        %if there is a predicted BB for this image,

        if pred_BB(1,1) == i
            found = true;
            %calc fasle positive, negative, True positives+negatives, bad
            %loc bad area, track record
            Pred_BB_top_left = [pred_BB(1,2), pred_BB(1,3)];
            True_BB_top_left = [True_BB(1,1), True_BB(1,2)];

            Pred_BB_area = pred_BB(1,4) * pred_BB(1,5);
            True_BB_area = True_BB(1,3) * True_BB(1,4);

            True_BB_hypot = hypot(True_BB(1,3), True_BB(1,4));
            location_offset = norm(True_BB_top_left - Pred_BB_top_left);

            %True positive if location offset is 1/4 of true bb hypo and
            %area difference is not larger than 4x true area or 4x smaller
            %than true area
            if does_exist == true
                if (location_offset <= True_BB_hypot/4)
                    if (Pred_BB_area > True_BB_area) && (Pred_BB_area < 4*True_BB_area)
                        total_true_positive = total_true_positive + 1;
                        True_positive_list = [True_positive_list, i];
                        track_record(i) = 1;
                    elseif (Pred_BB_area < True_BB_area) && (Pred_BB_area > True_BB_area/4)
                        total_true_positive = total_true_positive + 1;
                        True_positive_list = [True_positive_list, i];
                        track_record(i) = 1;
                    end
                end
                if (location_offset > True_BB_hypot/2)
                    if (location_offset < True_BB_hypot)
                        total_Bad_BB_location = total_Bad_BB_location + 1;
                        Bad_bb_loc_list = [Bad_bb_loc_list, i];
                        track_record(i) = 0;
                    end
                end
                if ((Pred_BB_area >= 4*True_BB_area) || (Pred_BB_area <= True_BB_area/4))
                    if (location_offset < True_BB_hypot)
                        total_Bad_BB_area = total_Bad_BB_area + 1;
                        Bad_bb_area_list = [Bad_bb_area_list, i];
                        track_record(i) = 0;
                    end
                end
            elseif does_exist == false
                total_false_positive = total_false_positive + 1;
                false_positive_list = [false_positive_list,i];
                track_record(i) = 0;
            end
        end      
    end
    if found == false && does_exist == false
        total_true_negative = total_true_negative + 1;
        True_negative_list = [True_negative_list,i];
        track_record(i) = 1;
    elseif (found == false) && (does_exist == true)
        total_false_negative = total_false_negative + 1;
        false_negative_list = [false_negative_list,i];
        track_record(i) = 0;
    end
end
% 
Bad_bb_area_list = unique(Bad_bb_area_list);
Bad_bb_loc_list = unique(Bad_bb_loc_list);

total_correct = total_true_positive + total_true_negative;
myexcel = 'C:\Users\Benjamin Ong\Desktop\Year 3\FYP_temp\evaluation_results\HOG_OR_ACF_simple_4_track.xlsx';
writematrix(track_record',myexcel)

plot(track_record);
ylim([-1 2])
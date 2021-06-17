
labelData = gTruth.LabelData;
labelData
out = [];
nfiles = size(labelData);

nun = [-1, -1, -1, -1];
for i=1:nfiles(1)
    tmp = labelData(i,:).Person_1{1}; 
    if isempty(tmp) %case 1: no people
        bb = [nun,nun];
        pre_out = [i,bb];
    else
        if (size(labelData(i,:).Person_1{1}) == [1,1]) %case 2, 1 person
            bb = tmp.Position;
            pre_out = [i,bb,nun];            
        else
            if (size(labelData(i,:).Person_1{1}) == [1,2]) %case 3, 2 person
                [temp_1,temp_2] = tmp.Position;
                pre_out = [i,temp_1,temp_2];
            else
                if size(labelData(i,:).Person_1{1}) == [2,4] %case 4, 2 person stupid format
                    tmper = labelData(i,:).Person_1{1};
                    tmper_1 = tmper(1,:);
                    tmper_2 = tmper(2,:);
                    pre_out = [i, tmper_1, tmper_2];
                end
            end
        end
    end
    out = [out;pre_out];
end

myexcel = 'C:\Users\Benjamin Ong\Desktop\Year 3\FYP_temp\Datasets\Videos\Labelled_videos\gtruth_BB_complex_1.xlsx';
writematrix(out,myexcel)

labelData = gTruth.LabelData;
labelData
out = [];
nfiles_1 = 162;
nfiles_2 = 203;
nfiles_3 = 135;
nfiles_4 = 195;

for i=1:nfiles_1
    tmp = labelData(i,:).Person_1{1}; 
    if isempty(tmp)
        bb = [-1, -1, -1, -1];
    else

        bb = tmp.Position;
%         bb = tmp; % for some reason mum_1 gtruth variable has unique id
%         so it is already position
    end
    out = [out;bb];
end

myexcel = 'C:\Users\Benjamin Ong\Desktop\Year 3\FYP_temp\Datasets\Videos\Labelled_videos\gtruth_BB_complex_1.xlsx';
writematrix(out,myexcel)
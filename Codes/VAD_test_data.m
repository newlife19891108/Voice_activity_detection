function y = VAD_test_data(index_vector)
addpath('C:\Users\BunnyButt\OneDrive\vad\speech')
addpath('C:\Users\BunnyButt\OneDrive\vad\speech\train')
addpath('C:\Users\BunnyButt\OneDrive\vad\speech\test')


testkeys = importfile('test/key.txt');



summa = 0;
test_features = [];

for index = 1:50
    
    %% Acquie signal and bindary list corresponding to voiced and unvoiced samples
    [signal, fs] = audioread(testkeys{index,1});
    binary_list = getAudioTimeAnswer(testkeys,index,length(signal),fs);  

    %% Implement windowing
    frame_length = round(0.025*fs); % In samples
    hop_size = round(0.0125*fs); % In samples (50% overlap)
    window_types = {'rect','hann','cosine','hamming'};

    frame_matrix = ex1_windowing_solution(signal, frame_length, hop_size, window_types{2});

    %% Create binary index for each frame
    frame = zeros(size(frame_matrix,2), size(frame_matrix,1));
    for i = 1:size(frame_matrix, 2)
        frame(i, :) = (1 + (i -1)*hop_size):(frame_length*i - hop_size*(i-1));    
        test_labels(i+summa) = sum(binary_list(frame(i, :))) > frame_length/2;
 
    end
    

    %% Extract features    
    test_features = feature_extraction(test_features, frame_matrix, fs);
 

    %% Debug if needed

    %{
    waitforbuttonpress
    t=(1:length(signal))'./fs;
    plot(t,signal)
    hold on
    plot(t,binary_list)
    hold on;
    plot((0:0.0125:(size(frame_matrix,2)-1)*0.0125), bin_indexes)
    %}

    summa = summa + size(frame_matrix, 2);
    frame_matrix = [];
end

%% Save features and labels


leave_out_index = 0;
for i =1:length(index_vector)
    if index_vector(i) == 0
        test_features(:, i-leave_out_index) = [];
        leave_out_index = leave_out_index + 1;
        
    end
end


% Write data and labels to csv files

i = num2str(index_vector);
name_part = strcat('test_data.', i);
final_features = strcat(name_part, '.csv');

csvwrite('test_labels.csv', test_labels');
csvwrite(final_features, test_features);

end

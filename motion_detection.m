motion_detection_project();
%main function that will run all 4 algorithms
function motion_detection_project()
frame_folders = ['ArenaA','ArenaN','AShipDeck','getin','getout','movecam','trees','walk'];

run_algorithms('ArenaA');
end

%Function to load and convert the images into grayscale
function frames = load_and_convert(frame_dir)
vid_frames = dir(fullfile(frame_dir, '*.jpg'));
n_files = length(vid_frames); %get the number of frames

grayed_frames = cell(n_files,1); %init the cell array to hold the frames

for frame=1:length(vid_frames)
    file_name = vid_frames(frame).name;
    %Get the full file path for the current frame
    current_frame = fullfile(frame_dir, file_name);

    current_image = imread(current_frame); %read image
    grayed_image = rgb2gray(current_image); %convert image
    grayed_frames{frame} = grayed_image; %add image to cell array
end
frames = grayed_frames;
end

function final = run_algorithms(frame_dir)
%this function will go through a directory frame by frame
%it will read in every frame from the directory, and pass the frame to each
%algorithm, then return a matrix containing the 4 images from each
%algorithm
vid_frames = dir(fullfile(frame_dir, '*.jpg'));
n_files = length(vid_frames); %get the number of frames

grayed_frames = load_and_convert(frame_dir);

M_simple_sub = simple_background_subtraction(grayed_frames,60);
M_simple_diff = simple_frame_differencing(grayed_frames,60);
M_adaptive_background = adaptive_background_subtraction(grayed_frames,0.5,60);
M_persistent_frame_diff = persistent_frame_differencing(grayed_frames, 50, 60);

for fr = 2:size(grayed_frames,1)
    file_name = vid_frames(fr).name;
    final = [M_simple_sub{fr},M_simple_diff{fr};M_adaptive_background{fr},M_persistent_frame_diff{fr}];
    new_file = strcat('TEST_walk',file_name); %This needs to be fixed to dynamically output the new frame images based on the current directory
    imwrite(final, new_file);  
end

end


function M_subtract = simple_background_subtraction(video_frames,threshold)
M_sub_frames = cell(length(video_frames),1);
base_frame = video_frames{1};

for frame=2:length(video_frames)
    diff = abs(base_frame - video_frames{frame});
    M_sub_frames{frame} = diff > threshold;
end 
M_subtract = M_sub_frames;
end

%pdf
function M_diff = simple_frame_differencing(video_frames,threshold)
M_diff_frames = cell(length(video_frames),1);
backgrounds = cell(length(video_frames),1);
backgrounds{1} = video_frames{1};
for frame=2:length(video_frames)
    diff = abs(backgrounds{frame-1} - video_frames{frame});
    M_diff_frames{frame} = diff > threshold;
    backgrounds{frame} = video_frames{frame};
end 
M_diff = M_diff_frames;
end

function M_adapt = adaptive_background_subtraction(video_frames,alpha,threshold)
M_adaptive_frames = cell(length(video_frames),1);
backgrounds = cell(length(video_frames),1);
backgrounds{1} = video_frames{1};

for frame=2:length(video_frames)
    diff = abs(backgrounds{frame-1} - video_frames{frame});
    M_adaptive_frames{frame} = diff > threshold;
    backgrounds{frame} = alpha*video_frames{frame} + (1-alpha)*backgrounds{frame-1};
end 
M_adapt = M_adaptive_frames;
end

function M_persist = persistent_frame_differencing(video_frames, gamma, threshold)
M_persist_frames = cell(length(video_frames),1);
backgrounds = cell(length(video_frames),1);
backgrounds{1} = video_frames{1};
h_vals = cell(length(video_frames),1);

for frame=2:length(video_frames)
    diff = abs(backgrounds{frame-1} - video_frames{frame});
    M_persist_frames{frame} = diff > threshold;
    temp = max(h_vals{frame-1}-gamma, 0);
    h_vals{frame} = max(255*M_persist_frames{frame}, temp);
    backgrounds{frame} = video_frames{frame};
end
M_persist = M_persist_frames;
end
motion_detection_project();
%main function that will run all 4 algorithms
function motion_detection_project()
frame_folders = ['ArenaA','ArenaN','AShipDeck','getin','getout','movecam','trees','walk'];
%here we will call run_algorithms in a loop, iterating through each
%directory in the frame_folders. After getting the results, it will the end
%of the loop will take the result matrix and export it as the 4 panel image
%needed for that frame for the video

%send directory to func
%for i = 1:size(frame_folders)
%run_algorithms
run_algorithms('walk');
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

%Function to get the backgrounds needed for simple frame differencing
function simp_frame_diff_backgrounds = get_simp_frame_diff_backgrounds(frame_dir, grayed_frames)
vid_frames = dir(fullfile(frame_dir, '*.jpg'));
n_files = length(vid_frames); %get the number of frames
simp_frame_diff_backs = cell(n_files,1);

for frame=2:length(vid_frames)
    %calculate the background images for each frame for simple frame diff
    simp_frame_diff_backs{frame} = grayed_frames{frame-1};
end
simp_frame_diff_backgrounds = simp_frame_diff_backs;
end

%Function to get the backgrounds needed for adaptive background
%substitution
function adaptive_back_sub_backgrounds = get_adaptive_back_sub_backgrounds(frame_dir)
vid_frames = dir(fullfile(frame_dir, '*.jpg'));
n_files = length(vid_frames); %get the number of frames
adaptive_back_sub_backgrounds = cell(n_files,1);

end
%Function to get the backgrounds needed for persistent frame differencing
function persistent_frame_diff_backgrounds = get_persistent_frame_diff_backgrounds(frame_dir)
vid_frames = dir(fullfile(frame_dir, '*.jpg'));
n_files = length(vid_frames); %get the number of frames
persistent_frame_diff_backgrounds = cell(n_files,1);

end

function final = run_algorithms(frame_dir)
%this function will go through a directory frame by frame
%it will read in every frame from the directory, and pass the frame to each
%algorithm, then return a matrix containing the 4 images from each
%algorithm
vid_frames = dir(fullfile(frame_dir, '*.jpg'));
n_files = length(vid_frames); %get the number of frames

grayed_frames = load_and_convert(frame_dir);
init_background_frame = grayed_frames{1};

simp_frame_diff_backs = get_simp_frame_diff_backgrounds(frame_dir, grayed_frames);

for fr = 2:size(grayed_frames,1)
    file_name = vid_frames(fr).name;
    
    current_frame = grayed_frames{fr};
    simp_diff_frame_back = simp_frame_diff_backs{fr};
    
    %%%SIMPLE BACKGROUND SUBSTITUTION 
    %Run simple background subtraction
    M_simple_sub = simple_background_subtraction(current_frame,init_background_frame,70);
    %Run simple frame differencing
    M_simple_diff = simple_frame_differencing(current_frame, simp_diff_frame_back, 60);
    

    final = [M_simple_sub,M_simple_diff];%,M_adaptive_background];
    new_file = strcat('new_walk',file_name); %This needs to be fixed to dynamically output the new frame images based on the current directory
    imwrite(final, new_file);
end

end


function M_subtract = simple_background_subtraction(current_frame, base, threshold)
    diff = abs(base - current_frame);
    M_subtract = diff > threshold;
end
%function for simple frame differencing
%This is working, however some back edges are not showing... consider maybe
%playing with this by doing the grayscaling the way he has it in bobtips
%pdf
function M_diff = simple_frame_differencing(current_frame, background, threshold)
    diff = abs(background - current_frame);
    M_diff = diff > threshold;
end
%function for adaptive background subtraction
function M_adapt = adaptive_background_subtraction(g_current_frame, g_prev_frame, threshold)
    diff = abs(g_prev_frame - g_current_frame);
    M_adapt = (diff > threshold);
end
%function for persistent frame differencing
function M_persist = persistent_frame_differencing(frame, threshold, gamma_val)



end
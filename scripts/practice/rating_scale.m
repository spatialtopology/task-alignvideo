function [ratings, times, RT] = rating_scale(p)

% EXPLAIN SCALE
% ********************************************************************
%   Program Name: rating_scale.m 
%   Original Programmer: Taken from Wani Woo's explain_scale.m in
%   www.github.com/canlab/PAINGEN
%   Created: August 12, 2019
%   Project: Spacetop
% This function takes as input a window and a variable containing a set of
% prompts to be rated and outputs the ratings (1-100) and the times of the
% rating.
%
% Input: 
%   1.) p -- the global variable from func_align_video_view_rate_task.m
%   which is a psychtoolbox window
%   2.) rating_prompts -- a cell array containing strings which act as
%   prompts for the rating scales. Also set at the beginning of
%   fun_align_video_view_rate_task.m
%
% Output: 
%   1.) ratings -- a cell array with length size(rating_prompts, 2)
%   containing the 1-100 rating for each rating prompt
%   2.) times -- a cell array with length size(rating_prompts, 2)
%   containing the time that each rating prompt was shown
%   3.) RT -- a cell array with length size(rating_prompts, 2)
%   containing the time that each rating was made by the subject

%% Directory for rating images
prompt_path = 'C:\Users\Dartmouth College\Desktop\Spacetop\func_align_video_task-master\func_align_video_task-master\cues\rating_prompts';


%% Get window
theWindow = p.ptb.window;
% prompt_ex_W = cell(numel(rating_prompts),1)
% for i = 1:numel(rating_prompts)
%     prompt_ex_W{i} = Screen(theWindow, 'DrawText', rating_prompts{i},0,0) 
% end
%% SETUP: Screen
window_rect = [0 0 p.ptb.screenXpixels p.ptb.screenYpixels];
%----------------------------------------------------------------------
%           Configure Screen for rating scale
%----------------------------------------------------------------------

W = window_rect(3); %width of screen
H = window_rect(4); %height of screen

white = 255;
%red = [158 1 66];
red = [255 0 0];
% orange = [255 164 0];

% rating scale left and right bounds 1/4 and 3/4
lb = W/4; 
rb = (3*W)/4;

% Height of the scale (10% of the width; sorry for the poor naming)
scale_W = (rb-lb).*0.2;
anchor_y = H/2+10+scale_W;
anchor_y2 = H/2+10+scale_W+25;

%----------------------------------------------------------------------
%               Configure Screen for rating prompt
%----------------------------------------------------------------------
%%% configure screen
dspl.screenWidth = p.ptb.rect(3);
dspl.screenHeight = p.ptb.rect(4);
dspl.xcenter = dspl.screenWidth/2; 
dspl.ycenter = dspl.screenHeight/2; 

%----------------------------------------------------------------------
%                       Prepare rating prompt images
%----------------------------------------------------------------------
% Return full list of prompt images from directory+pattern:
image_ext = '*.png';
prompt_files=dir(fullfile(prompt_path, image_ext));
if isempty(prompt_files)
    fprintf('ERROR: No images in directory\n')
else
    for i=1:size(prompt_files,1)
        prompt_files(i).name = [ prompt_path filesep prompt_files(i).name ];
    end
end
prompt_count = size(prompt_files,1);


%----------------------------------------------------------------------
%                       Set Up Output Variables
%----------------------------------------------------------------------
times = zeros(prompt_count,1);
ratings = zeros(prompt_count,1);
RT = zeros(prompt_count,1);

%----------------------------------------------------------------------
%                       Begin Rating Loop
%------------------------------------------------------------------
try 
    
for i = 1:prompt_count
    
    % set bar color
    barcolor = white;
    
    % display rating image for correct prompt
    dspl.cscale.width = 964;
    dspl.cscale.height = 480;
    dspl.cscale.w = Screen('OpenOffscreenWindow',p.ptb.screenNumber);
    % paint black
    Screen('FillRect',dspl.cscale.w,0)
    % assign scale image     
    prompt_n = prompt_files(i).name;
    dspl.cscale.texture = Screen('MakeTexture',theWindow, imread(prompt_n));
    
    % placement
    dspl.cscale.rect = [...
        [dspl.xcenter dspl.ycenter]-[0.5*dspl.cscale.width 0.5*dspl.cscale.height] ...
        [dspl.xcenter dspl.ycenter]+[0.5*dspl.cscale.width 0.5*dspl.cscale.height]];
    Screen('DrawTexture',dspl.cscale.w,dspl.cscale.texture,[],dspl.cscale.rect);
    
    % produce screen
    % Screen('CopyWindow',dspl.cscale.w, theWindow);
    
    
    % now set up rating scale below prompt
    SetMouse(lb,H/2); % set mouse at the left
    time_start=GetSecs; %get start time in ms
    button_pressed = false;
    while (1) % button

if ~button_pressed;        
        Screen('CopyWindow',dspl.cscale.w, theWindow);
        [x,~,button] = GetMouse(theWindow);
        if x < lb + 100
            x = lb + 100;
        elseif x > rb - 100
            x = rb - 100;
        end
        
    % set up scale
        xy = [(lb + 100) (H/2+scale_W - 50); (rb - 100) (H/2+scale_W - 50); (rb - 100) H/2];
        Screen(theWindow, 'FillPoly', 255, xy);
        % Screen(theWindow,'DrawText','Not',lb-50,anchor_y,255);
        % Screen(theWindow,'DrawText','at all',lb-50,anchor_y2,255);
        % Screen(theWindow,'DrawText','Strongest',rb-50,anchor_y,255);
        % Screen(theWindow,'DrawText','imaginable',rb-50,anchor_y2,255);

    % draw rating prompt (possible 1-7)
%         Screen('DrawText',theWindow, rating_prompts{i},W/2-prompt_ex_W{i}/2,50,orange);
    % update bar coordinates as mouse moves
        xy = [(lb + 100 ) (H/2 ); (lb + 100 ) (H/2+scale_W - 50)  ; (x )  (H/2+scale_W - 50) ; (x ) (H/2 )];
        Screen('FillPoly', theWindow, barcolor, xy, 1);
    % redraw rating bar with update
        times(i) = Screen('Flip', theWindow);

        % if clicked, go to next step in experimental loop
        if button(1)
            RT(i) = GetSecs-time_start;
    % record x as the rating for this trial
    ratings(1) = x;
button_pressed=true;

 % use bar coordinates with final x value from mouse movement
    xy = [(lb + 100 ) (H/2 ); (lb + 100 ) (H/2+scale_W - 50)  ; (x ) (H/2+scale_W - 50) ; (x ) (H/2 )];
    % make bar RED
    Screen('FillPoly', theWindow, red, xy, 1);
           % break
        end

end        

if GetSecs-time_start>5
break
end
    end
    
    % freeze the screen 1 second with red line
    % set up scale
        xy = [(lb + 100 ) (H/2 ); (lb + 100 ) (H/2+scale_W - 50)  ; (x ) (H/2+scale_W - 50) ; (x ) (H/2 )];;
        Screen(theWindow, 'FillPoly', 255, xy);
%         Screen(theWindow,'DrawText','Not',lb-50,anchor_y,255);
%         Screen(theWindow,'DrawText','at all',lb-50,anchor_y2,255);
%         Screen(theWindow,'DrawText','Strongest',rb-50,anchor_y,255);
%         Screen(theWindow,'DrawText','imaginable',rb-50,anchor_y2,255);

    % use bar coordinates with final x value from mouse movement
    xy = [(lb + 100 ) (H/2 ); (lb + 100 ) (H/2+scale_W - 50)  ; (x ) (H/2+scale_W - 50) ; (x ) (H/2 )];;
    % make bar RED
    Screen('FillPoly', theWindow, red, xy, 1);
    
    % record x as the rating for this trial
    ratings(1) = x;
    
    % draw bar and wait 1 second
    Screen('Flip', theWindow);
    WaitSecs(0.5);

    
    
end

catch em
    display(em.message);
    Screen('CloseAll');
end


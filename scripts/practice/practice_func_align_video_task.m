function practice_func_align_video_view_rate_task = practice_func_align_video_view_rate_task(subjID)
% *************************************************************************
%   Program Name: self_other_task.m 
%   Original Programmer: Luke Slipski @lslipski602@gmail.com
%   Created: August 11, 2019
%   Project: Spacetop
%   This program was designed to play videos associated with the Spatial
%   Topology grant and to collect 7 affective ratings at the end of each
%   video. The program takes in a subject's ID and a scan ID (1-4) and
%   shows a random order of a set of videos (1 set per scan).
%   
%  Input: 
%   1.) subjID -- An integer value 1-150
% *************************************************************************

% Clear the workspace and the screen
sca;
AssertOpenGL;

% for practice task only, bypasses graphics sync tests which weren't working on
% windows dev PC. Should be set to 0 on stim PC. 0 also works fine on linux
% systems
Screen('Preference', 'SkipSyncTests', 1);

% format SubjID for folder name and file names
subjID = sprintf('%04d', subjID);
sub_folder = strcat('sub-',subjID);

%----------------------------------------------------------------------
%                       Initialize Paths
%----------------------------------------------------------------------

% set base path. All other paths will reference subfolders within this path
global base_path;
base_path = 'C:\Users\Dartmouth College\Desktop\Spacetop\func_align_video_task-master\func_align_video_task-master';

% create data folder if it doesn't exist and a folder for the current
% participant
if ~exist([fullfile(base_path, 'data',subjID)],'dir')
    mkdir([fullfile(base_path, 'data',subjID)]);
end


% path for general paradigm folder
addpath(genpath(base_path));

% path for the video clips and randomized video orders in this experiment
video_path = fullfile(base_path, 'videos');

% determine which folder to look in for randomized videos and orders
video_folder = 'practice_videos';


% path for helper scripts used in this experiment
code_path =fullfile(base_path, 'code');

% path for any cue images and image names
cue_path = fullfile(base_path, 'cues');
practice_1 = 'practice_prompt_1.png';
practice_2 = 'practice_prompt_2.png';

% path for saving experiment log
sub_save_dir = fullfile(base_path, 'data/',subjID);

%----------------------------------------------------------------------
%                       Window Parameters
%----------------------------------------------------------------------

global p
% Here we call some default settings  for setting up Psychtoolbox
PsychDefaultSetup(2);

% assign external screen number for the Screen we want to show participants
p.ptb.screenNumber = max(Screen('Screens'));

% Define black and white
p.ptb.white = WhiteIndex(p.ptb.screenNumber);
p.ptb.black = BlackIndex(p.ptb.screenNumber);

% Open an on screen window
[p.ptb.window, p.ptb.rect] = PsychImaging('OpenWindow', p.ptb.screenNumber, p.ptb.black);

% Get the size of the on screen window
[p.ptb.screenXpixels, p.ptb.screenYpixels] = Screen('WindowSize', p.ptb.window);

% remove cursor from screen
HideCursor;

% Query the frame duration
p.ptb.ifi = Screen('GetFlipInterval', p.ptb.window);

% Set up alpha-blending for smooth (anti-aliased) lines
Screen('BlendFunction', p.ptb.window, 'GL_SRC_ALPHA', 'GL_ONE_MINUS_SRC_ALPHA');

% Setup the text type for the window
%Screen('TextFont', p.ptb.window, 'Arial');
Screen('TextFont', p.ptb.window, '-arabic-newspaper-medium-r-normal'); % for development on linux machine, where Arial isn't installed. Remove in production
Screen('TextSize', p.ptb.window, 20);

% Get the centre coordinate of the window
[p.ptb.xCenter, p.ptb.yCenter] = RectCenter(p.ptb.rect);


% Here we set the size of the arms of our fixation cross
p.fix.sizePix = 40;

% Now we set the coordinates (these are all relative to zero we will let
% the drawing routine center the cross in the center of our monitor for us)
p.fix.xCoords = [-p.fix.sizePix p.fix.sizePix 0 0];
p.fix.yCoords = [0 0 -p.fix.sizePix p.fix.sizePix];
p.fix.allCoords = [p.fix.xCoords; p.fix.yCoords];

% Set the line width for our fixation cross
p.fix.lineWidthPix = 4;

%----------------------------------------------------------------------
%                       Keyboard information
%----------------------------------------------------------------------

% Define the keyboard keys that are listened for. We will be using the escape key as
% an exit key and the space key as a skip-video key

KbName('UnifyKeyNames');
p.keys.space = KbName('space');
p.keys.esc = KbName('ESCAPE');

%----------------------------------------------------------------------
%                       Video Playback Setup
%----------------------------------------------------------------------
% looks for all videos in the current folder. Will cycle through
% alphabetically
moviename = '*.mp4';

% empty options for video Screen
shader = [];
pixelFormat = [];
maxThreads = [];

iteration = 0;
escape = 0;

% Use blocking wait for new frames by default:
blocking = 1;

% Default preload setting:
preloadsecs = [];

% Return full list of movie files from directory+pattern:
moviefiles=dir(fullfile(video_path,video_folder, moviename));
if isempty(moviefiles)
    fprintf('ERROR: No videos in directory\n')
else
    for i=1:size(moviefiles,1)
        moviefiles(i).name = [ video_path filesep video_folder filesep moviefiles(i).name ];
    end
end
moviecount = size(moviefiles,1);
PsychHomeDir('.cache');    

% Playbackrate defaults to 1:
rate=1;

% Choose 16 pixel text size:
Screen('TextSize', p.ptb.window, 16);


%----------------------------------------------------------------------
%                       Set Up Timing Variables for Saving
%----------------------------------------------------------------------
explog.date = date;
explog.subjID = subjID;
explog.movie_start = zeros(moviecount,1);
explog.movie_end = zeros(moviecount,1);
explog.rating_start = zeros(moviecount,1);
explog.rating_decide_onset = zeros(moviecount,1);
explog.decision_rt = zeros(moviecount,1);

%-------------------------------------------------------------------------------
%                            0. Experimental loop
%-------------------------------------------------------------------------------
try 
    % bring up screen and wait for participant to read direactions and
    % click to continue
    practice_pause(p.ptb.window, fullfile(cue_path, practice_1));

    for trl = 1:size(moviefiles,1)
        %allows esc to exit psych toolbox
        if escape==2
            break
        end
        
        % Counts through movies
        current_movie = moviefiles(trl).name;
        
        %-------------------------------------------------------------------------------
        %                                  2. Video (5s)
        %-------------------------------------------------------------------------------

        % Open movie file and retrieve basic info about movie:
        [movie movieduration fps imgw imgh] = Screen('OpenMovie', p.ptb.window, current_movie, [], preloadsecs, [], pixelFormat, maxThreads);
        totalframes=floor(fps*movieduration);
        fprintf('Movie: %s  : %f seconds duration, %f fps, w x h = %i x %i...\n', current_movie, movieduration, fps, imgw, imgh);

        i=0;

        % Start playback of movie. This will start
        % the realtime playback clock and playback of audio tracks, if any.
        % Play 'movie', at a playbackrate = 1, with endless loop=1 and
        % 1.0 == 100% audio volume.
        Screen('PlayMovie', movie, rate, 1, 1.0);
        explog.movie_start(trl) = GetSecs;

        % Plays movies while frame count is less than total frames
        while i<totalframes-1

            escape=0;
            [keyIsDown,secs,keyCode]=KbCheck; 
            if (keyIsDown==1 && keyCode(esc))
                % Set the abort-demo flag.
                escape=2;
                break;
            end

            % Spacebar to skip to next movie. CAN BE COMMENTED OUT
            if (keyIsDown==1 && keyCode(space))
                break;
            end

            % Only perform video image fetch/drawing if playback is active
            % and the movie actually has a video track (imgw and imgh > 0):
            if ((abs(rate)>0) && (imgw>0) && (imgh>0))
                % Return next frame in movie, in sync with current playback
                % time and sound.
                % tex is either the positive texture handle or zero if no
                % new frame is ready yet in non-blocking mode (blocking == 0).
                % It is -1 if something went wrong and playback needs to be stopped:
                tex = Screen('GetMovieImage', p.ptb.window, movie, blocking);

                % Valid texture returned?
                if tex < 0
                    % No, and there won't be any in the future, due to some
                    % error. Abort playback loop:
                    break;
                end

                if tex == 0
                    % No new frame in polling wait (blocking == 0). Just sleep
                    % a bit and then retry.
                    WaitSecs('YieldSecs', 0.005);
                    continue;
                end

                % Draw the new texture immediately to screen:
                Screen('DrawTexture', p.ptb.window, tex, [], [], [], [], [], [], shader);

                % Update display:
                Screen('Flip', p.ptb.window);

                % Release texture:
                Screen('Close', tex);

                % Framecounter:
                i=i+1;

            end % end if statement for grabbing next frame
        end % end while statement for playing until no more frames exist

        %get movie playback end time
        explog.movie_end(trl) = GetSecs;

        Screen('Flip', p.ptb.window);
        KbReleaseWait;

        % Done. Stop playback:
        Screen('PlayMovie', movie, 0);

        % Close movie object:
        Screen('CloseMovie', movie);

        % if escape is pressed during video, exit
        if escape==2
            break
        end
    
        %-------------------------------------------------------------------------------
        %                             3. Judgement rating (5s)
        %-------------------------------------------------------------------------------
        [ratings, times, RT] = rating_scale(p);
        explog.rating.ratings = ratings;
        explog.rating.times = times;
        explog.rating.RT = RT;
        %explog.rating_start(trl) = rating_onset;
        %explog.rating_decide_onset(trl) = buttonPressOnset;
        %explog.rating_trajectory{trl,1} = trajectory;
        %explog.decision_rt(trl) = RT;
        
    end
    
    % bring up screen and wait for participant to read direactions and
    % click to continue
    practice_pause(p.ptb.window, fullfile(cue_path, practice_2));
    
catch e
    display(e.message);
    Screen('CloseAll');
end

    %-------------------------------------------------------------------------------
    %                                   save parameter
    %-------------------------------------------------------------------------------
    save_file_name = fullfile(sub_save_dir,strcat('explog','sub_', subjID,'.mat'));
    save(save_file_name, 'explog');
Screen('CloseAll')







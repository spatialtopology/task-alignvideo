function alignvideos(sub_num, ses_num, run_num, biopac, debug)

HideCursor;
ses_str =  strcat('ses-',  sprintf('%02d', ses_num));
keySet = {'ses-01','ses-02','ses-03','ses-04'};
valueSet = [4 4 3 2];
M = containers.Map(keySet,valueSet);

for r = run_num:M(ses_str)

% code by Heejung Jung and Luke Slipski
% heejung.jung@colorado.edu
% 11.27.2020


%% -----------------------------------------------------------------------------
%                                Parameters
% ------------------------------------------------------------------------------
%% 0. Biopac parameters ________________________________________________________
% biopac channel
channel = struct;

channel.trigger     = 0;
channel.movie       = 1;
channel.rating      = 2;

if biopac == 1
    script_dir = pwd;
    cd('/home/spacetop/repos/labjackpython');
    pe = pyenv;
    try
        py.importlib.import_module('u3');
    catch
        warning("u3 already imported!");
    end

    % py.importlib.import_module('u3');
    % Check to see if u3 was imported correctly
    % py.help('u3')
    channel.d = py.u3.U3();
    % set every channel to 0
    channel.d.configIO(pyargs('FIOAnalog', int64(0), 'EIOAnalog', int64(0)));
    for FIONUM = 0:7
        channel.d.setFIOState(pyargs('fioNum', int64(FIONUM), 'state', int64(0)));
    end
    cd(script_dir);
end



%% A. Psychtoolsbox parameters _________________________________________________
global p
Screen('Preference', 'SkipSyncTests', 0);
PsychDefaultSetup(2);

if debug
    ListenChar(0);
    PsychDebugWindowConfiguration;
end
screens                         = Screen('Screens'); % Get the screen numbers
p.ptb.screenNumber              = max(screens); % Draw to the external screen if avaliable
p.ptb.white                     = WhiteIndex(p.ptb.screenNumber); % Define black and white
p.ptb.black                     = BlackIndex(p.ptb.screenNumber);
[p.ptb.window, p.ptb.rect]      = PsychImaging('OpenWindow', p.ptb.screenNumber, p.ptb.black);
[p.ptb.screenXpixels, p.ptb.screenYpixels] = Screen('WindowSize', p.ptb.window);
p.ptb.ifi                       = Screen('GetFlipInterval', p.ptb.window);
Screen('BlendFunction', p.ptb.window, 'GL_SRC_ALPHA', 'GL_ONE_MINUS_SRC_ALPHA'); % Set up alpha-blending for smooth (anti-aliased) lines
Screen('TextFont', p.ptb.window, 'Arial');
Screen('TextSize', p.ptb.window, 36);
[p.ptb.xCenter, p.ptb.yCenter]  = RectCenter(p.ptb.rect);
p.fix.sizePix                   = 40; % size of the arms of our fixation cross
p.fix.lineWidthPix              = 4; % Set the line width for our fixation cross
p.fix.xCoords                   = [-p.fix.sizePix p.fix.sizePix 0 0];
p.fix.yCoords                   = [0 0 -p.fix.sizePix p.fix.sizePix];
p.fix.allCoords                 = [p.fix.xCoords; p.fix.yCoords];
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
% Playbackrate defaults to 1:
rate=1;






%% B. Directories ______________________________________________________________
script_dir                      = pwd; % /home/spacetop/repos/alignvideos/scripts
main_dir                        = fileparts(script_dir); % /home/spacetop/repos/alignvideos
repo_dir                        = fileparts(fileparts(script_dir)); %/home/spacetop
taskname                        = 'alignvideos';

bids_string                     = [strcat('sub-', sprintf('%04d', sub_num)), ...
    strcat('_ses-',sprintf('%02d', ses_num)),...
    strcat('_task-', taskname),...
    strcat('_run-',  sprintf('%02d', r))];
sub_save_dir = fullfile(main_dir, 'data', strcat('sub-', sprintf('%04d', sub_num)),...
    strcat('ses-',sprintf('%02d', ses_num)),...
    'beh'  );
repo_save_dir = fullfile(repo_dir, 'data', strcat('sub-', sprintf('%04d', sub_num)),...
    strcat('task-', taskname), strcat('ses-',sprintf('%02d', ses_num)));
if ~exist(sub_save_dir, 'dir');    mkdir(sub_save_dir);     end
if ~exist(repo_save_dir, 'dir');    mkdir(repo_save_dir);   end

design_filename                 = fullfile(main_dir, 'design', 'spacetop_alignvideos_design.csv');
design_file                     = readtable(design_filename);
idx                             = design_file.session ==ses_num & design_file.run ==r;
param_T                         = design_file(idx, :); % extract parameters for each session and run
videos_per_run                  = size(param_T,1);

%% C. Circular rating scale _____________________________________________________
%image_filepath                  = fullfile(main_dir, 'stimuli', 'ratingscale');
%image_scale_filename            = ['task-', taskname, '_scale.png'];
%image_scale                     = fullfile(image_filepath, image_scale_filename);

%% D. making output table ________________________________________________________
vnames = {'src_subject_id', 'session_id', 'param_run_num', 'param_trigger_onset', 'param_start_biopac',...
    'param_video_filename', 'event01_video_onset', 'event01_video_biopac', 'event01_video_end',...
    'event02_rating01_displayonset', 'event02_rating01_displaystop', 'event02_rating01_rating', 'event02_rating01_RT', 'event02_rating01_biopac_displayonset', 'event02_rating01_biopac_response',...
    'event02_rating02_displayonset', 'event02_rating02_displaystop', 'event02_rating02_rating', 'event02_rating02_RT', 'event02_rating02_biopac_displayonset', 'event02_rating02_biopac_response',...
    'event02_rating03_displayonset', 'event02_rating03_displaystop', 'event02_rating03_rating', 'event02_rating03_RT', 'event02_rating03_biopac_displayonset', 'event02_rating03_biopac_response',...
    'event02_rating04_displayonset', 'event02_rating04_displaystop', 'event02_rating04_rating', 'event02_rating04_RT', 'event02_rating04_biopac_displayonset', 'event02_rating04_biopac_response',...
    'event02_rating05_displayonset', 'event02_rating05_displaystop', 'event02_rating05_rating', 'event02_rating05_RT', 'event02_rating05_biopac_displayonset', 'event02_rating05_biopac_response',...
    'event02_rating06_displayonset', 'event02_rating06_displaystop', 'event02_rating06_rating', 'event02_rating06_RT', 'event02_rating06_biopac_displayonset', 'event02_rating06_biopac_response',...
    'event02_rating07_displayonset', 'event02_rating07_displaystop', 'event02_rating07_rating', 'event02_rating07_RT', 'event02_rating07_biopac_displayonset', 'event02_rating07_biopac_response',...
    'param_end_instruct_onset', 'param_end_biopac', 'param_experiment_duration'};


T = array2table(zeros(videos_per_run, size(vnames, 2)));
T.Properties.VariableNames     = vnames;
T.src_subject_id(:)            = sub_num;
T.session_id(:)                = ses_num;
T.param_run_num(:)             = r;
T.param_video_filename         = param_T.video_name;


%% E. Keyboard information _____________________________________________________
KbName('UnifyKeyNames');
p.keys.confirm                 = KbName('return');
p.keys.right                   = KbName('3#');
p.keys.left                    = KbName('1!');
p.keys.space                   = KbName('space');
p.keys.esc                     = KbName('ESCAPE');
p.keys.trigger                 = KbName('5%');
p.keys.start                   = KbName('s');
p.keys.end                     = KbName('e');

[id, name]                     = GetKeyboardIndices;
trigger_index                  = find(contains(name, 'Current Designs'));
trigger_inputDevice            = id(trigger_index);

keyboard_index                 = find(contains(name, 'AT Translated Set 2 Keyboard'));
keyboard_inputDevice           = id(keyboard_index);

%% F. fmri Parameters __________________________________________________________
TR                             = 0.46;
task_duration                  = 6.50;

%% G. instructions _____________________________________________________
instruct_filepath              = fullfile(main_dir, 'stimuli', 'instructions'); 
instruct_start                 = fullfile(instruct_filepath, 'start.png');
instruct_end                   = fullfile(instruct_filepath, 'end.png');

%% H. Make Images Into Textures ________________________________________________
DrawFormattedText(p.ptb.window,sprintf('LOADING\n\n0%% complete'),'center','center',p.ptb.white );
HideCursor;
Screen('Flip',p.ptb.window);
for v = 1:length(T.param_video_filename)
    start_tex = Screen('MakeTexture',p.ptb.window, imread(instruct_start));
    end_tex  = Screen('MakeTexture',p.ptb.window, imread(instruct_end));
    preloadsecs =[];
    video_file      = fullfile(main_dir, 'stimuli', 'videos',strcat('ses-',sprintf('%02d', ses_num)),...
        strcat('run-',sprintf('%02d', r)), T.param_video_filename{v});
    [movie{v}, dur{v}, fps{v}, imgw{v}, imgh{v}] = Screen('OpenMovie', p.ptb.window, video_file, [], preloadsecs, [], pixelFormat, maxThreads);


    cue_image = dir(fullfile(main_dir, 'stimuli', 'cues', '*.png'));
    cue_tex = cell(length(cue_image),1);
    for c = 1:length(cue_image)
%         cue_image = fullfile(main_dir, 'stimuli', 'cues', '*.png');
        cue_filename = fullfile(cue_image(c).folder, cue_image(c).name);
        cue_tex{c} = Screen('MakeTexture', p.ptb.window, imread(cue_filename));
    end

    % instruction, actual texture
    %actual_tex = Screen('MakeTexture', p.ptb.window, imread(image_scale)); % pure rating scale
    %start_tex = Screen('MakeTexture',p.ptb.window, imread(instruct_start));
    %end_tex  = Screen('MakeTexture',p.ptb.window, imread(instruct_end));
    DrawFormattedText(p.ptb.window,sprintf('LOADING\n\n%d%% complete', ceil(100*v/length(T.param_video_filename))),'center','center',p.ptb.white);
    Screen('Flip',p.ptb.window);
end


%% -----------------------------------------------------------------------------
%                              Start Experiment
% ______________________________________________________________________________

%% ______________________________ Instructions _________________________________
% Screen('TextSize',p.ptb.window,36);
% DrawFormattedText(p.ptb.window,'.','center',p.ptb.screenYpixels/2,255);
% Screen('Flip',p.ptb.window);
% HideCursor;


%% ______________________________ Instructions _________________________________

Screen('TextSize',p.ptb.window,72);
Screen('DrawTexture',p.ptb.window,start_tex,[],[]);
Screen('Flip',p.ptb.window);
%% _______________________ Wait for Trigger to Begin ___________________________
% 1) wait for 's' key, once pressed, automatically flips to fixation
% 2) wait for trigger '5'
DisableKeysForKbCheck([]);
WaitKeyPress(p.keys.start); % press s
Screen('DrawLines', p.ptb.window, p.fix.allCoords,...
    p.fix.lineWidthPix, p.ptb.white, [p.ptb.xCenter p.ptb.yCenter], 2);
Screen('Flip', p.ptb.window);
WaitKeyPress(p.keys.trigger);
% T.param_trigger_onset(:)                = KbTriggerWait(p.keys.trigger, trigger_inputDevice);
T.param_trigger_onset(:)                  = GetSecs;
T.param_start_biopac(:)                   = biopac_video(biopac, channel, channel.trigger, 1);

WaitSecs(TR*6);

%% 0. Experimental loop _________________________________________________________

for trl = 1:size(T.param_video_filename,1)

    %% event 01. load videos _______________________________________________________
    totalframes = floor(fps{trl} * dur{trl});
    fprintf('Movie: %s  : %f seconds duration, %f fps, w x h = %i x %i...\n', T.param_video_filename{trl}, dur{trl}, fps{trl}, imgw{trl}, imgh{trl});
    disp('line 381')
    i=0;
    Screen('PlayMovie', movie{trl}, rate, 1, 1.0);
    % explog.movie_start(trl) = GetSecs;
    T.event01_video_onset(trl)         = GetSecs;
    T.event01_video_biopac(trl)        = biopac_video(biopac, channel, channel.movie, 1);

    while i<totalframes-1

        escape=0;
        [keyIsDown,secs,keyCode]=KbCheck;
        if (keyIsDown==1 && keyCode(p.keys.esc))
            % Set the abort-demo flag.
            escape=2;
            % break;
        end


        % Only perform video image fetch/drawing if playback is active
        % and the movie actually has a video track (imgw and imgh > 0):

        if ((abs(rate)>0) && (imgw{trl}>0) && (imgh{trl}>0))
            % Return next frame in movie, in sync with current playback
            % time and sound.
            % tex is either the positive texture handle or zero if no
            % new frame is ready yet in non-blocking mode (blocking == 0).
            % It is -1 if something went wrong and playback needs to be stopped:
            tex = Screen('GetMovieImage', p.ptb.window, movie{trl}, blocking);

            % Valid texture returned?
            if tex < 0
                % No, and there wont be any in the future, due to some
                % error. Abort playback loop:
                %  break;
            end

            if tex == 0
                % No new frame in polling wait (blocking == 0). Just sleep
                % a bit and then retry.
                WaitSecs('YieldSecs', 0.005);
                continue;
            end

            Screen('DrawTexture', p.ptb.window, tex, [], [], [], [], [], [], shader); % Draw the new texture immediately to screen:
            Screen('Flip', p.ptb.window); % Update display:
            Screen('Close', tex);% Release texture:
            i=i+1; % Framecounter:

        end % end if statement for grabbing next frame
    end % end while statement for playing until no more frames exist

    T.event01_video_end(trl) = GetSecs;
    T.event01_biopac_stop(trl) = biopac_video(biopac,channel, channel.movie, 0);

    Screen('Flip', p.ptb.window);
    KbReleaseWait;

    Screen('PlayMovie', movie{trl}, 0); % Done. Stop playback:
    Screen('CloseMovie', movie{trl});  % Close movie object:

    % Release texture:
    %         Screen('Close', tex);

    % if escape is pressed during video, exit
    if escape==2
        %break
    end

    %% event 02. judgment ratings _______________________________________________________

    T.event02_movie_biopac(trl)        = biopac_video(biopac, channel, channel.rating, 1);
    [ratings, times, RT] = rating_scale(p, cue_tex, biopac, channel);
    biopac_video(biopac, channel, channel.rating, 0);
    explog.rating.ratings{trl} = ratings;
    explog.rating.times{trl} = times;
    explog.rating.RT{trl} = RT;
end

%% save parameters
Screen('DrawTexture',p.ptb.window,end_tex,[],[]);
% Screen('Flip',p.ptb.window);
% DrawFormattedText(p.ptb.window,'This is the end of this run\nPlease wait for experimenter\n\nExperimenters - press e','center',p.ptb.screenYpixels/2,255);

T.param_end_instruct_onset(:)             = Screen('Flip', p.ptb.window);
WaitKeyPress(p.keys.end);
T.param_end_biopac(:)                     = biopac_video(biopac, channel, channel.trigger, 0);
T.param_experiment_duration(:) = T.param_end_instruct_onset(1) - T.param_trigger_onset(1);

for v = 1:videos_per_run
    T.event02_rating01_onset(v) = explog.rating.times{v}(1);
    T.event02_rating02_onset(v) = explog.rating.times{v}(2);
    T.event02_rating03_onset(v) = explog.rating.times{v}(3);
    T.event02_rating04_onset(v) = explog.rating.times{v}(4);
    T.event02_rating05_onset(v) = explog.rating.times{v}(5);
    T.event02_rating06_onset(v) = explog.rating.times{v}(6);
    T.event02_rating07_onset(v) = explog.rating.times{v}(7);

    T.event02_rating01_rating(v) = explog.rating.ratings{v}(1);
    T.event02_rating02_rating(v) = explog.rating.ratings{v}(2);
    T.event02_rating03_rating(v) = explog.rating.ratings{v}(3);
    T.event02_rating04_rating(v) = explog.rating.ratings{v}(4);
    T.event02_rating05_rating(v) = explog.rating.ratings{v}(5);
    T.event02_rating06_rating(v) = explog.rating.ratings{v}(6);
    T.event02_rating07_rating(v) = explog.rating.ratings{v}(7);

    T.event02_rating01_RT(v)    = explog.rating.RT{v}(1);
    T.event02_rating02_RT(v)    = explog.rating.RT{v}(2);
    T.event02_rating03_RT(v)    = explog.rating.RT{v}(3);
    T.event02_rating04_RT(v)    = explog.rating.RT{v}(4);
    T.event02_rating05_RT(v)    = explog.rating.RT{v}(5);
    T.event02_rating06_RT(v)    = explog.rating.RT{v}(6);
    T.event02_rating07_RT(v)    = explog.rating.RT{v}(7);


    %% ________________________ 7. temporarily save file _______________________
    tmpFileName = fullfile(sub_save_dir,[strcat(bids_string,'_TEMP_beh.csv') ]);
    writetable(T,tmpFileName);

end

%% _________________________ 8. save parameter _________________________________
% onset + response file
saveFileName = fullfile(sub_save_dir,[bids_string,'_beh.csv' ]);
repoFileName = fullfile(repo_save_dir,[bids_string,'_beh.csv' ]);
writetable(T,saveFileName);
writetable(T,repoFileName);


% ptb parameters
psychtoolbox_saveFileName = fullfile(sub_save_dir, [bids_string,'_psychtoolboxparams.mat' ]);
psychtoolbox_repoFileName = fullfile(repo_save_dir, [bids_string,'_psychtoolboxparams.mat' ]);
save(psychtoolbox_saveFileName, 'p');
save(psychtoolbox_repoFileName, 'p');

clear p;
if biopac
channel.d.close();
end
Screen('Close'); close all; sca;



end
close all;
    function WaitKeyPress(kID)
        while KbCheck(-3); end  % Wait until all keys are released.

        while 1
            % Check the state of the keyboard.
            [ keyIsDown, ~, keyCode ] = KbCheck(-3);
            % If the user is pressing a key, then display its code number and name.
            if keyIsDown

                if keyCode(p.keys.esc)
                    cleanup; break;
                elseif keyCode(kID)
                    break;
                end
                % make sure key is released
                while KbCheck(-3); end
            end
        end
    end

end

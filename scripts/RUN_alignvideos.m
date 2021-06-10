clear all;
Screen('Close');
clearvars;
sca;

% 1. grab participant number ___________________________________________________


sub_prompt = 'PARTICIPANT (in raw number form, e.g. 1, 2,...,98): ';
sub_num = input(sub_prompt);
ses_prompt = 'SESSION (1, 2, 3, OR 4): ';
ses_num = input(ses_prompt);
run_prompt = 'RUN (1, 2, 3, or 4): ';
run_num = input(run_prompt);
b_prompt = 'BIOPAC YES=1 NO=0 : ';
biopac = input(b_prompt);

debug = 0; %DEBUG_MODE = 1, Actual_experiment = 0

if ses_num == 1 && run_num > 4
    error('There are only 4 runs in session 1. Enter a valid run number.')
elseif ses_num == 2 && run_num > 4
    error('There are only 4 runs in session 2. Enter a valid run number.')
elseif ses_num == 3 && run_num > 3
    error('There are only 3 runs in session 3. Enter a valid run number.')
elseif ses_num == 4 && run_num > 2
    error('There are only 2 runs in session 4. Enter a valid run number.')
end



% DOUBLE CHECK MSG ______________________________________________________________
%% A. Directories ______________________________________________________________
task_dir                        = pwd;
repo_dir                        = fileparts(fileparts(task_dir));
repo_save_dir = fullfile(repo_dir, 'data', strcat('sub-', sprintf('%04d', sub_num)),...
    'task-alignvideos', strcat('ses-',sprintf('%02d', ses_num)));
bids_string                     = [strcat('sub-', sprintf('%04d', sub_num)), ...
    strcat('_ses-',sprintf('%02d', ses_num)),...
    strcat('_task-*'),...
    strcat('_run-', sprintf('%02d', run_num))];
repoFileName = fullfile(repo_save_dir,[bids_string,'_beh.csv' ]);

%% B. if so, "this run exists. Are you sure?" ___________________________________
if isempty(dir(repoFileName)) == 0
    RA_response = input(['\n\n---------------ATTENTION-----------\nThis file already exists in: ', repo_save_dir, '\nDo you want to overwrite?: (YES = 999; NO = 0): ']);
    if RA_response ~= 999 || isempty(RA_response) == 1
        error('Aborting!');
    end
end
%______________________________________________________________



alignvideos(sub_num, ses_num, run_num, biopac, debug)

run_str =  strcat('ses-',  sprintf('%02d', run_num));
keySet = {'ses-01','ses-02','ses-03','ses-04'};
valueSet = [4 4 3 2];
M = containers.Map(keySet,valueSet);

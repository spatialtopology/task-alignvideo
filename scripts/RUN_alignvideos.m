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

debug = 1; %DEBUG_MODE = 1, Actual_experiment = 0

if ses_num == 1 && run_num > 4
    error('There are only 4 runs in session 1. Enter a valid run number.')
elseif ses_num == 2 && run_num > 4
    error('There are only 4 runs in session 2. Enter a valid run number.')
elseif ses_num == 3 && run_num > 3
    error('There are only 3 runs in session 3. Enter a valid run number.')
elseif ses_num == 4 && run_num > 2
    error('There are only 2 runs in session 4. Enter a valid run number.')
end


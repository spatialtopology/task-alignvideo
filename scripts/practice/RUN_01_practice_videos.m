% Prompt User for the Participant's ID number
prompt = 'Subject Number (in raw number form, e.g. 1, 2,..., 98): ';
sub = input(prompt);

% Run the practice script for this participant
practice_func_align_video_task(sub);
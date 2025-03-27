function [when] = practice_pause(win, cue_img)

cue_texture = Screen('MakeTexture',win, imread(cue_img));
Screen('DrawTexture',win,cue_texture,[]);
Screen('Flip', win);

pressed = 0;
while ~pressed   % keeps checking
    [x,~,button] = GetMouse(win); % When ‘deviceNumber’ is -1, KbCheck will query all keyboard devices and return their “merged state”
    if button(1) == 1
        pressed = 1;
    end
end

end
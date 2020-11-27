function [time] = biopac_video(biopac, channel, channel_num, state_num)
if biopac
    channel.d.setFIOState(pyargs('fioNum', int64(channel_num), 'state', int64(state_num)))
    time = GetSecs;
else
    time = GetSecs;
    return
end
end

function al_indicateCondition(taskParam, txt)
%AL_INDICATECONDITION This function presents the welcome message at the beginning of the task
%
%   Input
%       taskParam: Task-parameter-object instance
%       txt: Presented text
%
%   Output
%       None

% Set text size and font
Screen('TextSize', taskParam.display.window.onScreen, 30);
Screen('TextFont', taskParam.display.window.onScreen, 'Arial');

while 1

    % Present text and background
    Screen('FillRect', taskParam.display.window.onScreen, []);
    DrawFormattedText(taskParam.display.window.onScreen, txt, 'center', 100, [0 0 0]);
    Screen('DrawingFinished', taskParam.display.window.onScreen);
    t = GetSecs;
    Screen('Flip', taskParam.display.window.onScreen, t + 0.1);

    % Wait for button press
    [~, ~, keyCode] = KbCheck(taskParam.keys.kbDev);
    if find(keyCode) == taskParam.keys.enter
        break
    elseif taskParam.unitTest.run
        WaitSecs(1);
        break
    elseif keyCode(taskParam.keys.esc)
        % for Tobii, we save the entirety of the trial
        if taskParam.gParam.eyeTrackerTobii
            al_eyeTrackerTobii.saveTobiiData(taskParam);
        end
        ListenChar();
        ShowCursor;
        Screen('CloseAll');
        error('User pressed Escape to finish task')
    end
end

WaitSecs(0.1);

end
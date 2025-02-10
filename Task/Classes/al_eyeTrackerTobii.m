classdef al_eyeTrackerTobii
    %AL_EYETRACKERTOBII This class-definition file provides functions
    %that initialise the eyetracking in Tobii Pro Lab and save data in
    %addition to the taskDataMain class.
    %
    %  

    % Methods of the eye-tracker object
    % --------------------------------- 
    % All static for now, can adapt later

    
    
    methods(Static)

        function taskParam = startTobii(taskParam)
            % startTitta starts the Titta handler and uses it
            % to start talkToProLab function. Then it starts
            % calibration
            %
            %   Input
            %       taskParam: Task-parameter-object instance
            %
            %   Output
            %       taskParam: Task-parameter-object instance
            

            % 1. Start Titta and get the settings, these are added from a local location
            try
                addTittaToPath;
            catch
                warning('Titta is not in the folder.');
            end
            
            eyeTrackerSettings = Titta.getDefaults('Tobii Pro Spectrum'); % Use the model from the selected tracker
            
            % request some debug output to command window, can skip for normal use
            eyeTrackerSettings.debugMode    = true; % false
            
            % setup screen
            fixClrs     = [0 255];
            bgClr       = 125;
            
            eyeTrackerSettings.UI.setup.bgColor       = bgClr;
            eyeTrackerSettings.UI.setup.instruct.color= fixClrs(1);
            eyeTrackerSettings.UI.setup.fixBackColor  = fixClrs(1);
            eyeTrackerSettings.UI.setup.fixFrontColor = fixClrs(2);

            
            % 2. Initialisation with project settings through taskParam
            taskParam.EThndl    = Titta(eyeTrackerSettings);
            temp_local_address = taskParam.gParam.localAddress;
            taskParam.EThndl.init(temp_local_address);
            
            % 3. Initialisation of Tobii Pro Lab 
            % project name is passed on from taskParam
            temp_Project = taskParam.gParam.eyeTrackerTobiiTest;
            temp_Tobii_Address = taskParam.gParam.TobiiAddress;
            taskParam.talkToProLab = TalkToProLab(temp_Project, temp_Tobii_Address);


            % 4. Start Recording, first Titta, then Tobii Pro Lab
            al_eyeTrackerTobii.startTittaRecording(taskParam);

            % Creating file name with the # of starting block
            tempID = sprintf('commonConfetti_%s%s_%d',taskParam.subject.ID, '_et',taskParam.subject.startsWithBlock);
            taskParam.talkToProLab.createParticipant(tempID, false); % false = does not allow dublicates
            
            % Screen height and width
            taskParam.talkToProLab.startRecording(tempID, taskParam.display.screensizePart(1), taskParam.display.screensizePart(2));
            
            
            % 5. Record reference time stamp, there is a 2ms delay for Tobii Pro Lab
            taskParam.timingParam.refTittaSys = GetSecs();
            taskParam.timingParam.refTitta = taskParam.EThndl.buffer.systemTimestamp();
            taskParam.talkToProLab.sendCustomEvent([], sprintf('Block %d Block Start Reference', taskParam.subject.startsWithBlock)); % by defalut, current time is taken. This appears in Tobii Pro Lab output

        end

        function taskParam = startTobiiCalibration(taskParam)
            % startTobiiCalibration starts the calibration process
            % 
            %
            %   Input
            %       taskParam: Task-parameter-object instance
            
            % 1. Parameters for calibration
            
            DEBUGlevel = 0;
            bgClr = 125;
            useWindowedOperatorScreen = false; 
        
            % Screen setup for Linux
            % If testing alone, set coordinate screen and participant
            % screen to one, only works with two 1920x1080 screens
            % Change for resolution settings
            temp_Project = taskParam.gParam.eyeTrackerTobiiTest;
            
            if strcmp(temp_Project, 'test_alone_confetti')
                scrCoordinatesOperator = [0 0 1920 1080];
            else
                scrCoordinatesOperator = [1920 0 3840 1080];
            end
           
            scrParticipant          = 0;
            scrCoordinatesParticipant = [0 0 1920 1080];
            scrOperator             = 0;

            % 2. Calibration process
            try
                
                % get setup struct (can edit that of course):
            
                if DEBUGlevel>1
                    % make screen partially transparent on OSX and windows vista or
                    % higher, so we can debug.
                    PsychDebugWindowConfiguration;
                end
            
                if DEBUGlevel
                    % Be pretty verbose about information and hints to optimize your code and system.
                    Screen('Preference', 'Verbosity', 4);
                else
                    % Only output critical errors and warnings.
                    Screen('Preference', 'Verbosity', 2);
                end
            
            
                Screen('Preference', 'SyncTestSettings', 0.002);    % the systems are a little noisy, give the test a little more leeway
                
                % Participant Screen
                [wpntP,winRectP] = PsychImaging('OpenWindow', scrParticipant, bgClr,scrCoordinatesParticipant, [], [], [], 4);
                
                % Operator Screen
                if useWindowedOperatorScreen
                    wrect  = Screen('GlobalRect', scrOperator);
                    [w, h] = Screen('WindowSize', scrOperator);
                    wrect  = CenterRect([w*.1 h*.1 w*.9 h*.9],wrect);
                    [wpntO,winRectO] = PsychImaging('OpenWindow', scrOperator, bgClr, wrect, [], [], [], 4, [], kPsychGUIWindow);
                else
                    [wpntO,winRectO] = PsychImaging('OpenWindow', scrOperator, bgClr,scrCoordinatesOperator, [], [], [], 4);
                end

                hz=Screen('NominalFrameRate', wpntP);
                
                Priority(1);
                Screen('BlendFunction', wpntP, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
                Screen('BlendFunction', wpntO, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);%useWindowedOperatorScreen    Screen('Preference', 'TextAlphaBlending', 1);
                Screen('Preference', 'TextAlphaBlending', 1);
                Screen('Preference', 'TextAntiAliasing', 2);
                % This preference setting selects the high quality text renderer on
                % each operating system: It is not really needed, as the high quality
                % renderer is the default on all operating systems, so this is more of
                % a "better safe than sorry" setting.
                Screen('Preference', 'TextRenderer', 1);
                KbName('UnifyKeyNames');    % for correct operation of the setup/calibration interface, calling this is required
                
                % do calibration
                try
                    ListenChar(-1);
                catch ME
                    % old PTBs don't have mode -1, use 2 instead which also supresses
                    % keypresses from leaking through to matlab
                    ListenChar(2);
                end
            
                tobii.calVal{1} = taskParam.EThndl.calibrateAdvanced([wpntP wpntO]);
                ListenChar(0);
            
                Screen('Close', wpntO);
                Screen('Close', wpntP);  
            
            catch me
        
                sca
                ListenChar(0);
                rethrow(me)
            
            end

           
           
        end

        function startTittaRecording(taskParam)

            taskParam.EThndl.buffer.startLogging(); % to record Events into buffer
            taskParam.EThndl.buffer.start('gaze');
            taskParam.EThndl.buffer.start('eyeOpenness');
            % Sanity check:
            if taskParam.EThndl.buffer.isRecording('gaze')
                disp('gaze recording:');
            end
            if taskParam.EThndl.buffer.isRecording('eyeOpenness')
                disp('eyeOpenness recording:');
            end
        end

        function saveTobiiData(taskParam)
            % This function saves the Tobii eye-tracking data using
            % Titta at the END of the experiment
            %
            %   Input
            %       taskParam: Task-parameter-object instance
            %
            %   Output
            %       None

            disp('Saving Tobii eyetracking data.');
            
            try
            
                % Saving the data on Matlab Computer
                temp_session_data = taskParam.EThndl.collectSessionData();
                                
                tempID = sprintf('commonConfetti_%s%s_%d',taskParam.subject.ID, '_et',taskParam.subject.startsWithBlock);
                                
                taskParam.EThndl.saveData(temp_session_data, [taskParam.gParam.dataDirectory, tempID]);
                
                disp('Session data saved successfully using Titta');
            
            catch 
                warning('Session data not saved using Titta');
            end
            
            taskParam.talkToProLab.stopRecording();
            
            try
                % Saving the data on the Tobii Computer after stop recording    
                taskParam.talkToProLab.finalizeRecording();
                disp('Session data saved successfully using Tobii Pro Lab');
            catch
                warning('Session data not saved using Tobii Pro Lab');
            end
           
            taskParam.talkToProLab.disconnect();
            taskParam.EThndl.deInit();

        end
        
    end
        
end





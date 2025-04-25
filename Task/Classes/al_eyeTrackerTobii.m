classdef al_eyeTrackerTobii
    %AL_EYETRACKERTOBII This class-definition file provides functions
    %that initialise the eyetracking in Tobii Pro Lab and save data in
    %addition to the taskDataMain class.
    %
    %  

    


    % Methods of the eye-tracker object
    % --------------------------------- 
    
    
    methods(Static)

        function taskParam = startTobii(taskParam)
            % startTobii first checks the ID. Then it starts the Titta handler and uses it
            % to start talkToProLab function. 
            %
            %   Input
            %       taskParam: Task-parameter-object instance
            %
            %   Output
            %       taskParam: Task-parameter-object instance
            
            
            % 0. Check if ID is for children and if Tobii is required
            if ~(strncmp(taskParam.subject.ID, '62',2) || strcmp(taskParam.gParam.eyeTrackerTobiiTest,"test_alone_confetti") || strcmp(taskParam.gParam.eyeTrackerTobiiTest,"test_temp"))
                ListenChar();
                ShowCursor;
                Screen('CloseAll');
                error('Invalid ID! Format should be 62xxx');
            end

            % Change the Intro status based on which block to start
            % For the children version, intro will be skipped if starts in the middle
            if taskParam.subject.startsWithBlock ~= 1
                taskParam.gParam.runIntro = false;
                disp('Skipping Intro');
            end 

            if ~taskParam.gParam.eyeTrackerTobii
                disp('Not using Tobii for this task.');
                return;
            end

            % 1. Start Titta and get the settings, these are added from a local location
            try
                addTittaToPath;
            catch
                warning('Titta is not in the folder.');
            end
            
            temp_eyeTrackerSettings = Titta.getDefaults('Tobii Pro Spectrum'); % Use the model from the selected tracker
            
            % request some debug output to command window, can skip for normal use
            temp_eyeTrackerSettings.debugMode    = true; % false
            temp_eyeTrackerSettings.freq = 1200;
            
            % setup screen colour here to start Titta
            fixClrs     = [0 255];
            bgClr       = 125;
            
            temp_eyeTrackerSettings.UI.setup.bgColor       = bgClr;
            temp_eyeTrackerSettings.UI.setup.instruct.color= fixClrs(1);
            temp_eyeTrackerSettings.UI.setup.fixBackColor  = fixClrs(1);
            temp_eyeTrackerSettings.UI.setup.fixFrontColor = fixClrs(2);

            try
                % 2. Initialisation with project settings through taskParam
                taskParam.EThndl    = Titta(temp_eyeTrackerSettings);
                temp_local_address = taskParam.gParam.localAddress;
                taskParam.EThndl.init(temp_local_address);
                
                
                % 3. Initialisation of Tobii Pro Lab 
                % project name is passed on from taskParam
                temp_Project = taskParam.gParam.eyeTrackerTobiiTest;
                temp_Tobii_Address = taskParam.gParam.TobiiAddress;
                taskParam.talkToProLab = TalkToProLab(temp_Project, temp_Tobii_Address);
    
                % 4. Start Recording, for Tobii, creating file name with the # of starting block
                tempID = sprintf('commonConfetti_%s%s_%d',taskParam.subject.ID, '_et',taskParam.subject.startsWithBlock);
                if ~strcmp(taskParam.subject.ID,'62000')
                    taskParam.talkToProLab.createParticipant(tempID, false); % false = does not allow dublicates
                else
                    taskParam.talkToProLab.createParticipant(62000, true);
                end
                
            catch
                ListenChar();
                ShowCursor;
                Screen('CloseAll');
                error('Cannot Start Tobii, please check project name');
            end
            
            % Screen height and width
            taskParam.talkToProLab.startRecording(tempID, taskParam.display.screensizePart(1), taskParam.display.screensizePart(2));
            
            % 5. Record reference time stamp, there is a 2 microseconds delay for Tobii Pro Lab
            taskParam.timingParam.refTittaSys = GetSecs();
            taskParam.timingParam.refTitta = taskParam.EThndl.buffer.systemTimestamp();
            taskParam.talkToProLab.sendCustomEvent([], sprintf('Start Ref start with Block %d', taskParam.subject.startsWithBlock)); % by defalut, current time is taken. This appears in Tobii Pro Lab output


        end


        function taskParam = startTobiiCalibration(taskParam)
            % startTobiiCalibration starts the calibration process that
            % requires user input. 
            % 
            %
            %   Input
            %       taskParam: Task-parameter-object instance
            %       
            
            openWindows = Screen('Windows');
            
            if ~isempty(openWindows)
                win = openWindows(1);  % Get the first open window
                % disp(['Detected window: ', num2str(win)]);
            else
                disp('No open windows found!');
            end
            
            % remove mouse confinement
            Screen('ConstrainCursor', win, 0);
            
             % Check the current conditions to see if we need baseline at the end 
            % if taskParam.subject.startsWithBlock == 1 && (~taskParam.gParam.baselineArousal)
            %     taskParam.gParam.baselineArousal = true;
            % end
            
            % Calibration pop-up
            while 1
                % Provide a choice for calibration process
                prompt = {'Do you want to calibrate? (Y/N)'};
                dlgtitle = 'Calibration?';
                fieldsize = [1 45];
                definput = {''};
                % Remove keyboard confinement temporarily
                ListenChar(0);
                answer = inputdlg(prompt,dlgtitle,fieldsize,definput);
                ListenChar(2);

                if ~isempty(answer) && (strcmp(answer{1},"Y")|strcmp(answer{1},"y"))
                    al_eyeTrackerTobii.tittaTobiiCalibration(taskParam);
                    break
                end

                if ~isempty(answer) && (strcmp(answer{1},"N")|strcmp(answer{1},"n"))
                    disp("Skipping calibration.");
                    break
                end

            end


        end


        function tittaTobiiCalibration(taskParam)
            % tittaTobiiCalibration handles calibration using Tobii
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

            % 2.Calibration process
            try
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
            
                try
                    Tobii.calVal{1} = taskParam.EThndl.calibrateAdvanced([wpntP wpntO]);
                catch
                    warning('calibration not sucessful');
                    ListenChar(0);
                end

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
            % This function starts Titta recording in the buffer
            %

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


        function saveTittaData(taskParam, varargin)
            % This function stops Titta recording in buffer and save Titta data for each
            % block to avoid memory problems
            %
            
            disp('Saving Tobii eyetracking data using Titta.');
            try
                % collecting data for this session.
                taskParam.EThndl.buffer.stop('gaze');
                taskParam.EThndl.buffer.stop('eyeOpenness');
                temp_session_data = taskParam.EThndl.collectSessionData();
                
                % Saving the data on Matlab Computer                
                try
                    tempID = sprintf('commonConfetti_%s%s%s',taskParam.subject.ID, '_et',varargin{1}(end-2:end));
                catch
                    warning('Not in Baseline or a block.');
                    tempID = sprintf('commonConfetti_%s%s%s',taskParam.subject.ID, '_et','_notData');
                end

            catch
                warning('Session data not collected using Titta.');
            end

            
            try
                % saving the data for this session
                taskParam.EThndl.saveData(temp_session_data, [taskParam.gParam.dataDirectory, tempID]);
                disp('Session data saved successfully using Titta.');
            catch 
                warning('Session data not saved using Titta.');
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

            openWindows = Screen('Windows');
            
            if ~isempty(openWindows)
                win = openWindows(1);  % Get the first open window
                % disp(['Detected window: ', num2str(win)]);
            else
                disp('No open windows found!');
            end
            
            % remove mouse confinement
            Screen('ConstrainCursor', win, 0);
            disp('Saving Tobii eyetracking data using Tobii Pro Lab.');
 
            taskParam.talkToProLab.stopRecording();
            try
                % Saving the data on the Tobii Computer after stop recording    
                taskParam.talkToProLab.finalizeRecording();
                disp('Session data saved successfully using Tobii Pro Lab.');
            catch
                warning('Session data not saved using Tobii Pro Lab.');
            end
           
            taskParam.talkToProLab.disconnect();
            taskParam.EThndl.deInit();

        end


        function restrictMouse(screensize)
            % This function restricts the mouse for the children
            %
            %   Input
            %       screensize: parameters of the participant screen
            %
            %   Output
            %       None

            
                temp_screenSize = [screensize(1), screensize(2), screensize(3)-100, screensize(4)];
                
                openWindows = Screen('Windows');
                if ~isempty(openWindows)
                    win = openWindows(1);  % Get the first open window
                    % disp(['Detected window: ', num2str(win)]);
                else
                    disp('No open windows found!');
                    return; % Exit function if no windows are found
                end
                Screen('ConstrainCursor', win, 0);
                Screen('ConstrainCursor', win, 1, temp_screenSize);
            
        end


        function sendEvent(taskParam, condition, Tevent, triggerID, trial, taskData)
            % sendEvent handles sending triggers to Tobii Pro Lab and Titta
            % condition copied from common confetti
            %
            %   Input
            %       taskParam: Task-parameter-object instance
            %       taskData: Task-data-object instance
            %       condition: Task condition
            %       trial: Current trial #
            %       Tevent: Event type that gets triggered 
            %       triggerID: Current trigger
            %
            %
            if taskParam.gParam.eyeTrackerTobii && (isequal(taskParam.trialflow.exp, 'exp') || isequal(taskParam.trialflow.exp, 'passive'))
                if isequaln(condition, 'baselineArousal')
                    temp_Tevent = sprintf('Baseline Colour %s ID %i', Tevent, triggerID);
                else
                    temp_name = taskData.savename;
                    if triggerID == 4
                        if (taskData.triggers(trial,4) == 0)
                            Tevent = append(Tevent,'1');
                            
                        elseif (taskData.triggers(trial,6) == 0)
                            Tevent = append(Tevent,'2');
                            
                        elseif (taskData.triggers(trial,8) == 0)
                            Tevent = append(Tevent,'3');
                            
                        end
                    end
                    temp_Tevent = sprintf('Block %s Trial %i Event %s ID %i', temp_name(end), trial, Tevent, triggerID);
                end
                
                temp_Tevent = convertCharsToStrings(temp_Tevent);
                

                % first send to Tobii Pro Lab
                taskParam.talkToProLab.sendCustomEvent([], temp_Tevent, []);
                
                % Then to Titta
                taskParam.EThndl.sendMessage(temp_Tevent);
            end

        end

        function taskParam = baselineArousalTobii(taskParam,file_name_suffix)

            taskParam.gParam.baselineArousal = false;% Display pupil info
            if taskParam.gParam.customInstructions
                header = taskParam.instructionText.firstPupilBaselineHeader;
                txt = taskParam.instructionText.firstPupilBaseline;
            else
                if strcmp(file_name_suffix, '_a1')
                    header = 'Erste Pupillenmessung';
                    txt=['Sie werden jetzt für drei Minuten verschiedene Farben auf dem Bildschirm sehen. '...
                    'Bitte fixieren Sie Ihren Blick währenddessen auf den kleinen Punkt in der Mitte des Bildschirms.'];
                elseif strcmp(file_name_suffix, '_a2')
                    header = 'Erste Pupillenmessung';
                    txt=['Sie werden jetzt für drei Minuten verschiedene Farben auf dem Bildschirm sehen. '...
                    'Bitte fixieren Sie Ihren Blick währenddessen auf den kleinen Punkt in der Mitte des Bildschirms.'];
                else
                    warning('Unidentified Baseline, skipping');
                    return
                end
   
            end
        
            feedback = false; % indicate that this is the instruction mode
            al_bigScreen(taskParam, header, txt, feedback, true);
        
            
           if strcmp(file_name_suffix, '_a1')
               taskParam = al_eyeTrackerTobii.startTobiiCalibration(taskParam);
           elseif strcmp(file_name_suffix, '_a2')
               taskParam.gParam.baselineArousalDuration =  taskParam.gParam.baselineArousalDuration/2;
           end
           al_eyeTrackerTobii.startTittaRecording(taskParam);

           if (isequal(taskParam.gParam.eyeTrackerTobiiTest, "test_temp") || isequal(taskParam.gParam.eyeTrackerTobiiTest, 'test_temp'))
               % Skipping for testing
               disp('test_temp BA working.');
               al_eyeTrackerTobii.saveTittaData(taskParam,file_name_suffix);
               return
           end
            % Measure baseline arousal
            al_baselineArousal(taskParam, file_name_suffix);
        
            % Save Titta data
            al_eyeTrackerTobii.saveTittaData(taskParam,file_name_suffix);
            
            
            disp(taskParam.gParam.baselineArousal);
            
        end
        
    end
end






classdef al_keys
    %AL_KEYS This class definition file specifies the 
    % properties and methods of a keys object
    %
    %   A keys object contains the key codes.
    
    % Properties of the subject object
    % --------------------------------
    
    properties
        
        delete
        rightKey
        keySpeed
        rightArrow
        leftArrow
        rightSlowKey
        slowKeySpeed
        leftKey
        leftSlowKey
        space
        enter        
        s
        five
        esc
        kbDev
        leftRelease
        rightRelease

    end
    
    % Methods of the conditions object
    % --------------------------------
    
    methods
        
        function self = al_keys()
            %AL_KEYS This function creates a keys object of
            % class keys
            
            KbName('UnifyKeyNames')
            self.delete = KbName('DELETE');
            self.rightKey = KbName('j');
            self.keySpeed = 0.75;
            self.rightArrow = KbName('RightArrow');
            self.leftArrow = KbName('LeftArrow');
            self.rightSlowKey = KbName('h');
            self.slowKeySpeed = 0.1;
            self.leftKey = KbName('f');
            self.leftSlowKey = KbName('g');
            self.space = KbName('Space');
            self.enter = 37;
            self.s = 40;
            self.five = 15; %'5';
            self.esc = KbName('ESCAPE');
            self.leftRelease = 43;
            self.rightRelease = 44; 
                      
        end

        function self = al_kbdev(self)
            % This function detects the keyboard device, necessary on 
            % some Macs

            kbdevs = [];
            devs = PsychHID('Devices');
            for d = 1:numel( devs )
                if strcmp(devs(d).usageName,'Keyboard')
                    kbdevs(end+1) = devs(d).index;
                end
            end
            
            if numel(kbdevs > 1)
              self.kbDev = -1; % "merge" all keyboard in KbCheck
            else
              self.kbDev = kbdevs;
            end
        end


        function self = checkQuitTask(self, eyeTracker, ID)
            % CHECKQUITTASK This function checks if esc was pressed to
            % quit task
            %
            %   Input
            %       eyeTracker: Optional eye-tracker argument (true/false)
            %       ID: Optional subject ID
            %
            %   Output
            %       None

            % Check if eye-tracker is used
            if ~exist('eyeTracker', 'var') || isempty(eyeTracker)
                eyeTracker = false;
            end

            % Check if ID is provided
            if ~exist('ID', 'var') || isempty(ID)
                ID = nan;
            end
                
            [ ~, ~, keyCode] = KbCheck(self.kbDev);
            if keyCode(self.esc)
                
                if eyeTracker

                    et_path = pwd;
                    et_file_name = sprintf('ec_%s', ID);
                    et_file_name=[et_file_name]; % todo: check if this is really necessary

                    al_saveEyelinkData(et_path, et_file_name)
                    Eyelink('StopRecording');

                end

                ListenChar();
                ShowCursor;
                Screen('CloseAll');
                error('User pressed Escape to quit task')
            end
        end
    end
end






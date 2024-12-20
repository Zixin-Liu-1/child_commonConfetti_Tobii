%% EyeOpennessData
%
% Provides data for the EyeOpenness.
%
%   eye_openness_data = EyeOpennessData(device_time_stamp,...
%                system_time_stamp,...
%                left_eye_validity,...
%                left_eye_openness_value,...
%                right_eye_validity,...
%                right_eye_openness_value)
%
%%
classdef EyeOpennessData
    properties (SetAccess = protected)
        %% LeftEyeValidity
        %
        %  eye_openness_data.LeftEyeValidity
        %
        LeftEyeValidity
        %% LeftEyeOpennessValue
        %
        %  eye_openness_data.LeftEyeOpennessValue
        %
        LeftEyeOpennessValue
        %% RightEyeValidity
        %
        % eye_openness_data.RightEyeValidity
        %
        RightEyeValidity
        %% RightEyeOpennessValue
        %
        %  eye_openness_data.RightEyeOpennessValue
        %
        RightEyeOpennessValue
        %% DeviceTimeStamp
        % Gets the time stamp according to the eye trackers internal clock.
        %
        %   eye_openness_data.DeviceTimeStamp
        %
        DeviceTimeStamp
        %% SystemTimeStamp
        % Gets the time stamp according to the computers internal clock.
        %
        %   eye_openness_data.SystemTimeStamp
        %
        SystemTimeStamp
    end

    methods
        function eye_openness_data = EyeOpennessData(device_time_stamp,...
            system_time_stamp,...
            left_eye_validity,...
            left_eye_openness_value,...
            right_eye_validity,...
            right_eye_openness_value)


            if nargin > 0
                eye_openness_data.DeviceTimeStamp = device_time_stamp;

                eye_openness_data.SystemTimeStamp = system_time_stamp;

                eye_openness_data.LeftEyeValidity = left_eye_validity;
                
                eye_openness_data.LeftEyeOpennessValue = left_eye_openness_value;
                
                eye_openness_data.RightEyeValidity = right_eye_validity;

                eye_openness_data.RightEyeOpennessValue = right_eye_openness_value;
            end

        end
    end

end



%% Version
% !version
%
% COPYRIGHT !year - PROPERTY OF TOBII PRO AB
% Copyright !year TOBII PRO AB - KARLSROVAGEN 2D, DANDERYD 182 53, SWEDEN - All Rights Reserved.
%
% Copyright NOTICE: All information contained herein is, and remains, the property of Tobii Pro AB and its suppliers,
% if any. The intellectual and technical concepts contained herein are proprietary to Tobii Pro AB and its suppliers and
% may be covered by U.S.and Foreign Patents, patent applications, and are protected by trade secret or copyright law.
% Dissemination of this information or reproduction of this material is strictly forbidden unless prior written
% permission is obtained from Tobii Pro AB.
%
function al_commonConfettiUninstructInstructions(taskParam)
%AL_COMMONCONFETTIUNINSTRUCTINSTRUCTIONS This function runs the instructions
% for the uninstruct version of the Hamburg confetti-cannon task
%
%   Minimal instruction flow: one welcome screen explaining the task,
%   one short practice block mimicking the structure of step 11 in
%   al_commonConfettiInstructions, and one start-experiment screen.
%
%   Practice data is loaded from hidCannonPracticeHamburgUninstruct.mat,
%   which defines the trial count and changepoint schedule. During practice,
%   outcomes are fixed to distMean (no variance). One catch trial is
%   included so the participant experiences the peek (outcome shown before
%   prediction).
%
%   Input
%       taskParam: Task-parameter-object instance
%
%   Output
%       None

% 1. Welcome and task explanation
% --------------------------------
% Single screen combining all essential information

% if taskParam.gParam.customInstructions
%     txt = taskParam.instructionText.welcomeText; % todo: create uninstruct text
% else
txt = ['Herzlich Willkommen zur Konfetti-Aufgabe!\n\n' ...
       'Sie sehen einen Kreis, auf dem Konfetti erscheinen wird. ' ...
       'Ihre Aufgabe ist es, vorherzusagen, wo das Konfetti als naechstes ' ...
       'auf dem Kreis erscheinen wird, und es mit einem Eimer zu fangen.\n\n' ...
       'Führen Sie den rosafarbenen Punkt mit der Maus an die Stelle, ' ...
       'wo Sie den Eimer platzieren möchten, und drücken Sie die linke ' ...
       'Maustaste, um Ihre Vorhersage abzugeben.\n\n' ...
       'Nach jeder Vorhersage sehen Sie, wo das Konfetti gelandet ist ' ...
       'und ob Sie es mit dem Eimer gefangen haben. ' ...
       'Die Größe des Eimers variiert und wird in jedem Durchgang zufällig ermittelt.\n\n' ...
       'Im ersten Durchgang jedes Blocks können Sie einfach raten. ' ...
       'Ab dem zweiten Durchgang sehen Sie zwei Striche auf dem Kreis:\n' ...
       'Der pinke Strich kennzeichnet die Position Ihrer letzten Vorhersage.\n' ...
       'Der schwarze Strich zeigt an, wo das Konfetti gelandet ist.\n\n' ...
       'In manchen Durchgaengen ist der Ort, an dem das Konfetti landen wird, ' ...
       'schon zu sehen - klicken Sie dann einfach darauf.\n\n' ...
       'Wenn Sie es schaffen, das Konfetti zu fangen, sammeln Sie Punkte. ' ...
       'Ihr Ziel ist es, möglichst viele Punkte zu sammeln.\n\n' ...
       'Bitte fixieren Sie nach jeder Vorhersage Ihren Blick auf den Punkt ' ...
       'in der Mitte des Kreises und vermeiden Sie Augenbewegungen.\n\n' ...
       'Es folgt zunächst ein kurzer Uebungsdurchgang.'];

% end

header = '';
feedback = true;
al_bigScreen(taskParam, header, txt, feedback);

% 2. Practice block
% ------------------
% Mimics the structure of step 11 in al_commonConfettiInstructions:
% set condition, configure trialflow, load data from .mat, run loop.

% Update condition
condition = 'main';
taskParam.trialflow.condition = 'uninstruct';

% Update trial flow (same as step 11)
taskParam.trialflow.colors = 'dark';
taskParam.trialflow.shot = 'static';
taskParam.trialflow.exp = 'practHid';
taskParam.trialflow.shieldAppearance = 'lines';
taskParam.trialflow.cannon = 'hide cannon';
taskParam.trialflow.confetti = 'show confetti cloud';
taskParam.trialflow.currentTickmarks = 'show';
taskParam.trialflow.push = 'practiceNoPush';
taskParam.trialflow.saveData = 'true';
taskParam.trialflow.saveEtData = 'false';
taskParam.cannon = taskParam.cannon.al_staticConfettiCloud(taskParam.trialflow.colors, taskParam.display);

% Set text size and font
Screen('TextSize', taskParam.display.window.onScreen, taskParam.strings.textSize);
Screen('TextFont', taskParam.display.window.onScreen, 'Arial');

% Load practice data
% The .mat file contains a fully populated taskData object with
% distMean, outcome, catchTrial, etc. already generated.
% No need to call al_cannonData — just load and override outcome.
taskData = load('hidCannonPracticeHamburgUninstruct.mat');
taskData = taskData.taskData;
taskData.saveAsStruct = true;

% Fix outcomes to distMean (no variance during practice)
taskData.outcome = taskData.distMean;

% Determine trial count from loaded data
nTrials = length(taskData.distMean);

% Update unit test predictions
taskParam.unitTest.pred = zeros(nTrials, 1);

% Run practice
al_confettiLoop(taskParam, condition, taskData, nTrials);

% Wait until keys released
KbReleaseWait();

% 3. Start experiment
% --------------------
% Parallel to Step 12 in al_commonConfettiInstructions

if taskParam.gParam.customInstructions
    header = taskParam.instructionText.startTaskHeader; % todo: create uninstruct text
    txt = taskParam.instructionText.startTask;
else
    header = 'Jetzt kommen wir zum Experiment';
    txt = ['Sie haben die Übungsphase abgeschlossen.\n\n'...
        'Versuchen Sie anhand der Position anhand der bisherigen ' ...
        'Konfettiwolken einzuschätzen wo das nächste Konfetti landen wird.\n\n'...
        'Beachten Sie, dass Sie das Konfetti trotz guter Vorhersagen '...
        'auch häufig nicht fangen können.\n\n'...
        'Achten Sie bitte auf Ihre Augenbewegungen und vermeiden Sie es '...
        'während eines Versuchs zu blinzeln. Wenn der Punkt in der Mitte '...
        'am Ende eines Versuchs weiß ist, dürfen Sie blinzeln.\n\nViel Erfolg!'
];
end

feedback = false;
al_bigScreen(taskParam, header, txt, feedback);

end

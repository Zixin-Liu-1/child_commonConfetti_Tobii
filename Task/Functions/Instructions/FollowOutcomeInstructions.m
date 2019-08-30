function FollowOutcomeInstructions
%FOLLOWOUTCOMEINSTRUCTIONS   This function runs the instruction for the follow-outcome version of the Dresden experiment
%
%   Input
%       ~
%
%    Output
%       ~

screenIndex = 1;
while 1
    switch(screenIndex)
        
        case 1
            
            txt = 'Kanonenkugeln Aufsammeln';
            screenIndex = YourTaskScreen(txt, taskParam.textures.basketTxt, screenIndex);
            
        case 2
            
            screenIndex = FirstCannonSlide(screenIndex);
            
        case 3
            
            [screenIndex, Data] = PressSpaceToInitiateCannonShot(screenIndex, true);
            
        case 4
            
            if isequal(subject.group, '1')
                
                txt=['Der schwarze Strich zeigt dir die '...
                    'Position der letzten Kugel. Der orangene '...
                    'Strich zeigt dir die Position deines '...
                    'letzten Korbes. Bewege den orangenen '...
                    'Punkt zur Stelle der letzten Kanonenkugel '...
                    'und dr�cke LEERTASTE um die Kugel '...
                    'aufzusammeln. '...
                    'Gleichzeitig schie�t die Kanone dann eine '...
                    'neue Kugel ab.'];
            else
                
                txt=['Der schwarze Strich zeigt Ihnen die '...
                    'Position der letzten Kugel. Der orangene '...
                    'Strich zeigt Ihnen die Position Ihres '...
                    'letzten Korbes. Bewegen Sie den orangenen '...
                    'Punkt zur Stelle der letzten Kanonenkugel '...
                    'und dr�cken Sie LEERTASTE um die Kugel '...
                    'aufzusammeln. Gleichzeitig schie�t die '...
                    'Kanone dann eine neue Kugel ab.'];
            end
            Data.distMean = 35;
            Data.outcome = 290;
            [screenIndex, Data] = MoveSpotToLastOutcome(screenIndex, Data, txt);
            
        case 5
            
            if isequal(subject.group, '1')
                txt=['Der Korb erscheint nach dem Schuss. '...
                    'In diesem Fall hast du die Kanonenkugel '...
                    'mit dem Korb aufgesammelt. Wie du sehen '...
                    'kannst, hat die Kanone auch eine neue '...
                    'Kugel abgeschossen, die du im n�chsten '...
                    'Durchgang aufsammeln kannst. Wenn '...
                    'mindestens die H�lfte der Kugel im Korb '...
                    'ist, z�hlt es als aufgesammelt.'];
                
            else
                txt=['Der Korb erscheint nach dem Schuss. '...
                    'In diesem Fall haben Sie die Kanonenkugel '...
                    'mit dem Korb aufgesammelt. Wie Sie sehen '...
                    'k�nnen, hat die Kanone auch eine neue '...
                    'Kugel abgeschossen, die Sie im n�chsten '...
                    'Durchgang aufsammeln k�nnen. Wenn '...
                    'mindestens die H�lfte der Kugel im '...
                    'Korb ist, z�hlt es als aufgesammelt.'];
                
            end
            distMean = 35;
            Data.distMean = 35;
            Data.outcome = 35;
            screenIndex = YouDidNotCollectTheCannonBall_TryAgain(screenIndex, Data, distMean, txt);
            
        case 6
            
            if isequal(subject.group, '1')
                txt=['Platziere den Korb jetzt wieder '...
                    'auf der Stelle der letzten Kanonenkugel '...
                    '(schwarzer Strich) und dr�cke LEERTASTE '...
                    'um die Kugel aufzusammeln.'];
            else
                
                
                txt=['Platzieren Sie den Korb jetzt wieder '...
                    'auf der Stelle der letzten Kanonenkugel '...
                    '(schwarzer Strich) und dr�cken Sie '...
                    'LEERTASTE um die Kugel aufzusammeln.'];
            end
            Data.distMean = 190;
            Data.outcome = 35;
            [screenIndex, Data] = MoveSpotToLastOutcome(screenIndex, Data, txt);
            
        case 7
            
            if isequal(subject.group, '1')
                
                txt = ['Sehr gut! Du hast die vorherige '...
                    'Kanonenkugel wieder aufgesammelt.'];
                
            else
                txt = ['Sehr gut! Sie haben die vorherige '...
                    'Kanonenkugel wieder aufgesammelt.'];
                
            end
            distMean = 190;
            Data.distMean = 190;
            Data.outcome = 190;
            screenIndex = YouDidNotCollectTheCannonBall_TryAgain(screenIndex, Data, distMean, txt);
            
        case 8
            
            if isequal(subject.group, '1')
                txt = sprintf(['Wenn du Kanonenkugeln '...
                    'aufsammelst, kannst du Geld verdienen. '...
                    'Wenn der Korb %s ist, verdienst du %s '...
                    'CENT wenn du die Kanonenkugel '...
                    'aufsammelst. Wenn der Korb %s ist, '...
                    'verdienst du nichts. Ebenso wie die '...
                    'Farbe, kann auch die Gr��e deines '...
                    'Korbes variieren. Die Farbe und die '...
                    'Gr��e des Korbes siehst du erst, '...
                    'nachdem die Kanone geschossen hat. '...
                    'Daher versuchst du am besten jede '...
                    'Kanonenkugel aufzusammeln.\n\nUm einen '...
                    'Eindruck von der wechselnden Gr��e '...
                    'und Farbe des Korbes zu bekommen, '...
                    'kommt jetzt eine kurze �bung.\n\n'],...
                    colRew, num2str(100*taskParam.gParam.rewMag),...
                    colNoRew);
                
            else
                
                txt = sprintf(['Wenn Sie Kanonenkugeln '...
                    'aufsammeln, k�nnen Sie Geld verdienen. '...
                    'Wenn der Korb %s ist, verdienen Sie %s '...
                    'CENT wenn Sie die Kanonenkugel '...
                    'aufsammeln. Wenn der Korb %s ist, '...
                    'verdienen Sie nichts. Ebenso wie die '...
                    'Farbe, kann auch die Gr��e Ihres Korbes '...
                    'variieren. Die Farbe und die Gr��e des '...
                    'Korbes sehen Sie erst, nachdem die Kanone '...
                    'geschossen hat. Daher versuchen Sie am '...
                    'besten jede Kanonenkugel aufzusammeln.'...
                    '\n\nUm einen Eindruck von der wechselnden '...
                    'Gr��e und Farbe des Korbes zu bekommen, '...
                    'kommt jetzt eine kurze �bung.\n\n'],...
                    colRew, num2str(100*taskParam.gParam.rewMag),...
                    colNoRew);
                
            end
            [screenIndex, Data] = YourShield(screenIndex,Data,txt);
            
        case 9
            
            screenIndex = ShieldPractice(screenIndex,whichPractice);
            
        case 10
            
            screenIndex = TrialOutcomes(screenIndex);
            
        case 11
            
            [screenIndex, Data] =...
                PressSpaceToInitiateCannonShot(screenIndex, false);
            
        case 12
            
            if isequal(subject.group, '1')
                
                
                txt= ['Versuche die letzte Kanonenkugel jetzt '...
                    'wieder aufzusammeln (angezeigt durch den '...
                    'schwarzen Strich).'];
            else
                txt= ['Versuchen Sie bitte die letzte '...
                    'Kanonenkugel wieder aufzusammeln '...
                    '(angezeigt durch den schwarzen Strich).'];
            end
            Data.distMean = 35;
            Data.outcome = 290;
            [screenIndex, Data] = MoveSpotToLastOutcome(screenIndex, Data, txt);
            
        case 13
            
            if isequal(subject.group, '1')
                if isequal(whichPractice, 'followOutcomePractice')
                    txt = sprintf(['Weil du die Kanonenkugel '...
                        'aufgesammelt hast und der Korb %s war, '...
                        'h�ttest du jetzt %s CENT verdient.'],...
                        colRew, num2str...
                        (100*taskParam.gParam.rewMag));
                else
                    txt = sprintf(['Weil du die Kanonenkugel '...
                        'aufgesammelt hast und das Schild %s '...
                        'war, h�ttest du jetzt %s CENT '...
                        'verdient.'], colRew,...
                        num2str(100*taskParam.gParam.rewMag));
                end
            else
                if isequal(whichPractice, 'followOutcomePractice')
                    txt = sprintf(['Weil Sie die Kanonenkugel '...
                        'aufgesammelt haben und der Korb %s '...
                        'war, h�tten Sie jetzt %s CENT '...
                        'verdient.'], colRew,...
                        num2str(100*taskParam.gParam.rewMag));
                else
                    txt = sprintf(['Weil Sie die Kanonenkugel '...
                        'aufgesammelt haben und das Schild '...
                        '%s war, h�tten Sie jetzt %s CENT '...
                        'verdient.'], colRew,...
                        num2str(100*taskParam.gParam.rewMag));
                end
            end
            distMean = 35;
            Data.distMean = 35;
            Data.outcome = 35;
            screenIndex = YouDidNotCollectTheCannonBall_TryAgain(screenIndex, Data, distMean, txt);
            
        case 14
            
            if isequal(subject.group, '1')
                
                
                txt= ['Versuche die letzte Kanonenkugel '...
                    'jetzt extra nicht aufzusammeln.'];
            else
                txt= ['Versuchen Sie bitte die letzte '...
                    'Kanonenkugel extra nicht aufzusammeln.'];
            end
            Data.distMean = 190;
            Data.outcome = 35;
            [screenIndex, Data] = MoveSpotToLastOutcome(screenIndex, Data, txt);
            
        case 15
            
            Data.distMean = 190;
            Data.outcome = 190;
            win = true;
            [screenIndex, Data] = YouCollectedTheCannonball_TryToMissIt(screenIndex, Data, win);
            
        case 16
            
            if isequal(subject.group, '1')
                txt= ['Versuche die letzte Kanonenkugel '...
                    'jetzt wieder aufzusammeln (angezeigt '...
                    'durch den schwarzen Strich).'];
            else
                txt= ['Versuchen Sie die letzte Kanonenkugel '...
                    'bitte wieder aufzusammeln (angezeigt '...
                    'durch den schwarzen Strich).'];
            end
            Data.distMean = 160;
            Data.outcome = 190;
            [screenIndex, Data] = MoveSpotToLastOutcome(screenIndex, Data, txt);
            
        case 17
            
            [screenIndex, Data] = YouMissedTheCannonball_TryToCollectIt(screenIndex, Data);
            
        case 18
            if isequal(subject.group, '1')
                
                txt= ['Versuche die letzte Kanonenkugel jetzt '...
                    'extra nicht aufzusammeln.'];
            else
                txt= ['Versuchen Sie bitte die letzte '...
                    'Kanonenkugel nicht aufzusammeln.'];
            end
            Data.distMean = 10;
            Data.outcome = 160;
            [screenIndex, Data] = MoveSpotToLastOutcome(screenIndex, Data, txt);
            
        case 19
            
            Data.distMean = 10;
            Data.outcome = 10;
            win = false;
            [screenIndex, Data] = YouCollectedTheCannonball_TryToMissIt(screenIndex, Data, win);
            
        case 20
            
            MainAndFollowCannon_CannonVisibleNoise
            
            screenIndex = screenIndex + 1;
            
        case 21
            
            header = 'Zweite �bung';
            
            if isequal(subject.group, '1')
                
                txt=['Im n�chsten '...
                    '�bungsdurchgang wird die Kanone meistens '...
                    'nicht mehr sichtbar sein. Anstelle der '...
                    'Kanone siehst du dann ein Kreuz, '...
                    'ansonsten bleibt alles gleich. '...
                    'Da du in dieser Aufgabe Kanonenkugeln '...
                    'aufsammelst, brauchst du nicht auf die '...
                    'Kanone zu achten.'];
            else
                
                txt=['Im n�chsten '...
                    '�bungsdurchgang wird die Kanone meistens '...
                    'nicht mehr sichtbar sein. Anstelle der '...
                    'Kanone sehen Sie dann ein Kreuz, '...
                    'ansonsten bleibt alles gleich. '...
                    'Da Sie in dieser Aufgabe Kanonenkugeln '...
                    'aufsammeln, brauchen Sie nicht auf die '...
                    'Kanone zu achten.'];
            end
            
            feedback = false;
            fw = al_bigScreen(taskParam, taskParam.strings.txtPressEnter, header, txt, feedback);
            if fw == 1
                screenIndex = screenIndex + 1;
            elseif bw == 1
                screenIndex = screenIndex - 3;
            end
            
            WaitSecs(0.1);
            
        case 22
            
            break
    end
end
end
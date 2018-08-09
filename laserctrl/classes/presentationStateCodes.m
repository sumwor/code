classdef presentationStateCodes
%only use the codes needed in the program
  properties (Constant)
% number codes for presentation states
%     NotRunning       =   -1;
%     SetUpTrial       =   1;
%     InitializeTrial  =   2;
%     StartOfTrial     =   3;
%     WithinTrial      =   4;
%     ChoiceMade       =   5;
%     DuringReward     =   6;
%     EndOfTrial       =   7;
%     InterTrial       =   8;
%     EndOfExperiment  =   9;
     trialStart = 1;
     trialEnd   = 0;
     sessionEnd = 2;
  end
end
classdef virmenStateCodes
%change this to presentation state codes
  properties (Constant)
% number codes for virmen states
    NotRunning       =   -1;
    SetUpTrial       =   1;
    InitializeTrial  =   2;
    StartOfTrial     =   3;
    WithinTrial      =   4;
    ChoiceMade       =   5;
    DuringReward     =   6;
    EndOfTrial       =   7;
    InterTrial       =   8;
    EndOfExperiment  =   9;
  end
end
# laser steering rig control program

## 1. digital output code
* 63: laser on
* 62: laser off
* 61: trial start ---- presentationstatecode: 1
* 60: trial end   ---- presentationstatecode: 0
* 59: session end ---- presentationstatecode: 2
* 58: intertrial interval ---- presentationstatecode: 3 (plan to include later, for save temp log)
* 1-57： position code


## 2. work flow
### 2.1. MatLab

  1) run lsrCtrlGUI.m
  2) cam ON
  3) load grid
    - check laser power and position
    
    3.5.  no need to register for now - plan to add this feature in the future
  
  4) presentation
  
### 2.2. presentation

  1) run scenario


## 3. logfile entries
### 3.1. info
- rig parameters 
- expt parameters
### 3.2. trial
- DIdata: original 6 bits binary input from presentation
- DICode: decimal code
- time: the time when code are received (in s), up to 8 ms error (due to iteration frequency)
### 3.3 notice
- a temp file is saved every trial, which takes roughly 30 ms. This could compromise the next digital input that is too short.

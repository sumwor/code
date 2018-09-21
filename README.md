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
### 1. MatLab

  1) run lsrCtrlGUI.m
  2) cam ON
  3) load grid
    - check laser power and position
  4) presentation
  
### 2. presentation

  1) run scenario

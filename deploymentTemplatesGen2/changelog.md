# Change Log
All notable changes to this project will be documented in this file.
 
The format is based on [Keep a Changelog](http://keepachangelog.com/)
and this project adheres to [Semantic Versioning](http://semver.org/).

## [unreleased]

## [2.0.0.0] 20.02.23
### Change
- [uiSvrDefinition,serverMain,windowsServer]
  reconfigured Security Type to allow Trusted launch for Windows Server 2022
### Add
- [uiSvrDefinition,serverMain]
  added Standard_Dsv5 and Dv5 VM sizes to allow Windows Server 2022 to support vTPM and nested virtualisation

## [2.0.0.0] 17.2.23
### Change
- [uiSvrDefinition,serverMain,windowsServer]
  added new course WWNAPT2

## [2.0.0.0] 15.2.23
### Change
- [uiSvrDefinition,serverMain]
  updated OS version

## [2.0.0.0] 31.01.23
### Change
- [uiSvrDefinition]
  changed course titles Course 1, 2, 3, 4
 
### Add
- [templates]
  Add Trusted Launch support for Gen2 managed Windows images.

## [2.0.0.0] 19.01.23
### Change
- [uiWcDefinition,uiSvrDefinition]
  added default tag value and set it to 'Yes' for resourceGroupCleanup

### Add
- [serverMain]
  added IT Bootcamp course

## [2.0.0.0] 18.01.23
### Change
- [uiWcDefinition,clientMain,windowsClient]
  added new DataLevel4 course

# Windows Server User Interface

## [2.0.0.0] 06.01.23
### Change
- [uiSvrDefinition]
  changed Troubleshooting Network Architecture part 1 and 2 to Troubleshooting Network Architecture
- [serverMain,windowsServer]
  changed TrblshootNetPt1 and TrblshootNetPt2 to TrblshootNet

### Add
- [uiSvrDefinition]
  added Working with End User Devices Part1 and Part2
- [serverMain,windowsServer]
  added Working with End User Devices Part1 and Part2

## [2.0.0.0] 13.12.22
### Change
- [uiSvrDefinition]
  Updated image naming and added new course.
- [serverMain]
  removed Network and Architecture

## [2.0.0.0] 21.10.22

### Change
- [uiSvrDefinition]
  Switched the OS Config position with VM config, moved platform to be part of OS config. 

## [1.0.4.0] 18.10.22

### Add
- [uiSvrDefinition]
  Added new course Supporting IT Architecture part 1 & 2 and Troubleshooting Networks

## [2.0.0.0] 18.10.22

### Add
- [serverMain,windowsServer]
  Added new course and custom image for Supporting IT Architecture and Troubleshooting Networks

## [2.0.0.0] 28.09.22

### Change
- [serverMain,windowsServer]
  Changed source repo to deploymentTemplategen2
  Changed gallery to TrainingACG
  Changed gallery image to BA-WinSvr2019

## [1.0.2.0] 11.08.22
 
### Change
- [uiSvrDefinition]
  Added visibility to vmSecurity. This section will only be visible during Linux deployment until gen 2 VMs are used.

## [1.0.1.0] 07.07.22
 
### Add
- [uiSvrDefinition]
  Add Security+ LabAdmin user.

# Windows Client User Interface

## [2.0.0.0] 21.10.22

### Change
- [uiWcDefinition]
  Switched the OS Config position with VM config, moved platform to be part of OS config. 

## [2.0.0.0] 28.09.22

### Change
- [clientMain,windowsClient]
  Changed source repo to deploymentTemplategen2
  Changed gallery to TrainingACG

## [1.0.3.0] 25.08.22

### Add
- [uiWcDefinition,clientMain,windowsClient]
  added new course SQL for Data Analysis

## [1.0.2.0] 11.08.22
 
### Change
- [uiWcDefinition]
  Added visibility to vmSecurity. This section will only be visible during Linux deployment until gen 2 VMs are used.


# Server Image and Courses (BA-WinSvrGen)
---

### Windwos Server General Image
- Mobility and Devices
- Server Fundamentals
- IT Essentials
- Security Plus
- IT Bootcamp

### Windows Server Supporting IT Architecture (BA-SupItArc)
- Working with End User Devices
- Supporting IT Architecture

### Windows Server - Troubleshooting Networks (BA-TshootNet)
- Troubleshooting Networks
- Working with Network Architecture Part 2
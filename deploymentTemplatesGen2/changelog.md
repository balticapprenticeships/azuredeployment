# Change Log
All notable changes to this project will be documented in this file.
 
The format is based on [Keep a Changelog](http://keepachangelog.com/)
and this project adheres to [Semantic Versioning](http://semver.org/).

## [unreleased]


# Windows Server User Interface

## [] 23.06.23
### Change
- [uiSvrDefinition,serverMain,windowsServer]
  added the capability to deploy VMs across subscription

## [2.2.1.0] 23.6.23
### Change
- [uiSvrDefinition]
- [serverMain] 2.0.0.0 
- [windowsServer] 1.0.0.0
  added L4 course 7

## [2.0.0.0] 01.06.23
### change
- [serverMain]
  removed location's default value ukwest
  set default location to reference resourceGroup

## [2.2.0.0]01.06.23
### change
- [uiSvrDefinition]
  removed config code block for location

## [2.1.1.0] 25.04.23
### Change
- [uiSvrDefinition]
  added L3 EPA image

## [2.0.0.0] 25.04.23
### Add
- [serverMain,windowsServer]
  added L3 EPA image
### Change
- [windowsClient]
  changed DSC config to use non experimental version

## [2.1.0.0] 17.04.23
### Change
- [uiSvrDefinition]
  removed user account option

## [2.0.0.0] 17.04.23
### Change
- [uiSvrDefinition,serverMain]
  set ICTNetC2 to use the TrblshootNet image.

## [2.0.0.0] 12.04.23
### Change
- [uiSvrDefinition,serverMain,windowsServer]
  added L4NetEngCourse5

## [2.0.0.0] 28.03.23
### Change
- [clientMain]
  removed user credentials output

## [2.0.0.0] 28.03.23
### Change
- [uiSvrDefinition,serverMain,windowsServer]
  added ICTNetC3

## [2.0.0.0] 27.03.23
### Change
- [uiSvrDefinition,serverMain,windowsServer,uiWcDefinition,windowsClient,clientMain]
  removed localUsername & localUserPassword (serverMain,clientMain)
  set suacConfig to only display for Linux deployments (uiSvrDefinition,uiWcDefinition)
  set localUserPassword from securestring to string (windowsServer,windowsClient)

## [2.0.0.0] 17.03.23
### Change
- [uiSvrDefinition,serverMain,windowsServer]
  added ICTNetCourse2
  removed Troubleshooting Networks

## [2.0.0.0] 15.03.23
### Change
- [uiSvrDefinition,serverMain,windowsServer]
  added Server Fundamentals 
  updated allowed versions
  removed Standard_B1ms

## [2.0.0.0] 07.03.23
### Change
- [uiSvrDefinition,serverMain,windowsServer]
  removed legacy course images

## [2.0.0.0] 24.02.23
### Change
- [uiSvrDefinition,serverMain,windowsServer]
  added new course L4NetEngCourse4

## [2.0.0.0] 23.02.23
### Change
- [windowsServer]
  changed image target
- [uiSvrDefinition,serverMain]

## [2.0.0.0] 22.02.23
### Change
- [uiSvrDefinition,serverMain,windowsServer]
  added new course ICTNetCourse5 (Cloud and On-Premises Network Infrastructure)

## [2.0.0.0] 21.02.23
### Change
- [uiSvrDefinition,serverMain,windowsServer]
  added Lab server dev image
- [uiSvrDefinition]
  set TrustedLaunch visability to Linux as TPM is not support on market place images via GitHub Actions
  Updated small server to use D2s_v5

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

### Change [2.4.1.0] 28.06.23
- [uiWcDefinition]
  removed NC4as_T4_v3 VM size

### Add [] 20.06.23
- [uiWcDefinition,clientMain,windowsServer]
  added the capability to deploy VMs across subscription

### Add [2.4.0.0] 20.06.23
- [uiWcDefinition]
  added new course SWAPC5

### Add [2.4.0.0] 08.06.23
- [uiWcDefinition]
  added NC12s_v3

## [2.3.0.0] 02.06.23
### Change
- [uiWcDefinition]
  removed NC6 virtual machine size
  removed small server VM size - not required for Windows Client VMs
### Add
- [uiWcDefinition]
  added NC4as_T4_v3
  added Standard SSD

## [1.0.0.0] 02.06.23
### Add
- [clientMain]
  added Standard SSD
### Change
- [clientMain]
  removed NC6 VM size
  added NC4as_T4_v3
  removed small server VM size - not required for Windows Client VMs

## [1.0.0.0] 01.06.23
### Add
- [windowsClient]
  added conditional VM extension to intall Azure Nvidia GRID & AMD drivers

## [2.2.0.0] 31.05.23
### change
- [uiWcDefinition]
  removed location block

## [1.0.0.0] 31.05.23
### change
- [clientMain]
  removed location's default value ukwest
  set default location to reference resourceGroup

## [2.1.2.0] 30.05.23
### Add
- [uiWcDefinition]
  added NC6 virtual machine size
  added NV4as_V4

## [1.0.0.0] 30.05.23
### Add
- [clientMain]
  added NC6 virtual machine size
  added NV4as_V4


## [2.1.1.0] 09.05.23

### Add
- [uiWcDefinition,windowsClient,clientMain]
  added Digital Marketing courses (DMCC3, DMCC4)
  added new VM size. Standard medium for Windows Client (B2ms)

## [2.1.0.0] 21.04.23

### Change
- [uiWcDefinition]
  Removed the requirement to add user credentials.

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


# Server Images and Courses
---

### Windwos Server General Image (BA-WinSvrGen)
- Mobility and Devices
- Server Fundamentals
- IT Essentials
- Security Plus
- IT Bootcamp

### Windows Server Supporting IT Architecture
- Course 1 (BA-ICTSupCourse1-2)
- Course 2 (BA-ICTSupCourse1-2)

##Windows Server - Working with End User Devices
- Course 3 (BA-ICTSupCourse3-4)
- Course 4 (BA-ICTSupCourse3-4)

###Windows Server - Working with Network Architecture
- Course 6 (BA-ICTSupCourse6)

### Windows Server - Understanding & Troubleshooting Networks Part 2
- Course 2 (BA-ICTNetCourse2)

### Windows Server - Cloud and On-Premises Network Infrastructure 
- Course 5 (BA-ICTNetCourse5)

### Windows Server - Level 4 Network Security (BA-L4NetEngCourse4)
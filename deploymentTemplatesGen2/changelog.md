# Change Log
All notable changes to this project will be documented in this file.
 
The format is based on [Keep a Changelog](http://keepachangelog.com/)
and this project adheres to [Semantic Versioning](http://semver.org/).


# Modules

## [3.1.3.0] 13.4.26
### Change
- [windowsDesktop]
  Reinstated the Testing image for MOS exams and added the ExamImage

## [3.1.2.0] 13.1.26
### Change
- [windowsDesktop]
  Changed Exam image from Testing (w10) to ExamImage (W11)

## [3.1.4.0] 13.8.25
### Change
- [serverMain]
  Changed idleVN to parameter

## [3.1.3.3] 24.4.25
### Add
- [uiSvrDefinition]
  added new image version

## [3.1.3.2] 4.4.25
### Add
- [uiSvrDefinition]
  added new image version

## [3.1.3.3] 24.4.25
### Add
- [serverMain]
  added new image version

## [3.1.3.2] 4.4.25
### Add
- [serverMain]
  added new image version

## [3.1.3.0] 15.11.24
### Change
- [serverMain,uiSvrDefinition]
  updated image allowed versions

## [3.1.1.0] 07.10.24
### Add
- [windowsServer]
  changed IT Bootcamp image to BA-ICTSupMstr

## [3.1.0.1] 26.09.24
### Add
- [windowsServer]
  added support for hibernation with Trusted Launch

## [3.1.0.1] 02.09.24
### Change
- [windowsDesktop]
  added support for hibernation with trusteed launch

## [3.1.0.1] 16.08.24
### Change
- [serverMain]
  updated image allowed versions

## [3.1.1.1] 16.08.24
### Change
- [uiSvrDefinition]
  updated allowed image versions

## [3.0.1.0] 13.03.24
### Change
- [networkInterface]
  added vmSize value
  chnaged acceleratedNetworking to check for vmSize

## [3.1.0.0] 06.03.24
### Change
- [publicIP]
  Changed allocation method to Static
  changed SKU to Standard ahead of mandatory change in 2025

# Windows Server User Interface

## [3.1.4.0] 13.8.25
### Change
- [uiSvrDefinition]
  Changed idleVN options to Yes and No

## [3.1.3.4] 22.07.25
### Change
- [uiSvrDefinition]
  Changed image versions

## [3.1.3.4] 22.07.25
### Change
- [serverMain]
  Changed image versions
  
## [3.1.3.1] 17.2.25
### Change
- [serverMain,uiSvtDefinition]
  Updated image allowed versiona

## [3.1.2.0] 09.10.24
### Add
- [serverMain]
  added Digital Skills routeway

## [3.1.2.0] 09.10.24
### add
- [uiSvrDefinition]
  added Digital Skills routeway

## [3.1.1.3] 27.09.24
### Change
- [uiSvrDefinition]
  updated image version

## [3.1.1.0] 07.10.24
### Change
- [serverMain]
  added new image version number 3.9.24

## [3.1.1.2] 27.09.24
### Change
- [uiSvrDefinition]
  updated image version

## [3.1.0.2] 26.09.24
### Change
- [serverMain]
  chnaged vTPM default value to false
  changed image version

## [3.1.0.0] 26.06.24
### Change
- [servermain,windowsServer,uiSvrDefinition]
  removed course 4 and 6 old

## [3.0.2.0] 13.03.24
### Change
- [serverMain]
  added vmSize value to networkInterface module

## [3.1.0.0] 04.03.24
### Change
- [uiSvrDefinition,serverMain]
  removed unused courses
  added apprenticeship programme option to UI
  grouped courses into programmes
  added course 2

## [3.0.1.0] 05.02.24
### Add
- [uiSvrDefinition,serverMain]
  added AMD server sku Standard_D2as_v5


# Windows Client User Interface

## [3.1.7.0] 14.1.26
### Change
- [uiWCDefinition]
  Changed programme mtaExam to exam
  Added new course 'ExamImage' to examImage

## [3.1.4.0] 14.1.26
### Change
- [desktopMain]
  Updated ImageVersion
  Changed courseImageValue matExam to exam
  Added examCourse ExamImage

## [3.1.6.1] 22.9.25
### Change
- [uiWCDefinition]
  ChangedSWAP5UE5 version to 5.4.4

## [3.1.6.0] 13.8.25
### Change
- [uiWCDefinition]
  Changed idleVN options to Yes and No

## [3.1.3.0] 13.8.25
### Change
- [desktopMain]
  Changed idleVN to parameter

## [3.1.5.1] 22.07.25
### Change
- [uiWcDefinition]
  Changed image versions

## [3.1.2.2] 22.07.25
### Change
- [desktopmain]
  Changed image versions

## [3.1.5.0] 25.06.25
### Change
- [uiWCDefinition]
  Changed L4 Data courses to pull the Data SQL DSC config

## [3.1.4.0] 23.06.25
### Change
- [uiWCDefinition]
  Changed L4 Data course 8 to pull the Data SQL DSC config

## [3.1.1.4] 2484.25
### Add
- [desktopMain]
  updated DeployWindowsVM content version

## [3.1.2.3] 24.4.25
### Add
- [uiWCDefinition]
  added new image version

## [3.1.2.2] 4.4.25
### Add
- [uiWCDefinition]
  added new image version

## [3.1.1.4] 24.4.25
### Add
- [desktopMain]
  added new image version
  removed unused course

## [3.1.1.3] 4.4.25
### Add
- [desktopMain]
  added new image version

## [3.1.1.2] 1.4.25
### Change
- [desktopMain]
  fixed VM size typo Standard_B2s to Standard_B2ms

## [3.1.21] 17.2.25
### Change
- [uiWcDefinition]
  Updated image allowed versiona

## [3.1.1.1] 17.2.25
### Change
- [desktopMain]
  Updated image allowed versiona
  Renamed clientMain to desktopMain

## [3.1.2.0] 29.11.24
### Add
- [uiWcDefinition]
  added Digital Skills to routeway

## [3.1.1.0] 29.11.24
### Add
- [clientMain]
  added Digital Skills to Keyvault variables

## [3.0.2.0] 13.03.24
### Change
- [clientMain]
  added vmSize value to networkInterface module
  added support for AMD based VMs (Standard_D2as_v5)

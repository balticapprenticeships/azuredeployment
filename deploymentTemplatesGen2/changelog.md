# Change Log
All notable changes to this project will be documented in this file.
 
The format is based on [Keep a Changelog](http://keepachangelog.com/)
and this project adheres to [Semantic Versioning](http://semver.org/).


# Modules

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

## [3.0.2.0] 13.03.24
### Change
- [clientMain]
  added vmSize value to networkInterface module
  added support for AMD based VMs (Standard_D2as_v5)
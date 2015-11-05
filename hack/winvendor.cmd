@echo off
setlocal

REM https://stackoverflow.com/questions/4051883/batch-script-how-to-check-for-admin-rights#11995662
echo Checking elevation...
net session >nul 2>&1
if %errorLevel% NEQ 0 (
    echo Failed: This script must be run elevated
    exit 1
)

REM Change to the docker repo root directory
pushd %~dp0..

REM Make sure we are in the right place before deleting, just in case
if not exist hack (
   echo Failed: hack directory not found
   exit -1
)

REM Delete/re-create the vendor directory
if exist vendor (
   echo Deleting vendor directory...
   rmdir /s /q vendor
)
echo Creating vendor directory...
mkdir vendor

REM Delete previous version and re-create symlink
if exist .gopath (
    echo Deleting .gopath...
    rmdir /s /q .gopath
)
echo Creating link at .gopath\src\github.com\docker\docker...
mkdir .gopath\src\github.com\docker
mklink /D .gopath\src\github.com\docker\docker .

REM Back to Unix parity.
echo Launching vendor shell script...
set VENDOR_FROM_WINDOWS=1
sh -c hack/vendor.sh

REM Restore the path
popd
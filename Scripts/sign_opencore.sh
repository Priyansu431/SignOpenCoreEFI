#!/bin/bash
. ./scripts/commonScript.sh
. ./scripts/checkWebConnectivty.sh

CreateFolder()
{
    mkdir -p "${1}"
}

#Check Internet connection
#1) Replace Internet check Code with checkWebConnectivity
CheckInternetConnection

#2) Check required Packages are installed or not use InstallRequiredPackages.sh file
. ./scripts/installRequiredPackages.sh

#3) Dowanload OpenCore latest version or spefic version use DownloadLatestOCBootloader.sh file
. ./scripts/downloadLatestOCBootloader.sh
# End -- 3) Dowanload OpenCore latest version or spefic version use DownloadLatestOCBootloader.sh file

# Start EFI Signing Process
. ./scripts/startSigningEfi.sh

exit
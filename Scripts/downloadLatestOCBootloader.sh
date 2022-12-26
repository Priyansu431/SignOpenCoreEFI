#!/bin/bash
printMessage "------------ Download OpenCore latest version ------------"

OpenCoreGitDetails="./files/openCoreGitDetails.json"
chmod -R 777 $OpenCoreGitDetails
rm -rf $OpenCoreGitDetails
printMessage "${OpenCoreGitDetails} is Deleted ..... "
sleep 2s

printMessage "Get latest OpenCore version"
respons=$(curl -s https://api.github.com/repos/acidanthera/OpenCorePkg/releases/latest | jq '{verison:.name,assets:.assets[] | select(.browser_download_url | contains("RELEASE"))}')

# Write Github api response into OpenCoreGitDetails.json files
echo $respons>>$OpenCoreGitDetails

# Extract data from Json Files
Version=`cat ${OpenCoreGitDetails} | jq -r '.verison'`
Link=`cat ${OpenCoreGitDetails} | jq -r '.assets | .browser_download_url'`
FileName=`cat ${OpenCoreGitDetails} | jq -r '.assets | .name'`
# echo "LINK : ${Link}"
printMessage "Verison: ${Version}"
printMessage "File Name: ${FileName}"
printMessage "Download Link: ${Link}"

TempDownloadFolder="./files/downloads"

chmod -R 777 "${TempDownloadFolder}/"
rm -rf "${TempDownloadFolder}/"
printMessage "${TempDownloadFolder} is Deleted ..... "
#sleep 5s


CreateFolder "$TempDownloadFolder"
# # Download OpenCore
OCDownloadPath="${TempDownloadFolder}/${FileName}"
wget "${Link}" --show-progress --progress=bar -q -O "${OCDownloadPath}"
unzip -q "${OCDownloadPath}" "X64/*" -d "${TempDownloadFolder}"

#Move EFI Folder From x64
mv "${TempDownloadFolder}/X64/EFI/" "${TempDownloadFolder}"
rm -rf "${TempDownloadFolder}/X64"

#Download HfsPlus.efi File and Move to Temp Folder for Processing
wget -q  https://github.com/acidanthera/OcBinaryData/raw/master/Drivers/HfsPlus.efi -O "${TempDownloadFolder}/HfsPlus.efi"
mv "${TempDownloadFolder}/HfsPlus.efi" "${TempDownloadFolder}/EFI/OC/Drivers"

printMessage "------------ End of Downloading OpenCore ------------"
# !/bin/bash
# Copyright (c) 2022 by Priyansu Prasad

CreateFolder()
{
    mkdir -p "${1}"
}

#Check Internet connection
case "$(curl -s --max-time 2 -I http://www.google.com | sed 's/^[^ ]*  *\([0-9]\).*/\1/; 1q')" in
    [23])
        echo "Web Connection is success...."
    ;;
    5)
        echo "The web proxy won't let us through"
        exit
    ;;
    *)
        echo "The network is down or very slow"
        exit
    ;;
esac

sudo apt-get install jq -y
sudo apt-get install wget -y
sudo apt-get install sbsigntool -y

OpenCoreGitDetails="OpenCoreGitDetails.json"

rm -rf $OpenCoreGitDetails
echo "${OpenCoreGitDetails} is Deleted ..... "
sleep 2s

echo "Get latest Open Core version and link"
respons=$(curl -s https://api.github.com/repos/acidanthera/OpenCorePkg/releases/latest | jq '{verison:.name,assets:.assets[] | select(.browser_download_url | contains("RELEASE"))}')

# Write Github api response into OpenCoreGitDetails.json files
echo $respons>>$OpenCoreGitDetails

# Extract data from Json Files
Version=`cat ${OpenCoreGitDetails} | jq -r '.verison'`
Link=`cat ${OpenCoreGitDetails} | jq -r '.assets | .browser_download_url'`
FileName=`cat ${OpenCoreGitDetails} | jq -r '.assets | .name'`
# echo "LINK : ${Link}"
echo "Verison: ${Version}"
echo "File Name: ${FileName}"
echo "Download Link: ${Link}"

TempDownloadFolder=".././TempDownload"

rm -rf "${TempDownloadFolder}/"
echo "${TempDownloadFolder} is Deleted ..... "
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


# Start EFI Signing Process
echo "EFI Signing In-Progress ........"
if [ -f "./Cert/ISK.key" ]; then
    echo "ISK.key was decrypted successfully"
    else
    echo "Not able to find ISK.key file....."
    exit
fi

if [ -f "./Cert/ISK.pem" ]; then
    echo "ISK.pem was decrypted successfully"
    else
    echo "Not able to find ISK.pem file....."
    exit
fi

#Copy EFI
cp -R "${TempDownloadFolder}/EFI/" "${TempDownloadFolder}/EFI-${Verison}-Signed/"

declare -a EFIFolders=("BOOT" "OC" "OC/Drivers" "OC/Tools")

for folder in "${EFIFolders[@]}"
do
    echo -e "\nCurrent Processing Folder ======= ${folder} ============"  
    #Remove file First then move the the signed folder 
    rm -rf "${TempDownloadFolder}/EFI-${Verison}-Signed/${folder}"/*.efi
    #sleep 5s

    for entry in "${TempDownloadFolder}/EFI/${folder}"/*.efi
    do
        efiFileName="$(basename  ${entry})"
        echo -e "\nCurrent Processing Filename  ============ '$efiFileName' ============ "
        echo "${folder} => ${entry}" 
        sbsign --key ./Cert/ISK.key --cert ./Cert/ISK.pem --output "${TempDownloadFolder}/EFI-${Verison}-Signed/${folder}/${efiFileName}" "${entry}"
    done
done

echo "EFI Signing completed successfully....."

exit
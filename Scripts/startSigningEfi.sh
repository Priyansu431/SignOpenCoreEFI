
# Start EFI Signing Process

certificatePath="./files/certificate/"

printMessage "\n---------- EFI Signing In-Progress ----------"
if [ -f "${certificatePath}ISK.key" ]; then
    printMessage "ISK.key was decrypted successfully"
else
    printMessage "Not able to find ISK.key file....."
    exit
fi

if [ -f "${certificatePath}ISK.pem" ]; then
    printMessage "ISK.pem was decrypted successfully"
else
    printMessage "Not able to find ISK.pem file....."
    exit
fi

# Copy EFI folder structure only
rsync -av -f"+ */" -f"- *" "${TempDownloadFolder}/EFI" "${TempDownloadFolder}/EFI-Signed/"


declare -a EFIFolders=("BOOT" "OC" "OC/Drivers" "OC/Tools")

for folder in "${EFIFolders[@]}"
do
    printMessage "Current Processing Folder ======= ${folder} ============"
    #Remove file First then move the the signed folder
    rm -rf "${TempDownloadFolder}/EFI-${Verison}-Signed/${folder}"/*.efi
    #sleep 5s
    
    for entry in "${TempDownloadFolder}/EFI/${folder}"/*.efi
    do
        efiFileName="$(basename  ${entry})"
        printMessage "\nCurrent Processing Filename  ============ '$efiFileName' ============ "
        printMessage "${folder} => ${entry}"
        sbsign --key ${certificatePath}ISK.key --cert ${certificatePath}ISK.pem --output "${TempDownloadFolder}/EFI-Signed/EFI/${folder}/${efiFileName}" "${entry}"

# sbsign --key ~/efitools/DB.key --cert ~/efitools/DB.crt \
#          --output vmlinuz-signed.efi vmlinuz.efi

    done
done

#Copy EFI
cp -R "${TempDownloadFolder}/EFI-Signed/EFI" "./EFI-${Version}-Signed/"

printMessage "---------- EFI Signing completed successfully ----------\n"

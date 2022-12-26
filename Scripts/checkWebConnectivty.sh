#!/bin/bash
#Check Internet connection
CheckInternetConnection(){
    
    printMessage "------------ Checking Internet connection ------------- "
    
    case "$(curl -s --max-time 2 -I http://www.google.com | sed 's/^[^ ]*  *\([0-9]\).*/\1/; 1q')" in
        [23])
            printMessage "Web Connection is success...."
        ;;
        5)
            printMessage "The web proxy won't let us through "
            exit
        ;;
        *)
            printMessage "The network is down or very slow "
            exit
        ;;
    esac
    
    printMessage "------------ End Of Internet Checking ------------- \n"
    
}


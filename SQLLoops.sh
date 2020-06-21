#!/bin/bash
#Stanleybet SQLLoops 
#Created by Robson Messias
#Last update date: 27/11/2019

echo -e '\033[33m'
echo "   _____ _              _            _          _   "
echo "  / ____|/ __ \| |    | |       __/ |               "
echo " | (___ | |  | | |    | |     _|___/___  _ __  ___  "
echo "  \___ \| |  | | |    | |    / _ \ / _ \|  _ \/ __| "
echo "  ____) | |__| | |____| |___| (_) | (_) | |_) \__ \ "
echo " |_____/ \___\_|______|______\___/ \___/|  __/|___/ "
echo "                                        | |         "
echo "                                        |_|         "
echo "                                                    "
echo -e '\033[0;0m'

export USER=$(whoami)
DBUser="postgres"
declare -a DataBaseName
declare -a RunlistArray
declare -a Array3
declare -a RunlistName
TotalTimeProcess=0

TotalTime ()
{
    hours=$(($1 / 3600))
    seconds=$(($1 % 3600))
    minutes=$(($1 / 60))
    seconds=$(($seconds % 60))
    echo "Total time: $hours hour(s) $minutes minute(s) $seconds second(s)"
}

#Check if the postgres user been used

if [ $USER != $DBUser ]; then
    echo "╔══════════════════════════════════════════════════════════╗"
    echo "║ Wrong user, you must run this script with postgres user  ║"
    echo "╚══════════════════════════════════════════════════════════╝"
    exit 1
else
    echo "                        SQLLoops Status                              "
    echo "╔═══════════════════════════════════════════════════════════════════╗"
    echo "║ User $USER detected                                            ║"
    echo "║                                                                   ║"
fi

if [ -e "./runlist" ]; then
    echo "║ Folder runlist already exists                                     ║"
    echo "║                                                                   ║"
else
    echo "║ Creating folder runlist                                           ║"
    echo "║                                                                   ║"
    mkdir ./runlist
    chmod -R 755 runlist
fi

if [ -e "./patches" ]; then
    echo "║ Folder patches already exists                                     ║"
    echo "║                                                                   ║"
else
    echo "║ Creating folder patches                                           ║"
    echo "║                                                                   ║"
    mkdir ./patches
    chmod -R 755 patches
fi

if [ -e "script_history" ]; then
    echo "║ The file script_history already exists                            ║"
    echo "║                                                                   ║"
else
    echo "║ Creating file script_history                                      ║"
    echo "║                                                                   ║"
    touch script_history
    chmod 755 script_history
fi

#Extract the database names from the Postgres instance

psql -l | grep "^\ galileo" | awk '{print $1}' >DBnames
chmod 755 DBnames
TotalVar=$(cat DBnames | wc -l)

#Stores the database names into the array

a=1
while [[ $a -le $TotalVar ]]; do
    PreName=$(cat DBnames | sed -n "$a"'p')
    DataBaseName[$a]=$PreName
    #echo "${DataBaseName[$a]}"
    ((a++))
done

#Check if runlist folder is empty, if yes it will create the runlist for each database.

if [ -z "$(ls -A runlist)" ]; then
    a=1
    while [[ $a -le $TotalVar ]]; do
        PreName=$(cat DBnames | sed -n "$a"'p')
        DataBaseName[$a]=$PreName
        touch runlist/${DataBaseName[$a]}.runlist
        #echo "${DataBaseName[$a]}"
        ((a++))
    done
    echo "║ The runlists were created inside the runlist folder.              ║"
    echo "║                                                                   ║"
fi

#Stores the runlist names to compare with the avaliable databases on Postgres instance

RunlistCount=$(ls -l runlist/*.runlist | awk '{print $9}' | wc -l)

c=1
while [[ $c -le $RunlistCount ]]; do
    PreName=$(ls -v runlist/*.runlist | cut -f1 -d. | cut -f2 -d/ | sed -n "$c"'p')
    RunlistArray[$c]=$PreName
    ((c++))
done

echo "║ All runlists were found  inside folder runlist                    ║"
echo "╚═══════════════════════════════════════════════════════════════════╝"
echo ""

echo "Galileo's databases:"
echo ""

for ((b = 1; b <= $RunlistCount; b++)); do
    if [[ ${DataBaseName[$b]} == ${RunlistArray[$b]} ]]; then
        echo $b ${DataBaseName[$b]}
    else
        echo ""
        echo "╔═══════════════════════════════════════════════════════════════════╗"
        echo "║ Error... The runlist for ${DataBaseName[$b]} database is missing! ║"
        echo "║       Insert the missing runlist in the folder runlist            ║"        
        echo "╚═══════════════════════════════════════════════════════════════════╝"
        echo ""
        exit 1
    fi
done

echo ""
echo "Options: "
echo "Type a number as above to select a database to be updated (eg. 1 or 2)"
echo "Type the word update to update the runlists and SQL patches from the Git repository (e.g. update)"
echo "Or exit to finish this script (e.g. exit): "
echo -n "Insert you option: "
read Input_String

if [[ $Input_String == "update" ]]; then
    bash ./RunListUpdate.sh
    wait
    exit 1
fi

check="true"
if [[ $Input_String == ?([1-9]) ]] || [[ $Input_String == ?([1-9][0-9]) ]]; then
    if [ $check = "false" ]; then
        echo ""
        echo "Insert another database to be updated or exit to finish this application (e.g. 1 or exit): "
        read Input_String
        echo ""
        if [[ $Input_String -le $RunlistCount ]] && [[ $Input_String -ge 1 ]]; then
            echo ""
            echo "You selected the ${DataBaseName[$Input_String]} database"
            echo ""
            echo "═════════════════════════════════════════════════════════"
            DBLoop=$(cat runlist/${DataBaseName[$Input_String]}.runlist | wc -l)
            if [ -z $DBLoop ] || [ $DBLoop = '0' ]; then
                echo ""
                echo "Do not exist a list of scripts inside the ${DataBaseName[$Input_String]}.runlist."
                echo ""
                exit 1
            else
                for ((d = 1; d <= $DBLoop; d++)); do
                    ScriptName=$(cat runlist/${DataBaseName[$Input_String]}.runlist | sed -n "$d"'p')
                    Compare_Script=$(cat script_history | grep ${DataBaseName[$Input_String]} | awk '{print $3}' | grep $ScriptName)
                    if [[ $Compare_Script == $ScriptName ]]
                    then
                        echo ""
                        echo -n " Warning: The $ScriptName patch has already been applied to the ${DataBaseName[$Input_String]}, would you like to apply it again? [y,n]: "
                        read Input_Question
                        if [ $Input_Question == "y" ] || [ $Input_Question == "Y" ]
                        then
                            echo ""
                            echo "... You have chosen to continue!"
                            echo ""
                        else
                            echo ""
                            echo "... You have chosen not to continue with this procedure!"
                            echo ""
                            exit 1
                        fi
                    fi
                    StartTime=$(date -u +%s)
                    date=$(date -u +%d/%m/%Y_%H:%M:%S)
                    echo "---------- Patch $ScriptName starts here ------------" >> script_history
                    echo "$date ${DataBaseName[$Input_String]} $ScriptName" >> script_history
                    echo "" >> script_history
                    psql -h 127.0.0.1 -U galileo -d ${DataBaseName[$Input_String]} -f patches/$ScriptName 2>&1 | tee -a script_history
                    echo "" 2>&1 | tee -a script_history
                    sleep 1
                    EndTime=$(date -u +%s)
                    TotalTime=$(($EndTime - $StartTime))
                    echo "Ending time and date is $(date)" 2>&1 | tee -a script_history
                    echo "Execution time for the patch $ScriptName was $TotalTime seconds" 2>&1 | tee -a script_history
                    check="false"
                    TotalTimeProcess=$($TotalTimeProcess + $TotalTime)
                done
                TotalTime $TotalTimeProcess 2>&1 | tee -a script_history
                echo ""
                echo "Database Sha256sum:"
                pg_dump -s ${DataBaseName[$Input_String]} > ${DataBaseName[$Input_String]}.sql
                sha256sum ${DataBaseName[$Input_String]}.sql 2>&1 | tee -a script_history
                echo "" >> script_history
                echo "---------- Patch $ScriptName End ------------" >> script_history
                echo "" >> script_history
            fi
        else
            if [[ $Input_String == "exit" ]] || [[ $Input_String == "Exit" ]]; then
                echo ""
                echo "╔═══════════════════════════════════════════════════╗"
                echo "║ This application has been successfully terminated ║"
                echo "╚═══════════════════════════════════════════════════╝"
                echo ""
                exit 1
            else
                echo ""
                echo "╔════════════════════════════════════════════════════╗"
                echo "║ Wrong option! Insert the correct values next time! ║"
                echo "╚════════════════════════════════════════════════════╝"
                echo ""
                exit 1
            fi
        fi
    else
        if [[ $Input_String -le $RunlistCount ]] && [[ $Input_String -ge 1 ]]; then
            echo ""
            echo "You selected the ${DataBaseName[$Input_String]} database"
            echo ""
            echo "═══════════════════════════════════════════════════════════"
            DBLoop=$(cat runlist/${DataBaseName[$Input_String]}.runlist | wc -l)
            if [ -z $DBLoop ] || [ $DBLoop = '0' ]; then
                echo ""
                echo "Do not exist a list of scripts inside the ${DataBaseName[$Input_String]}.runlist."
                echo ""
                exit 1
            else
                for ((d = 1; d <= $DBLoop; d++)); do
                    ScriptName=$(cat runlist/${DataBaseName[$Input_String]}.runlist | sed -n "$d"'p')
                    Compare_Script=$(cat script_history | grep ${DataBaseName[$Input_String]} | awk '{print $3}' | grep $ScriptName)
                    if [[ $Compare_Script == $ScriptName ]]; then
                        echo ""
                        echo -n "Warning: The $ScriptName patch has already been applied to the ${DataBaseName[$Input_String]}, would you like to apply it again? [y,n]: "
                        read Input_Question
                        if [[ $Input_Question == "y" ]] || [[ $Input_Question == "Y" ]]; then
                            echo ""
                            echo "... You have chosen to continue!"
                            echo ""
                        else
                            echo ""
                            echo "... You chose not to continue!"
                            echo ""
                            exit 1
                        fi
                    fi
                    StartTime=$(date -u +%s)
                    date=$(date -u +%d/%m/%Y_%H:%M:%S)
                    echo "---------- Patch $ScriptName starts here ------------" >> script_history
                    echo "$date ${DataBaseName[$Input_String]} $ScriptName" >> script_history
                    echo "" >> script_history
                    psql -h 127.0.0.1 -U galileo -d ${DataBaseName[$Input_String]} -f patches/$ScriptName 2>&1 | tee -a script_history
                    echo "" 2>&1 | tee -a script_history
                    sleep 1
                    EndTime=$(date -u +%s)
                    TotalTime=$(($EndTime - $StartTime))
                    echo "Ending time and date is $(date)" 2>&1 | tee -a script_history
                    echo "Execution time for the patch $ScriptName was $TotalTime seconds" 2>&1 | tee -a script_history
                    check="false"
                    TotalTimeProcess=$(($TotalTimeProcess + $TotalTime))
                done
                TotalTime $TotalTimeProcess 2>&1 | tee -a script_history
                echo ""
                echo "Database Sha256sum:"
                pg_dump -s ${DataBaseName[$Input_String]} > ${DataBaseName[$Input_String]}.sql
                sha256sum ./${DataBaseName[$Input_String]}.sql 2>&1 | tee -a script_history
                echo "" >> script_history
                echo "---------- Patch $ScriptName End ------------" >> script_history
                echo "" >> script_history
            fi
            echo ""
            echo "╔═════════════════════════════════════════╗"
            echo "║ Selected database successfully updated  ║"
            echo "╚═════════════════════════════════════════╝"
            echo ""
            exit 1
        else
            if [[ $Input_String == "exit" ]] || [[ $Input_String == "Exit" ]]; then
                echo ""
                echo "╔════════════════════════════════════════════════════╗"
                echo "║ This application has been successfully terminated  ║"
                echo "╚════════════════════════════════════════════════════╝"
                echo ""
                exit 1
            else
                echo ""
                echo "╔════════════════════════════════════════════════════╗"
                echo "║ Wrong option! Insert the correct values next time! ║"
                echo "╚════════════════════════════════════════════════════╝"
                echo ""
                exit 1
            fi
        fi
    fi
fi

if [[ $Input_String == "exit" ]] || [[ $Input_String == "Exit" ]]; then
    echo ""
    echo "╔═══════════════════════════════════════════════════╗"
    echo "║ This application has been successfully terminated ║"
    echo "╚═══════════════════════════════════════════════════╝"
    echo ""
    exit 1
else
    echo ""
    echo "╔════════════════════════════════════════════════════╗"
    echo "║ Wrong option! Insert the correct values next time! ║"
    echo "╚════════════════════════════════════════════════════╝"
    echo ""
    exit 1
fi

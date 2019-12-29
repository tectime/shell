#!/bin/bash
#Stanleybet SQLLoops Update tool 
#Created by Robson Messias
#Last update date: 27/11/2019

export stag=$(hostname)
export env=$(hostname | cut -c -2)
export hostname=$(hostname)
declare -a DataBaseName

echo ""
echo "SQLLoops Runlists and database patches Update"
echo ""

if [ -e "./runlist" ]; then
    echo "Checking if the folder runlist exist..."
    echo "Folder runlist  ---------------------------------------------------------> [ok]"
    echo ""
else
    echo "Something is wrong! The folder runlist does not exist or is empty!"
    echo "Please, execute the SQLLoops.sh to create the runlist folder."
    echo ""
    exit 1
fi

echo -e '\033[36m'
echo -e "╔════════════════════════════════════════════════╗"
echo -e "║ Donwloading the runlists from Git Repository...║"
echo -e "╚════════════════════════════════════════════════╝"
echo -e '\033[0;0m'

TotalVar=$(cat DBnames | wc -l)

#Check if exist updates for the runlits in the git repository

if [[ $stag == "qadbstag9" ]] || [[ $stag == "qadbstag" ]]; then
    if [[ $stag == "qadbstag" ]]; then
        a=1
        while [[ $a -le $TotalVar ]]; do
            PreName=$(cat DBnames | sed -n "$a"'p')
            DataBaseName[$a]=$PreName
            checksumold=$(sha1sum runlist/${DataBaseName[$a]}.runlist)
            echo -e "Updating runlist ${DataBaseName[$a]}\033[32m"
            /usr/bin/curl -k --progress-bar --header "PRIVATE-TOKEN: Insert the private token here " https://pr-gb-ops-gitlab-01.stanleybet.com/DevOps/configcent/raw/galileoservice/scripts/runlist/stag/qadbstag/${DataBaseName[$a]}.runlist -o runlist/${DataBaseName[$a]}.runlist
            checksumNew=$(sha1sum runlist/${DataBaseName[$a]}.runlist)
            if [[ $checksumold == $checksumNew ]]; then
                echo -e "\033[31m No changes detected on ${DataBaseName[$a]}.runlist \033[0;0m"
                echo ""
            else
                echo -e "The file ${DataBaseName[$a]}.runlist was successfully updated! \033[0;0m"
                echo ""
            fi
            ((a++))
        done
    else
        a=1
        while [[ $a -le $TotalVar ]]; do
            PreName=$(cat DBnames | sed -n "$a"'p')
            DataBaseName[$a]=$PreName
            checksumold=$(sha1sum runlist/${DataBaseName[$a]}.runlist)
            echo -e "Updating runlist ${DataBaseName[$a]}\033[32m"
            /usr/bin/curl -k --progress-bar --header "PRIVATE-TOKEN: Insert the private token here " https://pr-gb-ops-gitlab-01.stanleybet.com/DevOps/configcent/raw/galileoservice/scripts/runlist/stag/qadbstag9/${DataBaseName[$a]}.runlist -o runlist/${DataBaseName[$a]}.runlist
            checksumNew=$(sha1sum runlist/${DataBaseName[$a]}.runlist)
            if [[ $checksumold == $checksumNew ]]; then
                echo -e "\033[31m No changes detected on ${DataBaseName[$a]}.runlist \033[0;0m"
                echo ""
            else
                echo -e "The file ${DataBaseName[$a]}.runlist was successfully updated! \033[0;0m"
                echo ""
            fi
            ((a++))
        done
    fi
    if [ -e "./patches" ]; then
        echo "Checking if the folder patches exist..."
        echo "Folder patches -----------------------------------------------------------> [ok]"
        echo ""
    else
        echo "Something is wrong! The folder patches does not exist or is empty!"
        echo "Please, execute the SQLLoops.sh to create the folder patches"
        echo ""
        exit 1
    fi

    #Procedure to update the patches

    echo -e '\033[36m'
    echo -e "╔════════════════════════════════════════════════╗"
    echo -e "║ Donwloading the patches from Git Repository...  ║"
    echo -e "╚════════════════════════════════════════════════╝"
    echo -e '\033[0;0m'

    b=1
    while [[ $b -le $TotalVar ]]; do
        PreName=$(cat ./DBnames | sed -n "$b"'p')
        cat runlist/$PreName.runlist >>list_tmp
        echo -e "\n" >>list_tmp
        ((b++))
    done

    cat list_tmp | sed '/^$/d' | sort | uniq -d >list
    cat list_tmp | sed '/^$/d' | sort | uniq --u >>list
    chmod 755 list
    rm list_tmp

    Totalpatches=$(cat list | wc -l)

    c=1
    while [[ $c -le $Totalpatches ]]; do
        patchesName=$(cat list | sed -n "$c"'p')
        echo $patchesName
        ChecksumOldPatch=$(sha1sum ./patches/$patchesName)
        /usr/bin/curl -k --progress-bar --header "PRIVATE-TOKEN: Insert the private token here " https://pr-gb-ops-gitlab-01.stanleybet.com/DevOps/configcent/raw/galileoservice/scripts/patchs/$patchesName -o patches/$patchesName
        ChecksumNewPatch=$(sha1sum ./patches/$patchesName)
        if [ -e "./patches/$patchesName" ]; then        
            if [[ $ChecksumOldPatch == $ChecksumNewPatch ]]; then
                echo -e "\033[31m No changes detected on $patchesName \033[0;0m"
                echo ""
            else
                echo -e "\033[32m Patch successfully downloaded \033[0;0m"
            fi
        else
            echo -e "\033[31m Error... the patch $patchesName not found \033[0;0m"
            echo ""
        fi
        ((c++))
    done
    exit 1
fi

if [[ $env == "pr" ]] || [[ $env == "PR" ]] || [[ $env == "qa" ]] || [[ $env == "at" ]]; then
    if [[ $env == "PR" ]]; then
        env="pr"
    fi
    if [[ $env == "at" ]]; then
        env="pr"
    fi
    a=1
    while [[ $a -le $TotalVar ]]; do
        PreName=$(cat DBnames | sed -n "$a"'p')
        DataBaseName[$a]=$PreName
        checksumold=$(sha1sum runlist/${DataBaseName[$a]}.runlist)
        echo -e "Updating runlist ${DataBaseName[$a]}\033[32m"
        /usr/bin/curl -k --progress-bar --header "PRIVATE-TOKEN: Insert the private token here " https://pr-gb-ops-gitlab-01.stanleybet.com/DevOps/configcent/raw/galileoservice/scripts/runlist/$env/$hostname/${DataBaseName[$a]}.runlist -o runlist/${DataBaseName[$a]}.runlist
        checksumNew=$(sha1sum runlist/${DataBaseName[$a]}.runlist)
        if [[ $checksumold == $checksumNew ]]; then
            echo -e "\033[31m No changes detected on ${DataBaseName[$a]}.runlist \033[0;0m"
            echo ""
        else
            echo -e "The file ${DataBaseName[$a]}.runlist was successfully updated! \033[0;0m"
            echo ""
        fi
        ((a++))
    done
fi

if [[ $env == "st" ]]; then
    env="stag"
    a=1
    while [[ $a -le $TotalVar ]]; do
        PreName=$(cat DBnames | sed -n "$a"'p')
        DataBaseName[$a]=$PreName
        checksumold=$(sha1sum runlist/${DataBaseName[$a]}.runlist)
        echo -e "Updating runlist ${DataBaseName[$a]}\033[32m"
        /usr/bin/curl -k --progress-bar --header "PRIVATE-TOKEN: Insert the private token here " https://pr-gb-ops-gitlab-01.stanleybet.com/DevOps/configcent/raw/galileoservice/scripts/runlist/$env/$hostname/${DataBaseName[$a]}.runlist -o runlist/${DataBaseName[$a]}.runlist
        checksumNew=$(sha1sum runlist/${DataBaseName[$a]}.runlist)
        if [[ $checksumold == $checksumNew ]]; then
            echo -e "\033[31m No changes detected on ${DataBaseName[$a]}.runlist \033[0;0m"
            echo ""
        else
            echo -e "The file ${DataBaseName[$a]}.runlist was successfully updated! \033[0;0m"
            echo ""
        fi
        ((a++))
    done
fi


if [ -e "./patches" ]; then
    echo "Checking if the folder patches exist..."
    echo "Folder patches -----------------------------------------------------------> [ok]"
    echo ""
else
    echo "Something is wrong! The folder patches does not exist or is empty!"
    echo "Please, execute the SQLLoops.sh to create the folder patches"
    echo ""
    exit 1
fi

#Procedure to update the patches

echo -e '\033[36m'
echo "╔════════════════════════════════════════════════╗"
echo "║ Donwloading the patches from Git Repository...  ║"
echo "╚════════════════════════════════════════════════╝"
echo -e '\033[0;0m'

b=1
while [[ $b -le $TotalVar ]]; do
    PreName=$(cat ./DBnames | sed -n "$b"'p')
    cat runlist/$PreName.runlist >>list_tmp
    echo -e "\n" >>list_tmp
    ((b++))
done

cat list_tmp | sed '/^$/d' | sort | uniq -d >list
cat list_tmp | sed '/^$/d' | sort | uniq --u >>list
chmod 755 list
rm list_tmp
Totalpatches=$(cat list | wc -l)

c=1
while [[ $c -le $Totalpatches ]]; do
    patchesName=$(cat list | sed -n "$c"'p')
    echo $patchesName
    if [ -e "./patches/$patchesName" ]; then
        ChecksumOldPatch=$(sha1sum ./patches/$patchesName)
    else
        ChecksumOldPatch=0
    fi
    /usr/bin/curl -k --progress-bar --header "PRIVATE-TOKEN: Insert the private token here " https://pr-gb-ops-gitlab-01.stanleybet.com/DevOps/configcent/raw/galileoservice/scripts/patchs/$patchesName -o patches/$patchesName
    ChecksumNewPatch=$(sha1sum ./patches/$patchesName)
    if [ -e "./patches/$patchesName" ]; then        
        if [[ $ChecksumOldPatch == $ChecksumNewPatch ]]; then
            echo -e "\033[31m No changes detected on $patchesName \033[0;0m"
            echo ""
        else
            echo -e "\033[32m Patch successfully downloaded \033[0;0m"
        fi
    else
        echo -e "\033[31m Error... the patch $patchesName not found \033[0;0m"
        echo ""
    fi
    ((c++))
done

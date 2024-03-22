#!/bin/bash

# Define delay for better readability
delay=5

# Colors for styling
RED='\033[0;31m'
white='\033[0;37m'
blue='\033[1;34m'


echo -e "${white}THREE STEPS:	
	1/ See live domains
	2/ Open live domains in Chromium
	3/ Take screenshots 
"

read -p "Enter the Domain: " domain

# Check if the domain exists
if ping -c 1 "ayakalammayhm.$domain" &> /dev/null; then
    echo -e ">>>>>>>>>>>>>>>> ${RED}BAD: Domain exists. Mission canceled."
    while true; do echo -e "\a"; done
    exit 1
else
    echo -e ">>>>>>>>>>>>>>>> ${RED}GOOD: Domain doesn't exist. Continuing with the mission."
    sleep $delay

    mkdir /$USER/$domain 2> /dev/null

    gathering_subs() {
        echo ""
        echo -e "${blue}GATHER SUBDOMAINS"
        echo "-------------------------------------------"
        subfinder -d $domain -nW > /$USER/$domain/subfinder.txt
        python /$USER/Sublist3r/sublist3r.py -d $domain
        amass enum -active -d $domain -ipv4 -timeout 10 -o /$USER/$domain/amass.txt
        cat /$USER/$domain/amass.txt | awk '{print $1}' > /$USER/$domain/result_amass.txt
    }

    put_subs_together() {
        echo ""
        echo -e "${blue}Put all subdomains together"
        echo "---------------------------------------------"
        cd /$USER/$domain || exit
        cat * > result.txt
        cat result.txt | grep $domain | grep -v - | sort | uniq > final.txt
        cat result_amass.txt >> final.txt
        cat final.txt | awk '{print $1}' > final1.txt
        echo "Number of subdomains: $(cat /$USER/$domain/final1.txt | wc -l)" # Count number of subdomains
        cat final1.txt | grep "www" > www_file
    }

    extract_ips() {
        echo ""
        echo -e "${blue}Resolve all subdomains to IP"
        echo ""
        mkdir /$USER/$domain/IP
        cat /$USER/$domain/amass.txt | awk '{print $2}' | sed 's/,/\n/g' > /$USER/$domain/IP/final_IP
        for i in $(cat /$USER/$domain/final1.txt); do host $i; done > /$USER/$domain/IP/result_IP
        cat /$USER/$domain/IP/result_IP | grep $domain | grep "has" | cut -d " " -f 4 | grep -v address | sort
        cat /$USER/$domain/IP/final_IP | sort | uniq > /$USER/$domain/IP/final_IP1
    }

    organize() {
        echo -e "${blue}ORGANIZATION"
        mkdir /$USER/$domain/tools
        mv subfinder.txt censys.txt crt.txt certspotter.txt sublist3r.txt amass.txt tools/
    }

    gathering_subs
    put_subs_together
    extract_ips
    organize

    echo "SEE LIVE DOMAINS"
    echo "-----------------------------------------------------"
    mkdir /$USER/$domain/online
    for i in $(cat /$USER/$domain/final1.txt); do ping -4 -c 1 $i ; done > /$USER/$domain/live_host
    cat /$USER/$domain/live_host | grep $domain | cut -d " " -f 2 | grep -v bytes | sort | uniq > /$USER/$domain/lastlive_host

    echo ""
    echo "See live domains"
    echo "-----------------------------------------------------"
    cat /$USER/$domain/lastlive_host | httprobe > /$USER/$domain/http_site
    cat /$USER/$domain/http_site | sort | uniq > /$USER/$domain/finall_site

    echo ""
    echo "Open live domains in Chromium"
    for i in $(cat /$USER/$domain/finall_site); do chromium $i; done 

    echo ""
    echo "Take screenshots "
    echo "----------------------------------------------------"

    cd /$USER/Downloads/EyeWitness/
    ./EyeWitness.py -f /$USER/$domain/finall_site -d /$USER/$domain/screenshots

    echo "RECOGNIZE"
    cd /$USER/$domain/online ; mv live_host lastlive_host http_site http_site online/
fi

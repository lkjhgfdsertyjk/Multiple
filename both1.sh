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

    mkdir $domain 2> /dev/null

    gathering_subs() {
        echo ""
        echo -e "${blue}GATHER SUBDOMAINS"
        echo "-------------------------------------------"
	subfinder -d $domain -nW > $domain/subfinder.txt
        python tools/Sublist3r/sublist3r.py -d $domain -o $domain/sublist3r.txt
        amass enum -active -d $domain -timeout 1 -o $domain/amass.txt   
        cat $domain/amass.txt | awk '{print $1}' > $domain/result_amass.txt
   }

    put_subs_together() {
        echo ""
        echo -e "${blue}Put all subdomains together"
        echo "---------------------------------------------"
        cd $domain
        cat * > result.txt
        cat result.txt | grep $domain | grep -v - | sort | uniq > final.txt
        cat result_amass.txt >> final.txt
        cat final.txt | awk '{print $1}' > final1.txt
        echo "Number of subdomains: $(cat final1.txt | wc -l)" # Count number of subdomains
        cat final1.txt | grep "www" > www_file
        cd ..
    }

    extract_ips() {
    	echo ""
    	echo -e "${blue}Resolve all subdomains to IP"
    	echo "---------------------------------------------"
    	cd $domain || exit
    	mkdir -p IP
    	cat amass.txt | awk '{print $2}' | sed 's/,/\n/g' > IP/final_IP
    	for i in $(cat final1.txt); do host $i; done > IP/result_IP
    	cat IP/result_IP | grep $domain | grep "has" | cut -d " " -f 4 | grep -v address | sort > IP/ips.txt
    	cat IP/final_IP | sort | uniq > IP/final_IP1
    	cd ..
    }

    organize() {
        echo -e "${blue}ORGANIZATION"
        echo "---------------------------------------------"
	cd $domain
	mkdir -p tools
        mv subfinder.txt sublist3r.txt amass.txt tools/
	cd ..
    }

    #gathering_subs
    #put_subs_together
    #extract_ips
    #organize

    see_live_domains() {
    	echo "SEE LIVE DOMAINS"
    	echo "-----------------------------------------------------"
    	mkdir $domain/online
    	for i in $(cat $domain/final1.txt); do ping -4 -c 1 $i ; done > $domain/live_host
    	cat $domain/live_host | grep $domain | cut -d " " -f 2 | grep -v bytes | sort | uniq > $domain/lastlive_host

    	echo ""
    	echo "See live domains"
    	echo "-----------------------------------------------------"
    	cat $domain/lastlive_host | httprobe > $domain/http_site
    	cat $domain/http_site | sort | uniq > $domain/finall_site
    }
    open_domain() {
    	echo ""
    	echo "Open live domains in Chromium"
    	for i in $(cat $domain/finall_site); do firefox $i; done 
    }
    screenshot() {
    	echo ""
    	echo "Take screenshots "
    	echo "----------------------------------------------------"
    	echo "%%%%%%%%%%%%%%%%%%%%"; pwd
    	cd tools/EyeWitness/Python/
    	sudo ./EyeWitness.py -f ~/Multiple/$domain/finall_site -d ~/Multiple/$domain/screenshots
    }
    recognize() {
    	echo "RECOGNIZE"
	cd $domain
	mkdir online
	pwd
	mv live_host lastlive_host http_site http_site online/
    }
    
    #see_live_domains
    #open_domain
    #screenshot
    recognize	

fi

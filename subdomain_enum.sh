#!/bin/bash

domain=$1


# if [ ! -d "$domain/recon/amass" ]
# then
#     mkdir $domain/recon/amass
# fi

#using assetfinder 
#grep what domain we want 
echo "[+] Harvesting subdomains with assetfinder..."
if [ ! -d "$domain/recon" ]
then
	mkdir $domain
	mkdir $domain/recon
fi

assetfinder $domain | grep '.$domain' | sort -u | tee -a $domain/recon/final1.txt

#using amass
#echo "[+] Double checking for subdomains with amass and subfinder..."
#passive-enum
#amass enum -passive -d $domain -rf /root/50resolvers.txt | tee -a $domain/recon/final1.txt
#subfinder -nW -d $domain -rL /root/50resolvers.txt -t 200000
#sort -u $domain/recon/final1.txt >> $domain/recon/final.txt

echo "[+] Double checking for subdomains with amass and subfinder or findomain..."
#you can specify your resolver.txt path
#or you can use this 
#resolver=$(find /root/ -type f -name '50resolvers.txt')
#-config /root/.config/amass/config.ini
amass enum -d $domain -passive | tee -a $domain/recon/final1.txt
subfinder -nW -d $domain -rL /root/50resolvers.txt -t 2000 | tee -a $domain/recon/final1.tx
findomain-linux --target $domain | tee -a $domain/recon/final1.txt
sort -u $domain/recon/final1.txt >> $domain/recon/final.txt
#rm $domain/recon/final1.txt


# subfinder -nW -d $domain -rL /root/50resolvers.txt -t 2000 | tee -a $domain/recon/final1.txt
# findomain-linux --target $domain | grep ".$domain" | tee -a $domain/recon/final1.txt
# amass enum -d $domain | tee -a $domain/recon/final1.txt
# sort -u $domain/recon/final1.txt >> $domain/recon/final.txt


echo "[+] Compiling 3rd lvl domains..."
cat $domain/recon/final.txt | grep -Po '(\w+\.\w+\.\w+)$' | sort -u >> $domain/recon/3rd-lvl-domains.txt 
for line in $(cat $domain/recon/3rd-lvl-domains.txt);do echo $line | sort -u | tee -a $domain/recon/final.txt;done


echo "[+] Probing for alive domains..."

if [ ! -d "$domain/recon/httprobe" ]
then
	mkdir $domain/recon/httprobe
fi

cat "$domain/recon/final.txt" | sort -u | httprobe -s -p https:443 | sed 's/https\?:\/\///' | tr -d ':443' | sort -u >> $domain/recon/httprobe/alive.txt

cat $domain/recon/httprobe/alive.txt
alive_subdomain=`cat $domain/recon/httprobe/alive.txt | wc -l`
echo "Total Alive subdomain found : $alive_subdomain"



echo "[+] Checking for possible subdomain takeover..."

if [ ! -d "$domain/recon/potential_takeovers" ]
then
	mkdir $domain/recon/potential_takeovers
fi

subjack -w $domain/recon/httprobe/alive.txt -t 300 -timeout 30 -ssl -c ~/go/src/github.com/haccer/subjack/fingerprints.json -v 3 >> $domain/recon/potential_takeovers/potential_takeovers1.txt
sort -u $domain/recon/potential_takeovers/potential_takeovers1.txt >> $domain/recon/potential_takeovers/potential_takeover.txt

rm $domain/recon/potential_takeovers/potential_takeovers1.txt



echo "[+] Running whatweb on compiled domains..."
for Domain in $(cat $domain/recon/httprobe/alive.txt);do

	if [ ! -d  "$domain/recon/whatweb" ];then
		mkdir $domain/recon/whatweb
	fi
	
	if [ ! -d  "$domain/recon/whatweb/$Domain" ];then
		mkdir $domain/recon/whatweb/$Domain
	fi

	if [ ! -f "$domain/recon/whatweb/$Domain/output.txt" ];then
		touch $domain/recon/whatweb/$Domain/output.txt
	fi

	if [ ! -f "$domain/recon/whaweb/$Domain/plugins.txt" ];then
		touch $domain/recon/whatweb/$Domain/plugins.txt
	fi
	
	echo "[*] Pulling plugins data on $Domain $(date +'%Y-%m-%d %T')"
	whatweb --info-plugins -t 500 -v $Domain >> $domain/recon/whatweb/$Domain/plugins.txt; sleep 3
	echo "[*] Running whatweb on $Domain $(date +'%Y-%m-%d %T')"
	whatweb -t 500 -v $Domain >> $domain/recon/whatweb/$Domain/output.txt; sleep 3
done


echo "[+] Scraping wayback data..."

if [ ! -d "$domain/recon/wayback" ]
then
	mkdir $domain/recon/wayback 
fi

cat $domain/recon/final.txt | waybackurls | tee -a  $domain/recon/wayback/wayback_output1.txt
sort -u $domain/recon/wayback/wayback_output1.txt >> $domain/recon/wayback/wayback_output.txt
rm $domain/recon/wayback/wayback_output1.txt

echo "[+] Pulling and compiling js/php/aspx/jsp/json files from wayback output..."

if [ ! -d  "$domain/recon/wayback/extensions" ]
then
	mkdir  $domain/recon/wayback/extensions
fi

for line in $(cat $domain/recon/wayback/wayback_output.txt);do
	ext="${line##*.}"
	if [[ "$ext" == "js" ]];then
		echo $line | sort -u | tee -a  $domain/recon/wayback/extensions/js.txt
	fi

	if [[ "$ext" == "json" ]];then
		echo $line | sort -u | tee -a $domain/recon/wayback/extensions/json.txt
	fi

	if [[ "$ext" == "php" ]];then
		echo $line | sort -u | tee -a $domain/recon/wayback/extensions/php.txt
	fi

	if [[ "$ext" == "aspx" ]];then
		echo $line | sort -u | tee -a $domain/recon/wayback/extensions/aspx.txt
	fi

done



echo "[+] Scanning for open ports..."

if [ ! -d "$doamin/recon/scans" ]
then
	mkdir $doamin/recon/scans
fi

#nmap -iL $doamin/recon/httprobe/alive.txt -T4 -A -oA $doamin/recon/scans/scanned.txt

for alive_domain in $(cat $domain/recon/httprobe/alive.txt);do
	nmap -T4 -A $alive_domain -oA $domain/recon/scans/alive_domain-scanned.txt
done



echo "[+] Running eyewitness against all compiled domains..."

eyewitness=$(find /root/ -type f -name 'EyeWitness.py')
python3 $eyewitness --web -f $domain/recon/httprobe/alive.txt -d $domain/recon/eyewitness --resolve --no-prompt --timeout 45 --threads 2000



# echo "[~] Running dirsearch against all alive_domain..."

# if [ ! -d "$domain/recon/dirsearch" ]
# then
# 	mkdir $domain/recon/dirsearch
# fi

# for alive_domain in $(cat $domain/recon/httprobe/alive.txt);do
# 	echo "[~] Running dirsearch on this $alive_domain $(date +'%Y-%m-%d %T') "
# 	dirsearch=$(find /root/ -type f -name 'dirsearch.py')
# 	python3 $dirsearch -u "https://$alive_domain" -w /root/tools/SecLists/Discovery/Web-Content/common.txt -i 200,204,400,403 -x 500,502,429 -f -e php,ini,js,aspx,asp --threads 2000 -r -R 7 --full-url >> $domain/recon/dirsearch/$alive_domain-result.txt	
# done


#using ffuf

if [ ! -d "$domain/recon/ffuf" ]
then
	mkdir $domain/recon/ffuf
fi

echo "[~] Running ffuf against all alive_domain..."

for alive_domain in $(cat $domain/recon/httprobe/alive.txt);do
	echo "[~] Running ffuf on this $alive_domain $(date +'%Y-%m-%d %T') "
	ffuf -c -w /root/tools/SecLists/Discovery/Web-Content/common.txt -u https://$alive_domain/FUZZ -t 2000 -recursion -recursion-depth 5 -v | tee -a $domain/recon/ffuf/$alive_domain-result.txt
done


 # ffuf -c -w /root/tools/SecLists/Discovery/Web-Content/common.txt -fc 500,501,503,429 -D -e php,asp,aspx,jsp,zip,rar,tar -od test -o reformertech.txt -u https://reformertech.com/FUZZ -maxtime-job 40 -recursion -recursion-depth 2


echo "[~] Running ParamSpider and gf against all alive_domain..."


if [ ! -d "$domain/recon/ParamSpider" ]
then
	mkdir $domain/recon/ParamSpider
fi


if [ ! -d "$domain/recon/gf" ]
then
	mkdir $domain/recon/gf
fi

for alive_domain in $(cat $domain/recon/httprobe/alive.txt);do
	paramspider=$(find /root/ -type f -name 'paramspider.py')
	python3 $paramspider  -d $alive_domain -l high -e jpg,png,svg,js,css | sort -u >> $domain/recon/ParamSpider/$alive_domain-filter-parameter.txt
	python3 $paramspider -d $alive_domain -l high | sort -u >> $domain/recon/ParamSpider/$alive_domain-no-filter-parameter.txt

	if [ ! -d "$domain/recon/gf/$alive_domain" ]
	then
		mkdir $domain/recon/gf/$alive_domain
	fi

	gf sqli $domain/recon/ParamSpider/$alive_domain-filter-parameter.txt | sort -u >> $domain/recon/gf/$alive_domain/filter-parameter-sqli.txt
	gf sqli $domain/recon/ParamSpider/$alive_domain-no-filter-parameter.txt | sort -u >> $domain/recon/gf/$alive_domain/not-filter-parameter-sqli.txt

	
done





# massdns -r resolve_file.txt -t A(record-type) -o S subdomains-file.txt -w output-file.txt


# sed 's/A.*//' livehost.txt | sed 's/CN.*//' | sed 's/\..$//'> live_domains.txt

# sed 's/A.*//' livehost.txt		Removes everything after A
# sed 's/CN.*//'				Removes everything after CN
# sed 's/\..$//'				Removes . at the end of domains







# degoogle_hunter
# https://github.com/six2dez/degoogle_hunter
# https://github.com/blechschmidt/massdns
# https://www.youtube.com/watch?v=C_8WvR1rKpM



#Gospider sahaje js file found kora jay 

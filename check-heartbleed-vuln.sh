# using sslscan to find or check Heartbleed vuln
echo "          *** Checking for heartbleed    ***     "

sslscan $target >> ssloutput.txt && cat ssloutput.txt | grep "to heartbleed" | tee sslscan-output.txt

sleep 15

sudo rm -rf ssloutput.txt
sleep 2
sudo mv sslscan-output.txt $mypwd/$target/ 

sleep 7

# emoji to notify about end
figlet -f slant.tlf "DONE . ."

echo -e "\e[96m(\_/)"
echo -e "\e[96m(* *) your output saved to >>\e[91m~/$target"
echo -e "\e[96m \w/ @ webcipher101"

sleep 10

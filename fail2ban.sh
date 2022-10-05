#!/bin/bash

#help function
function help {
	echo "==== SysAdmin tool ===="
	echo ""
	echo "This tool will help you to browse a log file."
	echo ""
	echo -e "\033[31m You MUST DEFINE a log file to use with -f\E[0m" #31m : RED COLOR
	echo " -f file"
	echo ""
	echo " Various options are available :"
	echo " -h to display the help text (this one)"
	echo " -l to list event(s) for a specified IP address"
	echo "  -l X.X.X.X"
	echo " -L to list all uniq IP addresses of the log file"
	echo " -I to list iptables events"
	echo "  -I all / -I found / -I ban / -I unban"
	echo " -B to list ban events"
	echo " -S to list IP addresses sorted by events"
	echo "  -S all / -S found / -S ban (all ban events) / -S unban"
	echo ""
	echo -e "The syntax \033[31mMUST BE ./fail2ban.sh -f file [OPTION]\E[0m"
	echo " ./fail2ban.sh -f myLog.log -l 127.0.0.1"
	echo " ./fail2ban.sh -f myLog.log -I ban"
	echo ""
	echo "Each result will be printed on a text file."
	echo -e "MAKE SURE you have \033[31msufficient rights\E[0m to write on your directory !"
}

#log file check to call first
function target_file {
	if [ ! -f "$1" ]; then
		echo -e "\033[31mNO LOG\E[0m" #31m : RED COLOR
		exit 0
	fi
}

#list event(s) for a specified IP@
function list_events_ip {
	target_file $1
	echo "Log OK" ; echo "Work in progress ..."
	grep -E "$2" "$1" > specified_ip.txt
	echo "Done : specified_ip.txt"
}

#list all IP@ of a log file
function list_all_ip {
	target_file $1
	echo "Log OK" ; echo "Work in progress ..."
	grep -Ewo '([0-9]{1,3}\.){3}([0-9]){1,3}' "$1" | sort -un > all_ip.txt
	echo "Done : all_ip.txt"
}

#list all IP@ for a specified event
function list_iptables_events {
	target_file $1
	echo "Log OK" ; echo "Work in progress ..."

	if [ "$2" == "" ]; then
		echo -e "\033[31mNO ARG\E[0m" ; exit 0

	elif [ "$2" == "all" ]; then
		grep -i 'ssh-iptables' "$1" > ssh_Aevent.txt
		echo "Done : ssh_Aevent.txt"

	elif [ "$2" == "found" ]; then
		grep -iw "$2" "$1" > ssh_Fevent.txt
		echo "Done : ssh_Fevent.txt"

	elif [ "$2" == "ban" ]; then
		grep -iw "$2" "$1" > ssh_Bevent.txt
		echo "Done : ssh_Bevent.txt"

	elif [ "$2" == "unban" ]; then
		grep -iw "$2" "$1" > ssh_Uevent.txt
		echo "Done : ssh_Uevent.txt"

	else
		echo -e "\033[31mUNKNOWN ARG\E[0m" ; exit 0
	fi
}

#list all ban events
function list_ban_events {
	target_file $1
	echo "Log OK" ; echo "Work in progress ..."

	grep -iw 'ban' "$1" > ban_event.txt
	echo "" ; echo "" >> ban_event.txt
	echo "----------ALREADY BANNED IP ADDRESSES-----------------" >> ban_event.txt
	echo "" ; echo "" >> ban_event.txt
	grep -iw 'banned' $1 >> ban_event.txt

	echo "Done : ban_event.txt"
}

#list IP@ sorted by a specified event
function list_ip_sorted {
	target_file $1
	echo "Log OK" ; echo "Work in progress ..."

	if [ "$2" == "" ]; then
		echo -e "\033[31mNO ARG\e[0m" ; exit 0


	elif [ "$2" == "all" ]; then
		grep -Eow '([0-9]{1,3}\.){3}([0-9]{1,3})' "$1" | sort | uniq -c | sort -nr > sort_All.txt
		echo "Done : sort_All.txt"

	elif [ "$2" == "found" ]; then
		grep -Eoiw 'found ([0-9]{1,3}\.){3}([0-9]{1,3})' "$1" | cut -d " " -f 2 | sort | uniq -c | sort -nr > sort_Found.txt
		echo "Done : sort_Found.txt"

	elif [ "$2" == "ban" ]; then
		grep -Eoiw 'ban ([0-9]{1,3}\.){3}([0-9]{1,3})' "$1" | cut -d " " -f 2 | sort | uniq -c | sort -nr > sort_Ban.txt

		echo "" ; echo "" >> sort_Ban.txt
		echo "-----------------Already banned IP addresses-----------------" >> sort_Ban.txt
		echo "" ; echo "" >> sort_Ban.txt

		grep -iw 'banned' "$1" | cut -d "]" -f 3 | cut -d " " -f 2 | sort | uniq -c | sort -nr >> sort_Ban.txt
		echo "Done : sort_Ban.txt"

	elif [ "$2" == "unban" ]; then
		grep -Eoiw 'unban ([0-9]{1,3}\.){3}([0-9]{1,3})' "$1" | cut -d " " -f 2 | sort | uniq -c | sort -nr > sort_Unban.txt
		echo "Done : sort_Unban.txt"

	else
		echo -e "\033[31mUNKNOWN ARG\e[0m" ; exit 0
	fi
}




###  MAIN

clear

if [ "$#" == "0" ]; then
	help #display automatically the help
fi

while getopts "hf:l:LIBS" arg; do       # ./fail2ban.sh -arg . .
	echo
	case $arg in #2 = log_file // #4 optionnal arg
		f)
			target_file $2
			;;
		h)
    			help
    			;;
		l)
			list_events_ip $2 $4
			;;
		L)
			list_all_ip $2
			;;
		I)
			list_iptables_events $2 $4
			;;
		B)
			list_ban_events $2
			;;
		S)
			list_ip_sorted $2 $4
			;;
   		*)
    			echo "./fail2ban.sh -h for help"
    			;;
	esac
done

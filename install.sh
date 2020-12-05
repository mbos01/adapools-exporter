#!/bin/bash

#must run with sudo
if [[ "$EUID" -ne 0 ]]; then
        echo "Please run with sudo"
        exit
fi

#check if adapools-exporter service already exists
if systemctl list-units --full -all | grep "adapools-exporter"; then
        echo -e "\e[1;31m adapools-exporter service exists! \e[0m"
	#exit
fi

#determine location
while [[ -z "$install_path" ]]
do
        read -p "Where do you wish to install? " installp
        if [[ ! -d "$installp" ]]; then
                echo -e "\e[1;31m $installp does not exist! \e[0m"
        else
                install_path=$installp
        fi
done

echo -e "\n"

#determine user
while [[ -z "$install_user" ]]
do
        read -p "What user do you want to run the script with? " useracc
        if [[ -z "$useracc" ]]; then
                echo -e "\e[1;31m Please provide a username. \e[0m"
        elif [[ ! $useracc =~ ^[A-Za-z0-9_.-]+$ ]]; then
                echo -e "\e[1;31m You cannot use special characters. \e[0m"
        elif ! id -u "$useracc" >/dev/null 2>&1; then
                        read -p "User does not exist, create a new account? (y/n)" create_new
                        if [[ $create_new =~ "y" ]]; then
                                useradd -r -s /bin/false $useracc
                                install_user=$useracc
                        fi
        else
                                install_user=$useracc
        fi
done

echo -e "\n"

#determine python version
echo -e "Available Python versions:\n"

for i in /usr/bin/python*; do
        re="python$|python[[:digit:]]$"
        if [[ $i =~ $re ]]; then
                arr=( "${arr[@]}" $i );
        fi
done

if [[ ${#arr[@]} -eq 0 ]]; then
	echo -e "\e[1;31m Could not find Python! \e[0m"
	exit
fi

PS3=$'\n'"Please choose version: "

select python in "${arr[@]}"
do
    case $python in
        *)
                if [[ $REPLY -gt ${#arr[@]} ]]; then
                        echo "$RESULT is not a valid option."
                else
                        break
                fi
        ;;
    esac
done

echo -e "\n"

#determine pool id
while [[ -z "$pool_id" ]]
do
        read -p "What's your pool id? " p_id
        if [[ -z "$p_id" ]]; then
                echo -e "\e[1;31m Please provide a pool id. \e[0m"
        elif [[ ! $p_id =~ ^[A-Za-z0-9]+$ ]]; then
                echo -e "\e[1;31m Only letters and numbers. \e[0m"
        else
                pool_id=$p_id
        fi
done

#start installation

#create app directory and change owner
mkdir "$install_path/adapools-exporter"
chown $install_user:$install_user "$install_path/adapools-exporter"

#download script
wg_output=$(wget -O "$install_path/adapools-exporter/adapools-exporter.py" https://raw.githubusercontent.com/mbos01/adapools-exporter/main/adapools-exporter.py)

if [ $? -ne 0 ]; then
	echo -e "\e[1;31m Could not download adapools-exporter.py. \e[0m"
	rm -R "$install_path/adapools-exporter"
	exit
fi

#add pool id
sed -i "s/!!!!!YOUR-POOL-ID!!!!!/$pool_id/" "$install_path/adapools-exporter/adapools-exporter.py"

#install systemd service
bash -c "cat << 'EOF' > /etc/systemd/system/adapools-exporter.service
[Unit]
Description=Adapools exporter
After=network-online.target

[Service]
Type=simple
User=$install_user
WorkingDirectory=$install_path/adapools-exporter
ExecStart=$python $install_path/adapools-exporter/adapools-exporter.py
StandardOutput=null
Restart=always

[Install]
WantedBy=multi-user.target
EOF"

#reload, enable, start
systemctl daemon-reload
systemctl enable adapools-exporter.service
systemctl start adapools-exporter.service

#prometheus job
p_job="- job_name: adapools-exporter\n"
p_job="$p_job    scrape_interval: 15s\n"
p_job="$p_job    metrics_path: /metrics/\n"
p_job="$p_job    static_configs:\n"
p_job="$p_job        - targets: ['127.0.0.1:8000']\n"

#check if prometheus.yaml is available
if [[ -e "/etc/prometheus/prometheus.yaml" ]]; then
	while true
	do
 		read -r -p "Prometheus config detected. Do you want to add a new job? (Y/N) " input

 		case $input in
     		[yY][eE][sS]|[yY])
			echo -e $p_job >> /etc/prometheus/prometheus.yaml
			echo "Adapools-exporter job was added to prometheus config."
			break
 		;;
     		[nN][oO]|[nN])
 			echo "Adapools-exporter job was not added."
 			break
        	;;
     		*)
 			echo -e "\e[1;31m Invalid input... Only (Y/N) \e[0m"
 		;;
 		esac
	done
else
	echo -e "\nNo prometheus config found. Please add a new job manually."
	echo -e "\n$p_job"
fi



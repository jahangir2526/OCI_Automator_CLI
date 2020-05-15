#!/usr/bin/env bash
cd `dirname ${BASH_SOURCE[0]}`
cd ..

## Variables
adb_temp_file="config/.adb_temp.conf"
resource_file="config/resources.conf"


################################### FUNCTIONS ######################################
help_menu()
{
        echo ""
        echo "Syntax:"
        echo "./adb.sh [-h]"
	echo "./adb.sh <config_section> <OPERATION>"
        echo ""
        echo "Example:"
        echo "./adb.sh myadb1-prod START # to start the adb"
        echo "./adb.sh myadb1-prod STOP  # to stop the adb"
        echo "./adb.sh myadb1-prod OCPU <cpu-core-count> # to scale cpu to given number"
        echo "./adb.sh myadb1-prod STATUS # to check the status of adb"
	echo ""
	echo "./adb.sh myadb1-prod STATUS|grep -i lifecycle-state|gawk -F \":\" '{print \$2}'"
        echo ""
}

initialize()
{
	echo "" > $adb_temp_file
}

resource_param_generator()
{
	input=$resource_file
	flag=0
	echo "# sample config file auto generated" > $adb_temp_file
	while IFS= read -r line
	do
		if [[ $flag == 1 ]] && [[ $line == "["* ]]; then
			flag=0
		fi

		if [[ $flag == 1 ]]; then
			echo $line >> $adb_temp_file
		fi

		if [[ $line == "[$1"* ]]; then
			flag=1;
		fi

		done < "$input"
}

logger()
{
	bin/logger.sh $*
}

################################## MAIN ###################################
# checking the help flag
if [ "$1" = "-h" ]; then
        help_menu
        exit 0;
fi

# Initialize
initialize

# generating the conf file
resource_param_generator $1
source $adb_temp_file
# action based on operations
case $2 in
	"start" | "START")
		logger "[$1]  Starting";
		oci db autonomous-database start --autonomous-database-id $ADB_OCID
		;;

	"stop" | "STOP")
		logger "[$1] Stopping";
		oci db autonomous-database stop --autonomous-database-id $ADB_OCID	
		;;

	"ocpu" | "OCPU")
		logger "[$1] Allocating OCPU to $3";
	oci db autonomous-database update --cpu-core-count $3 --autonomous-database-id $ADB_OCID	
		;;

	"status" | "STATUS")
		logger "[$1] Checking Status";
		oci db autonomous-database get --autonomous-database-id $ADB_OCID	
		;;

	*) 	echo "Invalid operations. Please check syntax";
		help_menu;
esac


#!/usr/bin/env bash
cd `dirname ${BASH_SOURCE[0]}`
cd ..

## Variables
oac_temp_file="config/.oac_temp.conf"
resource_file="config/resources.conf"


################################### FUNCTIONS ######################################
help_menu()
{
        echo ""
        echo "Syntax:"
        echo "./oac.sh [-h]"
	echo "./oac.sh <config_section> <OPERATION>"
        echo ""
        echo "Example:"
        echo "./oac.sh myoac1-prod START # to start the oac"
        echo "./oac.sh myoac1-prod STOP  # to stop the oac"
        echo "./oac.sh myoac1-prod OCPU <cpu-core-count> # to scale cpu to given number"
        echo "./oac.sh myoac1-prod STATUS # to check the status of oac"
	echo ""
	echo "./oac.sh myoac1-prod STATUS|grep -i lifecycle-state|gawk -F \":\" '{print \$2}'"
        echo ""
}

initialize()
{
	echo "" > $oac_temp_file
}

resource_param_generator()
{
	input=$resource_file
	flag=0
	echo "# sample config file auto generated" > $oac_temp_file
	while IFS= read -r line
	do
		if [[ $flag == 1 ]] && [[ $line == "["* ]]; then
			flag=0
		fi

		if [[ $flag == 1 ]]; then
			echo $line >> $oac_temp_file
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
source $oac_temp_file
# action based on operations
case $2 in
	"start" | "START")
		oci analytics analytics-instance start --analytics-instance-id $OAC_OCID
		logger "[$1]  Starting";
		;;

	"stop" | "STOP")
		oci analytics analytics-instance stop --analytics-instance-id $OAC_OCID
		logger "[$1] Stopping";
		;;

	"ocpu" | "OCPU")
		oci analytics analytics-instance  scale --capacity '{"capacityType": "OLPU_COUNT", "capacityValue": '$3'}' --analytics-instance-id $OAC_OCID
		logger "[$1] Allocating OCPU to $3";
		;;

	"status" | "STATUS")
		oci analytics analytics-instance get --analytics-instance-id $OAC_OCID
		logger "[$1] Checking Status";
		;;

	*) 	echo "Invalid operations. Please check syntax";
		help_menu;
esac


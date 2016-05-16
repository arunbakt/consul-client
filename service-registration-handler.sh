#!/usr/local/bin/bash
declare -A CONFIG_WATCHES
declare -r DEAFULT_CONSUL_AGENT_HOST="192.168.99.102"
declare -r DEFAULT_CONSUL_AGENT_PORT="8500"
declare -r PROCESS_UNDER_WATCH_FILES_DIR="/tmp/processes_under_watch"

declare -a service_names;

process_services() {	
	initialize &&
	cleanup_unregistered_processes &&
	populate_process_entries &&
	register_new_processes
}

initialize() {
	
	if [ ! -d "$PROCESS_UNDER_WATCH_FILES_DIR" ]; then
		printf "%s\n" "Creating a temporary directory consul_watch_processes..."
		mkdir $PROCESS_UNDER_WATCH_FILES_DIR;	
	fi
		
}

populate_process_entries() {
	
	
	for process_file in "$PROCESS_UNDER_WATCH_FILES_DIR"/*; do
		if [ -e $process_file ]; then
			local file_name=`basename $process_file`
			local process_pid=`cat $process_file`
			printf "%s%d\n" "Process file name: $process_file with pid:" $process_pid
			CONFIG_WATCHES[$file_name]=$process_pid	
		fi
	done
}

register_new_processes() {
	for sn in "${service_names[@]}"; do
		printf "%s\n" "$sn is currently being watched?  ${CONFIG_WATCHES[$sn]}"
		if [ -z "${CONFIG_WATCHES[$sn]}" ]; then 
			start_watching $sn
		else
			printf "%s\n" "Already watching service $sn"
		fi			
	done
}

start_watching() {
	local service_to_watch="$1"
	if [ !"consul"="$service_to_watch" ]; then
		printf "%s\n" "Starting to watch $service_to_watch" 
		touch $PROCESS_UNDER_WATCH_FILES_DIR/$service_to_watch &&
		consul watch -http-addr="$DEAFULT_CONSUL_AGENT_HOST":"$DEFAULT_CONSUL_AGENT_PORT" -type keyprefix -prefix "$service_to_watch" ./key-value-update.sh &
		echo $! > $PROCESS_UNDER_WATCH_FILES_DIR/$service_to_watch
	fi	
}

cleanup_unregistered_processes() {
	for service_under_watch in "$PROCESS_UNDER_WATCH_FILES_DIR"/*; do
		
		if [ -e $service_under_watch ]; then
			local file_name=`basename $service_under_watch`
			local service_pid=`cat $service_under_watch`
			is_value_present_in_array $file_name
			process_entry_is_a_running_service=$?
			printf "%s %d\n" "Checking if a process with filename $file_name exists? $process_entry_is_a_running_service"
			if [ ! $process_entry_is_a_running_service -eq 0 ]; then
				printf "%s\n" "Stopping consul watch for service $file_name"
				kill -9 $service_pid > /dev/null 2>&1
				rm -f $service_under_watch 
				printf "%s\n" "Successfully stopped consul watch for service $file_name"
			elif ! kill -0 $service_pid  > /dev/null 2>&1 ; then
				printf "%s\n" "Unremoved file marker with pid that no longer exists. Removing $service_under_watch"
				rm -f $service_under_watch 
			fi
		fi
		
	done
}

is_value_present_in_array(){
	local value_to_check="$1"
	for value in ${service_names[@]}; do
		if [ $value = $value_to_check ]; then
			return 0
		fi
	done
	return 1
}

# set -x
if [ -z "$CONSUL_HOST_AGENT" ]; then
	CONSUL_HOST_AGENT=$DEAFULT_CONSUL_AGENT_HOST
fi

while read -r input_data; do
	
	printf "%s %d\n" "Service Registration Process Invoked. Current pids underwatch " "${CONFIG_WATCHES[@]}"
	
	if [[ -n $input_data ]]; then 
		
		printf "\n%s\n"	"$input_data";	
		i=0;
		while read -r service_name; do
			service_names[i]="$service_name"
			let i=i+1;
		done  < <(jq -r '. | keys | .[]'  <<-EOF 
			$input_data
		EOF
		)

		process_services 
		printf "\n%s\n" "The size of the input event array is :"${#service_names[@]}
		
	 fi
	 
done
# set +x

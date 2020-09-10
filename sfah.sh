#!/bin/bash --noprofile
# Copyright (c) 2019 Moles & Halitosis
# Oct 2019 - choose a folding slot with FOLDSLOT
# Calculates rates and shows current percent completion
# of f@h client in the fah directory

# the regular expression pattern for the work unit
WORKUNIT=WU0.
# The slot you want to monitor
FOLDSLOT=${FOLDSLOT:-FS01}
# The F@H log file
FAHLOG=${FAHLOG:-/home/yourusername/yourFAHdir/log.txt}
declare -a fahStatus fahRate

#set -x

current_datetime(){
	TZ=UTC date +'%H:%M:%S'
}

change_datetime_to_seconds(){
	local dt=$1		# grab the datetime
	local dth dtm dts	# hour min sec holders
	local dtt		# total time in sec

	dth=$(echo $dt | cut -s -d: -f1 | sed 's/^0//')
	dtm=$(echo $dt | cut -s -d: -f2 | sed 's/^0//')
	dts=$(echo $dt | cut -s -d: -f3 | sed 's/^0//')

	dtt=$(($dth * 3600 + $dtm * 60 + $dts))

	echo $dtt
}

most_recent_points(){
	grep ":${FOLDSLOT}:Final credit estimate" "$FAHLOG" | tail -n1 | tr ',' ':' | cut -s -d: -f1-3,7
	# do awk stuff here, if you can
}

current_fahstatus(){
	local line n=0
	for line in $(grep ":$WORKUNIT:$FOLDSLOT:....:Completed" "$FAHLOG" | tail -n 5 | tr '()' '::' | cut -s -d: -f1-3,8)
	do
		fahStatus[$n]="$line":"$(change_datetime_to_seconds $line)"
		echo Were $line $(change_datetime_to_seconds $line)
		: $(( n++ ))
	done
}

fold_rate(){
	lastRow=$(( ${#fahStatus[*]} - 2 ))
	for row in $(seq 0 $lastRow)
	do

		iT=$(echo ${fahStatus[$row]} | cut -s -d: -f5)
		jT=$(echo ${fahStatus[((row + 1))]} | cut -s -d: -f5)
		if [ $iT -lt $jT ]
		then
			fahRate[(( $row + 1 ))]=$(( jT - iT ))
			tT=$((tT + fahRate[(($row + 1))]))
		else
			echo "row $row:" $iT $jT ${fahStatus[$row]} ${fahStatus[(($row + 1))]} >&2
		fi
	done
	tT=$(( $tT / (${#fahStatus[*]} - 1) ))
}

DT=$(current_datetime)

current_fahstatus
fold_rate
echo "Now " $DT '   ' $(change_datetime_to_seconds $DT)
#echo fahStatus length: ${#fahStatus[@]}

echo $(echo ${fahStatus[4]}|cut -s -d: -f1-3) $(echo ${fahStatus[4]}|cut -s -d: -f4) Avg: ${tT}s
most_recent_points

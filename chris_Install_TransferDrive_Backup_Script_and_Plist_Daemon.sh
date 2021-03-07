#!/bin/bash

#### Christian Orellana
#### February 2020


#### Transfer Drive Plist Launch Daemon

#### FUNCTIONS

## Uninstall all files
uninstall_TransferBackup_Daemon() {

	sudo launchctl unload -w /Library/LaunchDaemons/com.location.Chris.TransferDriveBackup.plist

	rm -rf /Library/LaunchDaemons/com.location.Chris.TransferDriveBackup.plist

	rm -rf /Library/Scripts/Pratt/location_it_chris_TransferDriveBackup.sh

	rm -rf /Library/Logs/location_it_chris_TransferDriveBackup.log

}

## Install bash script
install_bash_script() {

	mkdir /Library/Scripts/location
	touch /Library/Scripts/location/location_it_chris_TransferDriveBackup.sh
cat << 'EOF' >> /Library/Scripts/location/location_it_chris_TransferDriveBackup.sh
#!/bin/bash

#### Christian Orellana
#### February 2020

#### Transfer Drive Backup 


### VARIABLES
# transferDrivefiles='/Users/admin/Desktop/TranferTest'
# transferDriveBackup='/Users/admin/Desktop/TransferBackup/'

transferDrivefiles='/Volumes/LaCie48/shares/transfer'
transferDriveBackup='/Volumes/LaCie48/TransferBackup/'
date=$(/bin/date +"%A_%b_%d_%Y")
log=/Library/Logs/location_it_chris_TransferDriveBackup.log


### FUNCTIONS

moveTransferFiles() {

	echo "Starting backup of transfer drive $date" >> $log
	## Set permission of all transfer drives to admin
	chown -R admin:wheel $transferDrivefiles; chmod -R 777 $transferDrivefiles
	echo "Changing permissions of inside Transfer File for admin" >> $log
	## Make a new folder with today's current date in Specified Back up location above
	mkdir $transferDriveBackup/$date
	echo "Created new folder for $date inside $transferDriveBackup" >> $log
	## Move all files to the Back up Folder
	mv $transferDrivefiles/* $transferDriveBackup/$date/
	echo "Moving all transfer drive files to $transferDriveBackup$date folder" >>$log
	## Make sure all moved files are owned by admin
	chown -R admin:wheel $transferDriveBackup/$date/; chmod -R 777 $transferDriveBackup/$date/
	echo "Resetting permissions for back up folder for admin use" >> $log

}

checkBackup_Exists() {

	## Check if the back up folder exists with content
	if [[ "$(ls -A $transferDriveBackup/$date/)" ]]; then
		echo "Back up completed for $date" >> $log
	else
		echo "There was no back up made to $date. Please check transfer Drive, possible loss of data, or there were no files to backup." >> $log
	fi

}


### RUN CODE
moveTransferFiles
checkBackup_Exists

exit 0
EOF

	chown admin:wheel /Library/Scripts/location/location_it_chris_TransferDriveBackup.sh
	chmod +x /Library/Scripts/location/location_it_chris_TransferDriveBackup.sh

}

install_daemon() {

	touch /Library/LaunchDaemons/com.location.Chris.TransferDriveBackup.plist

cat << 'EOF' >> /Library/LaunchDaemons/com.location.Chris.TransferDriveBackup.plist
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
	<dict>
		<key>Label</key>
		<string>com.location.Chris.TransferDriveBackup</string>
		<key>Program</key>
		<string>/Library/Scripts/location/location_it_chris_TransferDriveBackup.sh</string>
		<key>StartCalendarInterval</key>
		<dict>
			<key>Hour</key>
			<integer>18</integer>
			<key>Weekday</key>
			<integer>7</integer>
		</dict>
	</dict>
</plist>
EOF

	chown root:wheel /Library/LaunchDaemons/com.location.Chris.TransferDriveBackup.plist
	chmod 644 /Library/LaunchDaemons/com.location.Chris.TransferDriveBackup.plist
	launchctl load -w /Library/LaunchDaemons/com.location.Chris.TransferDriveBackup.plist

}

### RUN CODE

uninstall_TransferBackup_Daemon
install_bash_script
install_daemon

exit 0
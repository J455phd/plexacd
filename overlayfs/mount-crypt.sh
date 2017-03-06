#!/bin/bash
# Mount ACD using rclone and overlayfs
# Import common functions
source /opt/plexacd/plexacd.func
# Import functions
source /opt/plexacd/plexacd.conf

# Mount Functions

unmount_mediadir() {
# Unmount the plex acd mounts
if mountpoint -q $MEDIADIR; then 
	log "Unmounting $MEDIADIR"
	$fusermount -u $MEDIADIR
	if [ $? -eq 0 ]; then
 		log "Failed to unmount $MEDIADIR... Retrying with force"
 	else
		$fusermount -uz $MEDIADIR
 		log "$MEDIADIR removed with force"
 	fi
else
	log "$MEDIADIR already unmountpoint"
fi
}
unmount_acdcrypt() {
if mountpoint -q $ACDCRYPT; then
  log "Unmounting $ACDCRYPT"
  $fusermount -u $ACDCRYPT
  if [ $? -eq 0 ]; then
    log "Failed to unmount $ACDCRYPT... Retrying with force"
  else
    $fusermount -uz $ACDCRYPT
    log "$ACDCRYPT removed with force"
  fi
else
  log "$ACDCRYPT already unmountpoint"
fi
}

mount_acdcrypt() {
# Mount the acd via rclone using rclone crypt
log "Mounting $ACDCRYPT"
$rclone mount \
    --read-only \
    --allow-non-empty \
    --allow-other \
    --buffer-size 150M \
    --quiet \
    $REMOTENAME: $ACDCRYPT &
	if [ $? -eq 0 ]; then
		log "Mounted $ACDCRYPT successfully."
	else
		log "Mount of $ACDCRYPT failed"
		exit 1
	fi
	
}

mount_mediadir() {
# Mount the local / remote dirs into a overlay filesystem
# Lowerdir is read-only (ACD), the upper dir is the write local dir, the work dir is used by overlay
mount -t overlay overlay -o lowerdir=$ACDCRYPT,upperdir=$LOCALDIR,workdir=$WORKDIR $MEDIADIR
if [ $? -eq 0 ]; then
  log "Mounted $MEDIADIR successfully"
  else
  log "Failed to mount overlayfs of $LOCALDIR and $ACDCRYPT. please retry"
fi

}

main() {
    lock $PROGNAME \
        || eexit "Only one instance of $PROGNAME can run at one time."
		
		logsetup
		#Unmounts
		unmount_mediadir
		unmount_acdcrypt
		#Mounts
		mount_acdcrypt
    sleep 10
		mount_mediadir

		rm $lock_file
}

# Execute main function, will provide logging
main

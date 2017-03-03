# Plex Scripts / Setup for ACD

Running your own Plex Cloud with rclone, amazon cloud drive with either unionfs or overlayfs. I've also complied a custom kernel with fuse changes


### Prerequisites

What things you need to install the software and how to install them

```
* Ubunutu / Debian - For custom kernel to work
* Fully setup plex / rclone latest beta version
* Mount points for your local data / acd-crypt 
```

### About

You have have a few options available to you, I have provided scripts for both UnionFS / OverlayFS (requires kernel 3.18+), 
I've also compiled a custom kernel from source with fuse tuning.

### Installing / Deployment

To install you need to pull this git repo, you then can choose between UnionFS or OverlayFS
If you want OverlayFS you need kernel 3.18+, you can follow my kernel install below prior to running any scripts.

```
cd /tmp
git clone https://github.com/jaketame/scripts.git plexacd/
cd /tmp/plexacd
cp /tmp/plexacd/UnionFS or OverlayFS to /opt/plexacd/
cd /opt/plexacd
chmod +x *.sh
Amend plexconf.conf with your relevant paths
Copy sysctl.conf to /etc/sysctl.conf - Please ensure you verify no existing parameters exist, if this is a fresh install there won't be
```

Once you have the scripts locally update crontab.

Required

```
@reboot /opt/plexacd/mount-crypt.sh
```

You have two options for uploading to acd

Option 1 - Upload files to cloud based on local filesystem free space

```
*/5 * * * * /opt/plexacd/disk-check.sh
```

Option 2 - Upload files every 6 hours

```
0 */6 * * * /opt/plexacd/upload-cloud.sh
```

Optional - Run mount-check every 5 minutes to verify mount is still online Not needed as rclone mount is fairly stable

```
*/5 * * * * /opt/plexacd/check-mount.sh
```

### Custom Kernel

This kernel has been complied from source and includes overlayfs and tuning changes to fuse, you can view more here
https://jaketame.co.uk/kernel/

```
Once you have git pulled the repo, you can install the custom kernel either version 3.18.48 or 4.4.52
cd kernel
cd 4.4.52
dpkg -i linux-*.deb
reboot
uname -a # Verify new kernel
```

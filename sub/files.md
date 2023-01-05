# Work with files and filesystems

## find

```bash
# Find large files, do not descend into other filesystems
find . -xdev -size +500M -exec du -m {} \; | sort -nr
# Find large directories
find . -type d -exec du -sm {} \; | sort -nr | head -10
# Find files with no owner or no group
find . \( -nouser -o -nogroup \) -print
# Find world-writable files
find . -perm -o+w \( -type d -or -type f \) -exec ls -ld {} \;
# Find files with suid or sgid bit
find . -perm +6000 -type f -exec ls -ld {} \;
```

## lsof

```bash
# Check for processes with open files under foo directory
lsof +D /usr/local/foo
```

## tar

tar(1) can be utilized to copy a directory (and preserve permissions, ownership, and links)

**NB**: to preserve complete directory ownership, permissions, and timestamps, the operation should be run as root

### Copy a directory locally

```bash
# Copy the current working directory to /tmp/foo
tar cf - . | (cd /tmp/foo && tar xf -)
# Copy the local 'rman' directory to /fuz/rman
tar cf - rman | (cd /fuz && tar xf -)
```

### Create and push tarball over SSH

```bash
# Run from the host that contains the content to be tarred up
tar cf - /dbatools | ssh foo@host.local "cat > /san/bkup-area/dbatools.tar"
```

### Create and pull a tarball over SSH

```bash
# Run from the host that will house the finished tarball
ssh foo@host.local "tar cf - /dbatools" > /san/bkup-area/dbatools.tar
# Or do the following to expand the tarball
ssh foo@host.local "cat /san/bkup-area/dbatools.tar" | tar xf -
```

### Copy a directory over SSH

```bash
tar cf - /some/dir | ssh baz@somewhere 'tar xf -'
```

## rsync

```bash
# SSH sync, remove target files that don't exist in source
rsync -av --delete source_dir/ someone@baz.local:/target_dir
```

## Logical volumes and XFS

```bash
# Create logical volume
lvcreate -L10G -n lvfoo uservg00
# Format (after mounting, use restorecon -R on directory)
mkfs.xfs /dev/mapper/uservg00-lvfoo
# Grow logical volume and filesystem
lvresize -L+50G /dev/mapper/uservg00-lvfoo
xfs_growfs /dev/mapper/uservg00-lvfoo
```

Shrinking a logical volume with XFS is not possible, but there is a workaround:

1. Create a new LV and filesystem
2. Migrate all files there
3. Clean up the old LV and filesystem in order to reclaim VG space

```bash
# Create a new, smaller LV and filesystem,
# and mount it to a temp directory
lvcreate -L2G -n lvbaz uservg00
mkfs.xfs /dev/mapper/uservg00-lvbaz
mount /dev/mapper/uservg00-lvbaz /tmp/baz-boo
# Correctly copy the old directory contents
# to the temp directory AS ROOT
cd /usr/local/thingies
tar cf - . | (cd /tmp/baz-boo && tar xf -)
# Clean up the old stuff (BE CAREFUL!)
umount /usr/local/thingies
lvremove /dev/mapper/uservg00-lvold
# Mount the new, smaller filesystem
umount /tmp/baz-boo
mount /dev/mapper/uservg00-lvbaz /usr/local/thingies
restorecon -R /usr/local/thingies
```

## Block device notes

```bash
# Match /dev/mapper devices to /dev/dm- and /dev/xxa1
lsblk
# Get device size in bytes
blockdev -v --getsize64 /dev/block_device_here
# Get block device size in bytes
blockdev -v --getbsz /dev/block_device_here
# Determine LBA (logical blocks) occupied by a file
hdparm --fibmap /path/to/file
```

#!/bin/bash
set -x

SFTP_MOUNT="/mnt/sftp/${sftp-user-name}"
SFTP_DIR="$SFTP_MOUNT/private"

S3FS_PASSWD="/etc/s3fs/oci_passwd"

# Due to ChrootDirectory restrictions, the chrooted directory must owned by root. To overcome it, an SFTP user
# should put its file within a directory like <chroot-directory>/<user-directory>.
#
# Since <chroot-directory> is like /mnt/sftp/%u (where %u is the username), we create a subdirectory within it
# with read/write permissions for the SFTP user

# Create the SFTP directory 
mkdir -p $SFTP_DIR

# Set root ownership for chrooted directory
chown root:root $SFTP_MOUNT

# Enabling the SFTP user to write into its personal directory
chown ${sftp-user-name}:${sftp-user-group} $SFTP_DIR

# Take a look at /etc/os-release for fetching Linux distribution information
#
# Copied from https://unix.stackexchange.com/questions/432816/grab-id-of-os-from-etc-os-release
OS_ID=$(grep -oP '(?<=^ID=).+' /etc/os-release | tr -d '"')

if [ $OS_ID == "ol" ]; then

  OS_MAJOR_VERSION=$(grep -oP '(?<=^VERSION_ID=).+' /etc/os-release | tr -d '"' | cut -d'.' -f1)

  # Enable s3fs YUM repository
  yum-config-manager --enable ol$OS_MAJOR_VERSION\_developer_EPEL

  # Install s3fs (https://github.com/s3fs-fuse/s3fs-fuse)
  yum install -y s3fs-fuse
fi

if [ $OS_ID == "rhel" ] || [ $OS_ID == "centos" ]; then

  # Add the EPEL repository, that includes s3fs
  yum install -y epel-release

  # Install s3fs (https://github.com/s3fs-fuse/s3fs-fuse)
  yum install -y s3fs-fuse
fi

if [ $OS_ID == "ubuntu" ] || [ $OS_ID == "debian" ]; then

  # Install s3fs (https://github.com/s3fs-fuse/s3fs-fuse)
  apt install -y s3fs
fi

# Create the s3fs configuration directory
mkdir -p /etc/s3fs

# Create hte s3fs passwd file
cat <<EOF > $S3FS_PASSWD
${s3-access-key}:${s3-secret-key}
EOF

# Update ownership of s3fs passwd file
chown root:root

# Update permissions of s3fs passwd file
chmod 0600 $S3FS_PASSWD

# Adding s3fs configuration to /etc/fstab for mounting the Object Storage bucket
if ! grep -q 's3fs#${bucket-name}' /etc/fstab ; then
    echo '# Configuration for mounting OCI Object Storage buckets through s3fs' >> /etc/fstab
    echo "s3fs#${bucket-name} $SFTP_DIR fuse _netdev,allow_other,use_path_request_style,passwd_file=$S3FS_PASSWD,url=https://${bucket-namespace}.compat.objectstorage.${region}.oraclecloud.com/ 0 0" >> /etc/fstab
fi

# Mount the Object Storage bucket
mount -a

# Copy the SSH daemon configuration file
cp /run/bootstrap/sshd_config /etc/ssh/sshd_config

# Changing ownership of SSH daemon configuration file
chown root:root /etc/ssh/sshd_config

# Update SSH daemon configuration file permissions
chmod go-rw /etc/ssh/sshd_config

# Restore SELinux context, otherwise SSH daemon fails to start
restorecon /etc/ssh/sshd_config

# Restart the SSH daemon
systemctl restart sshd
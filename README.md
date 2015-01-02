## Collection of small yet useful Windows Scripts

#### LogonAD.cmd
Active Directory logon script that checks group membership and optionally logs connections compatible Win2000/XP/2K3/Vista/7/8/8.1+

#### MxSQLBackup.cmd
Backups Microsoft SQL Server 2005/2008/2012 and MySQL / MariaDB databases, supports compression and backup rotation. Sends alert emails on backup failure.

#### FindLongFileNames.cmd
Creates a report of path and filenames exceeding 256 chars. Sends alert email if found.

#### ServiceAlert.cmd
Restarts a Windows service including custom commands, logs and sends alert emails.

#### Other small scripts

**DelTempAttributes.ps** - Removes temporary bit from files in order to force DFS Replication to process those files.

**ImportADUsers.cmd** - Reads CSV files and imports them as Active Directory Users

**w32time_reconfig.cmd** - Reconfigues Windows time service (targeted for Win2K8+ servers)

**WhenToShutdown.cmd** - Shuts the computer down depending on the day of week

**PasswordNeverExpires.cmd** - Sets a user password to never expire

**DeleteOldFiles.cmd** - Deletes files elder than X days (Vista/7/8/8.1+, ressource kit needed for XP/2K3)


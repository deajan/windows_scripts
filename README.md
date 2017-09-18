## Collection of small yet useful Windows Scripts

#### LogonAD.cmd
Active Directory logon script that checks group membership and optionally logs connections compatible Win2000/XP/2K3/Vista/7/8/8.1+

#### MxSQLBackup.cmd
Backups Microsoft SQL Server 2005/2008/2012 and MySQL / MariaDB databases, supports compression and backup rotation. Sends alert emails on backup failure.

#### FindLongFileNames.cmd
Do not use (some quirks on newer systems). Please see TLPD http://tlpd.sourceforge.net
Searches a designated path for full filenames exceeding 255 characters (or any other value), and mails a report if some exceeding filenames are met.
FindVeryLongFileNames courtesy of http://www.vcode.no/web/vcode.nsf/downloads/FindVeryLongFileNames

#### ServiceAlert.cmd
Restarts a Windows service including custom commands, logs and sends alert emails.

#### Other small scripts

**RemoveTemporaryAttribute.ps1** - Recursively removes temporary bit from files in a folder in order to force DFS Replication to process those files.

**ImportADUsers.cmd** - Reads CSV files and imports them as Active Directory Users

**w32time_reconfig.cmd** - Reconfigues Windows time service (targeted for Win2K8+ servers)

**ExecuteOnWeekDays.cmd** - Executes commands depending on the day of week

**PasswordNeverExpires.cmd** - Sets a user password to never expire

**DeleteOldFiles.cmd** - Deletes files elder than X days (Vista/7/8/8.1+, ressource kit needed for XP/2K3)


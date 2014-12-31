## Collection of small yet usefull Windows Scripts

LogonAD.cmd - Active Directory logon script that checks group membership and optionally logs connections compatible Win2000/XP/2K3/Vista/7/8/8.1+

FindLongFileNames.cmd - Creates a report of path and filenames exceeding 256 chars. Sends alert email if found.
mxSQLBackup.cmd - Backups MSSQL and MySQL / MariaDB SQL databases, compresses and rotates them. Sends alert email on backup failure.
ServiceAlert.cmd - Restarts a Windows service including custom commands, logs and sends alert emails.

The three scripts above require binaries which are gzip.exe (for log / sql compression), mailsend.exe (for sending email alerts) and base64.exe (to scramble email passwords in a very basic way)

DelTempAttributes.ps - Removes temporary bit from files in order to force DFS Replication to process those files.

ImportADUsers.cmd - Reads CSV files and imports them as Active Directory Users
w32time_reconfig.cmd - Reconfigues Windows time service (targeted for Win2K8+ servers)
WhenToShutdown.cmd - Shuts the computer down depending on the day of week
PasswordNeverExpires.cmd - Sets a user password to never expire
DeleteOldFiles.cmd - Deletes files elder than X days (Vista/7/8/8.1+, ressource kit needed for XP/2K3)

base64.exe is not mandatory, if no p64= supplied than password is used
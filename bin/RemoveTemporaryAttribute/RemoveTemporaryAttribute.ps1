# Powershell script to remove temporary attribute from files
# DFS replication does not replicate files having temporary attributes
# v1.0 by Orsiris de Jong - http://www.netpower.fr - ozy@netpower.fr

if (!$Args[0])
{
	Write-Host 'This script must be called with a path argument
	RemoveTemporaryAttribute.ps1 c:\path\to\files'
	exit
}
else
{
	Get-childitem $Args[0] -recurse | ForEach-Object -process {if (($_.attributes -band 0x100) -eq 0x100) {$_.attributes = ($_.attributes -band 0xFEFF)}}
}
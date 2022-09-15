<#
.SYNOPSIS
Find and replace for Sharepoint site webparts and titles

.DESCRIPTION
SP Find and replace loops through a Sharepoint Modern site collections SitePages folder, 
checks the title and webparts on the Page, finds the String given to it, 
and prompts what should it be changed.
Used with switches to determine where to seek for the required string.
Prompts with the result when possible match is found.

Author          Github      Web
Tarmo Urrio     @Tarzzi     https://urrio.fi

.PARAMETER Force
Switch to not care about possible wrong hits. Fast and furious.

.PARAMETER HubSite
Switch to check entire hubsites pages

.PARAMETER ReplaceAll
Switch to toggle replacing all possible hits that are found with the same string

.PARAMETER SiteURL
Site collection url ex. https://yourtenant.sharepoint.com/sites/sitecollectionname

.PARAMETER String
String to search for from titles and webparts

.PARAMETER Text
Switch to enable text webpart scanning

.PARAMETER Title
Switch to enable page title scanning

.PARAMETER Webpart
Switch to enable webpart scanning

.EXAMPLE
1. Run replace.ps1 with required parameters and desired switches. 
2. Follow prompts

.NOTES
Create an issue if somethings not lining up
#>


param (
	[Parameter(Mandatory = $true, HelpMessage = "Hubsite / Site collection address, where to check for the text")]
	$SiteURL,
	[Parameter(Mandatory = $true, HelpMessage = "Text string to find from the sites")]
	$String,
	[switch]$HubSite,
	[switch]$ReplaceAll,
	[switch]$Capital,
	[switch]$Text,
	[switch]$Title,
	[switch]$Webpart,
	[switch]$Force
)

Get-Module PnP.PowerShell


function WriteLog {
	Param ([String]$LogString, [String]$Color)
	$Stamp = Get-Date -Format "HH:mm:ss" 
	$LogMessage = $Stamp + ":: " + $LogString
	Write-Host $LogMessage -ForegroundColor $Color
}

function FindAndReplace {
	# Logging
	$Location = (Get-Item .).FullName
	$Timestamp = Get-Date -Format "ddMMHHmm" 
	$Location = $Location + "\replace_log_" + $Timestamp + ".log"  
	Start-Transcript -Append $Location


	if ($ReplaceAll.IsPresent) {
		$NewString = Read-Host "Give the string to replace all found items"
	}


	# Get hubsite and refrence to id:s
	if ($HubSite.IsPresent){
		$AdminSiteURL = Read-Host "Enter Admin site URL: "
		Connect-PnPOnline -URL $AdminSiteURL -Interactive -ErrorAction Stop
		$HubSiteURL = $SiteURL
		$HubSite = Get-PnPHubSite -Identity $HubSiteURL
		$HubID = $HubSite.ID.GUID
		$Sites = Get-PnPTenantSite

		$Sites | ForEach-Object {
			# Write-Host $_.HubSiteID
			$SiteGUID = $_.HubSiteID
			if($HubID -eq $SiteGUID){
				# Check page on match
				$SiteURL = $_.Url
				Write-Host $SiteURL
				Connect 
			}
		}
		
        WriteLog "Text replacer finished!" Green
        Disconnect-PnPOnline
        Stop-Transcript
	}
	else{
		Connect
		
        WriteLog "Text replacer finished!" Green
        Disconnect-PnPOnline
        Stop-Transcript
	}

}

. "$PSScriptRoot\Finder\Title.ps1"
. "$PSScriptRoot\Finder\Webpart.ps1"
. "$PSScriptRoot\Finder\Text.ps1"
. "$PSScriptRoot\Finder\Connect.ps1"
FindAndReplace
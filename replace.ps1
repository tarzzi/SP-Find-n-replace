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
	[Parameter(Mandatory = $true, HelpMessage = "Site collection address, where to check for the text")]
	$SiteURL,
	[Parameter(Mandatory = $true, HelpMessage = "Text string to find from the sites")]
	$String,
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

	Try {
		WriteLog "Connecting to $($SiteURL)" Yellow
		Connect-PnPOnline -URL $SiteURL -Interactive -ErrorAction Stop
	}
	Catch {
		WriteLog "Error connecting to Sharepoint"
	}

	Try {
		$PageItems = Get-PnPListItem -List "Site Pages"
		$Pages = $PageItems | ForEach-Object { $_["FileLeafRef"] }
		$PageCount = $Pages.Length
		$Count = 1
		$LikeStr = '*' + $String + '*'

		# Loop pages of collection
		$Pages | ForEach-Object {
			try {
				$RequireSave = $false

				$Page = Get-PnPPage -Identity $_
				Write-Host "`n"
				WriteLog "Checking site $($Page.Name) ($($Count)/$($PageCount))" White

				# Page Title 
				CheckTitles

				# Other Webparts
				CheckWebparts

				# Plaintext webparts
				CheckText

			}
			catch {
				WriteLog "Failed checking Page $($Page.Title): $($_.Exception)" Red
			}
			# Save page when changes have been made 
			if ($RequireSave) {
				$null = $Page.Save()
				$null = $Page.Publish()
				WriteLog "$($Page.Name) saved and published." Green    
			}
			$Count += 1
		}

		WriteLog "Text replacer finished!" Green
		Disconnect-PnPOnline
		Stop-Transcript
	}

	Catch {
		WriteLog $_.Exception Red
		Stop-Transcript
		Break
	}
}

. "$PSScriptRoot\Finder\Title.ps1"
. "$PSScriptRoot\Finder\Webpart.ps1"
. "$PSScriptRoot\Finder\Text.ps1"
FindAndReplace
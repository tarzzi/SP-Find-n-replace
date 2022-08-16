<# SP Replacer
.SYNOPSIS
# Find and replace for Sharepoint text webparts

.DESCRIPTION
SP Replacer loops through a Sharepoint Modern site collection site Pages, 
checks text webparts on the Page, finds the String given to it, 
and prompts what should it be changed.  

.PARAMETER LogString
Handles logging with Timestamps (because why not)

.PARAMETER Color
Handles logging color

.EXAMPLE
Run replacer and follow prompts

.NOTES
Version     Date        Author          Github
1.0         16.8.2022   Tarmo Urrio     @Tarzzi

.FUNCTIONALITY
TODO
- Capital letter search & replace // Check text also for capital version
- Page title search
- Other webparts, eg titles
- Multiple hits on same text webpart
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
    [switch]$Other
)

Get-Module PnP.PowerShell


function WriteLog {
    Param ([String]$LogString, [String]$Color)
    $Stamp = Get-Date -Format "HH:mm:ss" 
    $LogMessage = $Stamp + ": " + $LogString
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
        Connect-PnPOnline -URL $SiteURL -Interactive

        $PageItems = Get-PnPListItem -List "Site Pages"
        $Pages = $PageItems | ForEach-Object { $_["FileLeafRef"] }
        $PageCount = $Pages.Length
        $Count = 1
        $LikeStr = '*' + $String + '*'

        $Pages | ForEach-Object {
            try {

                $Page = Get-PnPPage -Identity $_
                Write-Host "`n"
                WriteLog " Checking site $($Page.Name) ($($Count)/$($PageCount))" White

                # Begin Check Other
                # TODO    $Controls = $Page.Controls | Where-Object { "PageText" -ne $_.Type.Name } 
                # End Check Other

                # Begin Check Title
                # TODO
                # End Check Title

                # Begin Check plaintext webparts
                if ($Text.IsPresent) {
                    $Controls = $Page.Controls | Where-Object { "PageText" -eq $_.Type.Name }    
                    WriteLog "- Found ($($Controls.Length)) text web part(s)" White

                    $Controls | ForEach-Object {                        
                        WriteLog "-- Checking web part InstanceId: $($_.InstanceId)"  White
                        try {
                            $FoundString = $_.Text
                            if ($FoundString -like $LikeStr) {
                                WriteLog "--- Bingo! Found text:" Green
                                WriteLog $FoundString White
                                if (!$ReplaceAll.IsPresent) {
                                    WriteLog "What should it be replaced with?" Yellow 
                                    $NewString = Read-Host "New string"
                                }
                           
                                #$_.text = $String.replace($String, $NewString)
                                $_.text = $FoundString -replace $String, $NewString

                                WriteLog "Text updated!" Green

                                $null = $Page.Save()
                                $null = $Page.Publish()
                                WriteLog "$($Page.Name) saved and published." Green      
                            }
                            else {
                                WriteLog "--- No matches!" Yellow
                            }

                        }
                        catch {                           
                            WriteLog "Failed updating web part, InstanceId: $($_.InstanceId), Error: $($_.Exception)" Red
                        }
                    }
                }
                # End Check plaintext webparts
            }
            catch {
                WriteLog "Failed checking Page $($Page.Title): $($_.Exception)" Red
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

. FindAndReplace
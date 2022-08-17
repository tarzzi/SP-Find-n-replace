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

.PARAMETER CancelWith
Parameter string to cancel the replacement operation.

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
#TODO
- Cancel string that can be set up 
- Force
#>


param (
    [Parameter(Mandatory = $true, HelpMessage = "Site collection address, where to check for the text")]
    $SiteURL,
    [Parameter(Mandatory = $true, HelpMessage = "Text string to find from the sites")]
    $String,
    [Parameter(Mandatory = $true, HelpMessage = "String to cancel the replacing when possible match is found")]
    $CancelWith,
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
        Connect-PnPOnline -URL $SiteURL -Interactive

        $PageItems = Get-PnPListItem -List "Site Pages"
        $Pages = $PageItems | ForEach-Object { $_["FileLeafRef"] }
        $PageCount = $Pages.Length
        $Count = 1
        $LikeStr = '*' + $String + '*'

        $Pages | ForEach-Object {
            try {
                $RequireSave = $false

                $Page = Get-PnPPage -Identity $_
                Write-Host "`n"
                WriteLog "Checking site $($Page.Name) ($($Count)/$($PageCount))" White

                # Begin Check Title
                if ($Title.IsPresent) {
                    try {
                        $PageName = $Page.PageTitle
                        WriteLog "- Checking title: $($PageName)" White
                    
                        if ($PageName -like $LikeStr) {
                            WriteLog "-- Bingo! Found matching title" Green
                            if (!$ReplaceAll.IsPresent) {
                                WriteLog "What should it be replaced with?" Yellow 
                                $NewString = Read-Host "New string"
                            }
                            $Page.PageTitle = $PageName -replace $String, $NewString
                            $RequireSave = $true
                        }
                        else {
                            WriteLog "-- No matches!" Yellow
                        }
                    }
                    catch {
                        WriteLog "Failed updating page title, Name: $($Page.PageTitle), Error: $($_.Exception)" Red
                    }
                }
                # End Check Title

                # Begin Check Other Webparts
                if ($Webpart.IsPresent) {
                    $WebpartCount = 1
                    try {
                        $Controls = $Page.Controls | Where-Object { "PageText" -ne $_.Type.Name }
                        WriteLog "- Found ($($Controls.Length)) web part(s)" White

                        $Controls | ForEach-Object {      
                            WriteLog "-- Checking webpart $($WebpartCount)/$($Controls.Length)"  White
                            $altText = $_.PropertiesJson.altText
                            $wpTitle = $_.PropertiesJson.Title
                            $wpLink = $_.PropertiesJson.Link
                            #Custom webparts
                            $wpCustomTitle = $_.PropertiesJson.collectionData.title
                            $wpCustomDesc = $_.PropertiesJson.collectionData.description
                            $wpCustomLink = $_.PropertiesJson.collectionData.link

                            try {
                                # Webpart Title
                                if ($altText -like $LikeStr) {
                                    WriteLog "-- Bingo! Found matching alt text: $($altText)" Green
                                    if (!$ReplaceAll.IsPresent) {
                                        WriteLog "What should it be replaced with?" Yellow 
                                        $NewString = Read-Host "New string"
                                    }
                                    $_.PropertiesJson.altText = $altText -replace $String, $NewString
                                    $RequireSave = $true
                                }
                                #Webpart Alt-text
                                elseif ($wpTitle -like $LikeStr) {
                                    WriteLog "-- Bingo! Found matching title text: $($altText)" Green
                                    if (!$ReplaceAll.IsPresent) {
                                        WriteLog "What should it be replaced with?" Yellow 
                                        $NewString = Read-Host "New string"
                                    }
                                    $_.PropertiesJson.Title = $wpTitle -replace $String, $NewString
                                    $RequireSave = $true
                                }
                                #Webpart Link-text
                                elseif ($wpLink -like $LikeStr) {
                                    WriteLog "-- Bingo! Found matching link text: $($wpLink)" Green
                                    if (!$ReplaceAll.IsPresent) {
                                        WriteLog "What should it be replaced with?" Yellow 
                                        $NewString = Read-Host "New string"
                                    }
                                    $_.PropertiesJson.Link = $wpLink -replace $String, $NewString
                                    $RequireSave = $true
                                }
                                #Webpart custom Title-text
                                elseif ($wpCustomTitle -like $LikeStr) {
                                    WriteLog "-- Bingo! Found matching title text: $($wpCustomTitle)" Green
                                    if (!$ReplaceAll.IsPresent) {
                                        WriteLog "What should it be replaced with?" Yellow 
                                        $NewString = Read-Host "New string"
                                    }
                                    $_.PropertiesJson.collectionData.title = $wpCustomTitle -replace $String, $NewString
                                    $RequireSave = $true
                                }
                                #Webpart custom Description-text
                                elseif ($wpCustomDesc -like $LikeStr) {
                                    WriteLog "-- Bingo! Found matching description text: $($wpCustomDesc)" Green
                                    if (!$ReplaceAll.IsPresent) {
                                        WriteLog "What should it be replaced with?" Yellow 
                                        $NewString = Read-Host "New string"
                                    }
                                    $_.PropertiesJson.collectionData.description = $wpCustomDesc -replace $String, $NewString
                                    $RequireSave = $true
                                }
                                #Webpart custom Link-text
                                elseif ($wpCustomLink -like $LikeStr) {
                                    WriteLog "-- Bingo! Found matching link text: $($wpCustomLink)" Green
                                    if (!$ReplaceAll.IsPresent) {
                                        WriteLog "What should it be replaced with?" Yellow 
                                        $NewString = Read-Host "New string"
                                    }
                                    $_.PropertiesJson.collectionData.link = $wpCustomLink -replace $String, $NewString
                                    $RequireSave = $true
                                }
                            }
                            catch {  
                                WriteLog "Failed updating webpart, InstanceId: $($_.InstanceId), Error: $($_.Exception)" Red
                            }
                           
                        }
                    }
                    catch {
                        WriteLog "Failed checking webparts, Error: $($_.Exception)" Red
                       
                    }
                    $Webpartcount += 1
                }
                # End Check Other

                # Begin Check plaintext webparts
                if ($Text.IsPresent) {
                    $Controls = $Page.Controls | Where-Object { "PageText" -eq $_.Type.Name }    
                    WriteLog "- Found ($($Controls.Length)) text web part(s)" White
                    $WpCount = 1

                    $Controls | ForEach-Object {                        
                        WriteLog "-- Checking text webpart $($WpCount)/$($Controls.Length)"  White
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
                                $RequireSave = $true
  
                            }
                        }
                        catch {                           
                            WriteLog "Failed updating webpart, InstanceId: $($_.InstanceId), Error: $($_.Exception)" Red
                        }
                        $WpCount += 1
                    }
                    if (!$RequireSave) {
                        WriteLog "--- No matches!" Yellow
                    }
                }
                # End Check plaintext webparts
            }
            catch {
                WriteLog "Failed checking Page $($Page.Title): $($_.Exception)" Red
            }
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

. FindAndReplace
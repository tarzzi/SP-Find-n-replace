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
Version     16.8.2022   Author          Github
1.0         Date        Tarmo Urrio     @Tarzzi

#>

function WriteLog{
    Param ([String]$LogString, [String]$Color)
    $Stamp = Get-Date -Format "HH:mm:ss" 
    $LogMessage = $Stamp + ": " + $LogString
    Write-Host $LogMessage -ForegroundColor $Color
}

$Location = (Get-Item .).FullName
$Timestamp = Get-Date -Format "ddMMHHmm" 
$Location = $Location + "\replacer_log_" + $Timestamp + ".txt"  
Start-Transcript -Append $Location
$SiteURL = Read-Host "Give site collection url"
$OldString = Read-Host "Text to find"

    Try {
        WriteLog "Connect to $($SiteURL)" White
        Connect-PnPOnline -URL $SiteURL -Interactive

            $PageItems = Get-PnPListItem -List "Site Pages"
            $Pages = $PageItems | ForEach-Object { $_["FileLeafRef"] }
            $PageCount = $Pages.Length
            $Count = 1

        $Pages | ForEach-Object {
            try {

                $Page = Get-PnPPage -Identity $_
                Write-Host "`n"
                WriteLog " Checking site $($Page.Name) ($($Count)/$($PageCount))" White
                $Controls = $Page.Controls | Where-Object { "PageText" -eq $_.Type.Name }    
                WriteLog "- Found ($($Controls.Length)) text web part(s)" White

                $Controls | ForEach-Object {                        
                    WriteLog "-- Checking web part InstanceId: $($_.InstanceId)"  White
                    try {
                        $String = $_.text
                        $LikeStr = '*' + $OldString + '*'
                        if($String -like $LikeStr){
                            WriteLog "--- Bingo! Found text:" Green
                            WriteLog $String White
                            WriteLog "What should it be replaced with?" Yellow 
                            $NewString = Read-Host 
                            $_.text = $String.replace($OldString,$NewString)
                            WriteLog "Text updated!" Green

                            $null = $Page.Save()
                            $null = $Page.Publish()
                            WriteLog "$($Page.Name) saved and published." Green      
                        }
                        else{
                            WriteLog "--- No matches!" Yellow
                        }

                    }
                    catch {                           
                        WriteLog "Failed updating web part, InstanceId: $($_.InstanceId), Error: $($_.Exception)" Red
                    }
                }
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
        WriteLog $_.Exception
        Stop-Transcript
        Break
    }


function Connect {
    Try {
        WriteLog "Connecting to $($SiteURL)" Yellow
        Connect-PnPOnline -URL $SiteURL -Interactive
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

    }

    Catch {
        WriteLog $_.Exception Red
        if (!$HubSite.IsPresent) {
            Stop-Transcript
            Break
        }
    }
}
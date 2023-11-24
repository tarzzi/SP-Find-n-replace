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
        $CsvItem = @()

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

                # Author
                CheckAuthor

            }
            catch {
                WriteLog "Failed checking Page $($Page.Title): $($_.Exception)" Red
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
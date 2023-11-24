function CheckAuthor {
    if ($Author.IsPresent) {
        try {
            $AuthorLine = $Page.PageHeader.AuthorByline
            if ($AuthorLine -like $LikeStr) {
                WriteLog "--- Bingo! Found author" Green

                $CsvItem += [PSCustomObject]@{
                    "SiteUrl" = $SiteURL
                    "PageUrl" = $SiteUrl + "/sitepages/" + $Page.Name
                    "Text"    = $AuthorLine
                }
                if (!$FindOnly.IsPresent) {
                    if ((!$ReplaceAll.IsPresent) -and (!$Force.IsPresent)) {
                        WriteLog "Replace this Author y/n ?" Yellow
                        $Confirm = Read-Host "Type y for yes, n for no"
                        if ($Confirm -eq "y") {
                            WriteLog "Please give the new author UPN " Yellow 
                            $NewString = Read-Host "New author email adress:"
                            $Page.PageHeader.AuthorByline = $AuthorLine -replace $String, $NewString
                            WriteLog "Author replaced!" Green
                            SavePage
                        }
                        else {
                            WriteLog "Skipping..." Yellow
                        }
                    }
                    if (($Force.IsPresent) -and ($ReplaceAll.IsPresent)) {
                        $Page.PageHeader.AuthorByline = $AuthorLine -replace $String, $NewString
                        WriteLog "Author replaced!" Green
                        SavePage
                    }
                    if (($Force.IsPresent) -and (!$ReplaceAll.IsPresent)) {
                        WriteLog "Please give the new author UPN " Yellow 
                        $NewString = Read-Host "New author email adress:"
                        $Page.PageHeader.AuthorByline = $AuthorLine -replace $String, $NewString
                        WriteLog "Author replaced!" Green
                        SavePage
                    }
                }
            }

        }
        catch {
            WriteLog "Failed checking Author, Error: $($_.Exception)" Red
           
        }
    }
    
}
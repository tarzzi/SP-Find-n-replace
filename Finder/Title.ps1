Function CheckTitles {
	if ($Title.IsPresent) {
		try {
			$PageName = $Page.PageTitle
			WriteLog "- Checking title: $($PageName)" White
        
			if ($PageName -like $LikeStr) {
				WriteLog "-- Bingo! Found matching title" Green
				
				if ($AuthorLine -like $LikeStr) {
					WriteLog "--- Bingo! Found author" Green
	
					$CsvItem += [PSCustomObject]@{
						"SiteUrl" = $SiteURL
						"PageUrl" = $SiteUrl + "/sitepages/" + $Page.Name
						"Text"    = $AuthorLine
					}
					if (!$ReplaceAll.IsPresent) {
						WriteLog "What should it be replaced with?" Yellow 
						$NewString = Read-Host "New string"
					}
					if ($Force.IsPresent) {
						$Page.PageTitle = $PageName -replace $String, $NewString
						WriteLog "Text replaced!" Green
						SavePage
					}
					else {
						WriteLog "Are you sure you want to replace this y/n ?" Yellow
						$Confirm = Read-Host "Type y for yes, n for no"
						if ($Confirm -eq "y") {
							$Page.PageTitle = $PageName -replace $String, $NewString
							WriteLog "Text replaced!" Green
							SavePage
						}
						else {
							WriteLog "Skipping..." Yellow
						}
					}
				}
			}
		}
		catch {
			WriteLog "Failed updating page title, Name: $($Page.PageTitle), Error: $($_.Exception)" Red
		}
	}
}
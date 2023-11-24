function CheckWebparts {
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
						$CsvItem += [PSCustomObject]@{
							"SiteUrl" = $SiteURL
							"PageUrl" = $SiteUrl + "/sitepages/" + $Page.Name
							"Text"    = $altText
						}
						if (!$FindOnly.IsPresent) {
							if (!$ReplaceAll.IsPresent) {
								WriteLog "What should it be replaced with?" Yellow 
								$NewString = Read-Host "New string"
							}
							if ($Force.IsPresent) {
								$_.PropertiesJson.altText = $altText -replace $String, $NewString
								WriteLog "Text replaced!" Green
								SavePage
							}
							else {
								WriteLog "Are you sure you want to replace this y/n ?" Yellow
								$Confirm = Read-Host "Type y for yes, n for no"
								if ($Confirm -eq "y") {
									$_.PropertiesJson.altText = $altText -replace $String, $NewString
									WriteLog "Text replaced!" Green
									SavePage
								}
								else {
									WriteLog "Skipping..." Yellow
								}
							}
						}
					}
					#Webpart Alt-text
					elseif ($wpTitle -like $LikeStr) {
						WriteLog "-- Bingo! Found matching title text: $($wpTitle)" Green
						
						$CsvItem += [PSCustomObject]@{
							"SiteUrl" = $SiteURL
							"PageUrl" = $SiteUrl + "/sitepages/" + $Page.Name
							"Text"    = $altText
						}
						if (!$FindOnly.IsPresent) {
							if (!$ReplaceAll.IsPresent) {
								WriteLog "What should it be replaced with?" Yellow 
								$NewString = Read-Host "New string"
							}
							if ($Force.IsPresent) {
								$_.PropertiesJson.Title = $wpTitle -replace $String, $NewString
								WriteLog "Text replaced!" Green
								SavePage
							}
							else {
								WriteLog "Are you sure you want to replace this y/n ?" Yellow
								$Confirm = Read-Host "Type y for yes, n for no"
								if ($Confirm -eq "y") {
									$_.PropertiesJson.Title = $wpTitle -replace $String, $NewString
									WriteLog "Text replaced!" Green
									SavePage
								}
								else {
									WriteLog "Skipping..." Yellow
								}
							}
						}
					}
					#Webpart Link-text
					elseif ($wpLink -like $LikeStr) {
						WriteLog "-- Bingo! Found matching link text: $($wpLink)" Green
						$CsvItem += [PSCustomObject]@{
							"SiteUrl" = $SiteURL
							"PageUrl" = $SiteUrl + "/sitepages/" + $Page.Name
							"Text"    = $wpLink
						}
						if (!$FindOnly.IsPresent) {
							if (!$ReplaceAll.IsPresent) {
								WriteLog "What should it be replaced with?" Yellow 
								$NewString = Read-Host "New string"
							}
							if ($Force.IsPresent) {
								$_.PropertiesJson.Link = $wpLink -replace $String, $NewString
								WriteLog "Text replaced!" Green
								SavePage
							}
							else {
								WriteLog "Are you sure you want to replace this y/n ?" Yellow
								$Confirm = Read-Host "Type y for yes, n for no"
								if ($Confirm -eq "y") {
									$_.PropertiesJson.Link = $wpLink -replace $String, $NewString
									WriteLog "Text replaced!" Green
									SavePage
								}
								else {
									WriteLog "Skipping..." Yellow
								}
							}
						}
					}
					#Webpart custom Title-text
					elseif ($wpCustomTitle -like $LikeStr) {
						WriteLog "-- Bingo! Found matching title text: $($wpCustomTitle)" Green
						
						$CsvItem += [PSCustomObject]@{
							"SiteUrl" = $SiteURL
							"PageUrl" = $SiteUrl + "/sitepages/" + $Page.Name
							"Text"    = $altText
						}
						if (!$FindOnly.IsPresent) {
							if (!$ReplaceAll.IsPresent) {
								WriteLog "What should it be replaced with?" Yellow 
								$NewString = Read-Host "New string"
							}
							if ($Force.IsPresent) {
								$_.PropertiesJson.collectionData.title = $wpCustomTitle -replace $String, $NewString
								WriteLog "Text replaced!" Green
								SavePage
							}
							else {
								WriteLog "Are you sure you want to replace this y/n ?" Yellow
								$Confirm = Read-Host "Type y for yes, n for no"
								if ($Confirm -eq "y") {
									$_.PropertiesJson.collectionData.title = $wpCustomTitle -replace $String, $NewString
									WriteLog "Text replaced!" Green
									SavePage
								}
								else {
									WriteLog "Skipping..." Yellow
								}
							}
						}
					}
					#Webpart custom Description-text
					elseif ($wpCustomDesc -like $LikeStr) {
						WriteLog "-- Bingo! Found matching description text: $($wpCustomDesc)" Green
						$CsvItem += [PSCustomObject]@{
							"SiteUrl" = $SiteURL
							"PageUrl" = $SiteUrl + "/sitepages/" + $Page.Name
							"Text"    = $wpCustomDesc
						}
						if (!$FindOnly.IsPresent) {
							if (!$ReplaceAll.IsPresent) {
								WriteLog "What should it be replaced with?" Yellow 
								$NewString = Read-Host "New string"
							}
							if ($Force.IsPresent) {
								$_.PropertiesJson.collectionData.description = $wpCustomDesc -replace $String, $NewString
								WriteLog "Text replaced!" Green
								SavePage
							}
							else {
								WriteLog "Are you sure you want to replace this y/n ?" Yellow
								$Confirm = Read-Host "Type y for yes, n for no"
								if ($Confirm -eq "y") {
									$_.PropertiesJson.collectionData.description = $wpCustomDesc -replace $String, $NewString
									WriteLog "Text replaced!" Green
									SavePage
								}
								else {
									WriteLog "Skipping..." Yellow
								}
							}
						}
					}
					#Webpart custom Link-text
					elseif ($wpCustomLink -like $LikeStr) {
						WriteLog "-- Bingo! Found matching link text: $($wpCustomLink)" Green
						$CsvItem += [PSCustomObject]@{
							"SiteUrl" = $SiteURL
							"PageUrl" = $SiteUrl + "/sitepages/" + $Page.Name
							"Text"    = $wpCustomLink
						}
						if (!$FindOnly.IsPresent) {
							if (!$ReplaceAll.IsPresent) {
								WriteLog "What should it be replaced with?" Yellow 
								$NewString = Read-Host "New string"
							}
							if ($Force.IsPresent) {
								$_.PropertiesJson.collectionData.link = $wpCustomLink -replace $String, $NewString
								WriteLog "Text replaced!" Green
								SavePage
							}
							else {
								WriteLog "Are you sure you want to replace this y/n ?" Yellow
								$Confirm = Read-Host "Type y for yes, n for no"
								if ($Confirm -eq "y") {
									$_.PropertiesJson.collectionData.link = $wpCustomLink -replace $String, $NewString
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
					WriteLog "Failed updating webpart, InstanceId: $($_.InstanceId), Error: $($_.Exception)" Red
				}
   
				$Webpartcount += 1            
			}
		}
		catch {
			WriteLog "Failed checking webparts, Error: $($_.Exception)" Red
           
		}
	}
    
}
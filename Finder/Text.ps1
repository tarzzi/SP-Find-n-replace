function CheckText {
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
					if ($Force.IsPresent) {
						$_.text = $FoundString -replace $String, $NewString
						WriteLog "Text replaced!" Green
						$RequireSave = $true
					}
					else {
						WriteLog "Are you sure you want to replace this y/n ?" Yellow
						$Confirm = Read-Host "Type y for yes, n for no"
						if ($Confirm -eq "y") {
							$_.text = $FoundString -replace $String, $NewString
							WriteLog "Text replaced!" Green
							$RequireSave = $true
						}
						else {
							WriteLog "Skipping..." Yellow
						}
					}
				}
			}
			catch {                           
				WriteLog "Failed updating webpart, InstanceId: $($_.InstanceId), Error: $($_.Exception)" Red
			}
			$WpCount += 1
		}
	}
    
    
}
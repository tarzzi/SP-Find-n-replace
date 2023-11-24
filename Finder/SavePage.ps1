function SavePage {
    $null = $Page.Save()
    $null = $Page.Publish()
    WriteLog "$($Page.Name) saved and published." Green    
}
# SP-Find-n-replace

## Find and replace for Sharepoint text webparts

SP Replacer loops through a Sharepoint Modern site collection site Pages, 
checks text webparts on the Page, finds the String given to it, 
and prompts what should it be changed.

## Example run

![Example image](example.png)

## Version history

|Version|Date|Updates|
|--|--|--|
|1.0|16.8.2022|Initial version|
|1.1|17.8.2022|Add replacing for page title and other webparts. Add force switch and confirmation. |

## Usage

Run replace.ps1 with desired switches for desired result.

``` Powershell
.\replace.ps1 -SiteURL https://YOURTENANT.sharepoint.com/sites/SITECOLLECTION -String "Example" -Title -Webpart -Text
```

## Parameters

-Force
Switch to not care about possible wrong hits. Fast and furious.

-ReplaceAll
Switch to toggle replacing all possible hits that are found with the same string

-SiteURL "string"
Site collection url ex. https://yourtenant.sharepoint.com/sites/sitecollectionname

-String "string"
String to search for from titles and webparts

-Text
Switch to enable text webpart scanning

-Title
Switch to enable page title scanning

-Webpart
Switch to enable webpart scanning
# SP-Find-n-replace

## Find and replace for Sharepoint text webparts

SP Replacer loops through a Sharepoint Modern site collection site Pages, 
checks text webparts on the Page, finds the String given to it, 
and prompts what should it be changed.

## Example run

![Example image](example.png)

## Version history

|Version|Published|Changes|
|--|--|--|
|1.0|16.8.2022|Initial version|
|1.1|17.8.2022|Add replacing for page title and other webparts. Add force switch and confirmation. |
|1.2|15.9.2022|Add HubSite wide checking option|
|1.3|19.9.2022|Add AuthorByLine replacing option|
|1.4|24.11.2023|Add FindOnly switch|

## Parameters and Switches

- **Author**  
Switch to enable author replacing on AuthorByLine.

- **Force**  
Switch to not care about possible wrong hits. Fast and furious.

- **HubSite**  
Switch to toggle whole HubSite checking

- **ReplaceAll**  
Switch to toggle replacing all possible hits that are found with the same string

- **SiteURL**  
Site collection url ex. https://yourtenant.sharepoint.com/sites/sitecollectionname

- **String**  
String to search for from titles and webparts

- **Text**  
Switch to enable text webpart scanning

- **Title**  
Switch to enable page title scanning

- **Webpart**  
Switch to enable webpart scanning

- **FindOnly**
Switch to enable find only mode. No replacing is done.

## Usage

Run replace.ps1 with desired switches for desired result.

### Examples

Search through single site collection 
``` Powershell
.\Replace.ps1 -SiteURL https://YOURTENANT.sharepoint.com/sites/SITECOLLECTION -String "Example" -Title -Webpart -Text
```
Search through all site collections that are connected to the hubsite
``` Powershell
.\Replace.ps1 -HubSite -SiteURL https://YOURTENANT.sharepoint.com/sites/HUBSITE -String "Example" -Title -Webpart -Text
```
Replace author that has left the company from all pages 
``` Powershell
.\Replace.ps1 -HubSite -SiteURL https://YOURTENANT.sharepoint.com/sites/HUBSITE -String "Example" -Author
```
Replace URL address from all links
``` Powershell
.\Replace.ps1 -HubSite -SiteURL https://YOURTENANT.sharepoint.com/sites/HUBSITE -String "www.test.com" -Text -Webpart
```
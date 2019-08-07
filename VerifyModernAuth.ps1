#Import the module, requires that you are administrator and are able to run the scripts 
#Requires the Hybrid Exhange Powershell module 
#Instructions here: https://msunified.net/2018/02/01/how-to-connect-to-exchange-online-powershell-via-ise-with-mfa-the-correct-way/
#
Import-Module $((Get-ChildItem -Path $($env:LOCALAPPDATA+"\Apps\2.0\") -Filter CreateExoPSSession.ps1 -Recurse ).FullName | Select-Object -Last 1)
#connect specifying username, if you already have authenticated to another moduel, you actually do not have to authenticate 
#Connect-EXOPSSession -UserPrincipalName user@domain.onmicrosoft.com 
#This will make sure when you need to reauthenticate after 1 hour that it uses existing token and you don't have to write password and stuff
Connect-EXOPSSession -UserPrincipalName <Your Admin> 
$global:UserPrincipalName="<Your Admin"


Get-OrganizationConfig | Format-Table -Auto Name,OAuth*
#Set-OrganizationConfig -OAuth2ClientProfileEnabled $true


#Sharepoint 
#Requires the Sharepoint Online Powershell Module 

Import-Module Microsoft.Online.SharePoint.PowerShell -DisableNameChecking
$orgName="<Your ORG URL"
Connect-SPOService -Url https://$orgName-admin.sharepoint.com 
$SPOTenant=Get-SPOTenant  
$SPOTenant.LegacyAuthProtocolsEnabled

(Get-SPOTenant).LegacyAuthProtocolsEnabled

#Skype
Import-Module SkypeOnlineConnector
$sfbSession = New-CsOnlineSession -UserName <your admin>
Import-PSSession $sfbSession
#Set-CsOAuthConfiguration -ClientAdalAuthOverride Allow

Get-CsOAuthConfiguration | Format-Table -Auto Identity,ClientAdalAuthOverride*

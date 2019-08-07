Connect-MsolService 
#Set your domain name 
$MyDomoain = MyDomain.com 

#FIND ALL USERS THAT ARE REGISTERED
Get-MsolUser -All | where {$_.StrongAuthenticationMethods -ne $null} | Select-Object -Property UserPrincipalName | Sort-Object userprincipalname 

#FIND ALL USER objects THAT ARE NOT REGISTERED
Get-MsolUser -All | where {$_.StrongAuthenticationMethods.Count -eq 0} | Select-Object -Property UserPrincipalName | Sort-Object userprincipalname 

#Find All End Users in my domain 
Get-MsolUser -All | where {$_.StrongAuthenticationMethods.Count -eq 0 -and $_.UserPrincipalName -match $MyDomain} | Select-Object -Property UserPrincipalName | Sort-Object userprincipalname 

#Create a group in AAD (I have called it (MFA_Enforce)_(Not Registered Users) ) 
#Collect the ID to Variable
$NonMFAGroup = Get-MsolGroup | Where-Object {$_.DisplayName -eq “(MFA_Enforce)_(Not Registered Users)”}

$UsersWithoutMFA = Get-MsolUser -All | where {$_.StrongAuthenticationMethods.Count -eq 0 -and $_.UserPrincipalName -match $MyDomain} | Select-Object -Property UserPrincipalName, ObjectID | Sort-Object userprincipalname 
$UsersWithMFA = Get-MsolUser -All | where {$_.StrongAuthenticationMethods -ne $null} | Select-Object -Property UserPrincipalName, ObjectID | Sort-Object userprincipalname

foreach ($user in $UsersWithoutMFA){
    Add-MsolGroupMember -GroupObjectId $NonMFAGroup.ObjectId -GroupMemberType User -GroupMemberObjectId $user.ObjectID
}

$MFAGroup = Get-MsolGroupMember -GroupObjectId $NonMFAGroup.ObjectId | Select-Object -Property ObjectID 
$UsersRegistered = Compare-Object -ReferenceObject $MFAGroup.ObjectID -DifferenceObject $UsersWithMFA.ObjectID -ExcludeDifferent -IncludeEqual

foreach ($user in $UsersRegistered){
    Remove-MsolGroupMember -GroupObjectId $NonMFAGroup.ObjectId -GroupMemberObjectId $user.InputObject
}

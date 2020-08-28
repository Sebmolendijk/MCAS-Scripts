$csvPath = 'c:\temp\alerts.csv'

Import-Module MCAS

$CASCredential = Import-Clixml 'C:\temp\CASCred.credential'

# Define here the policies Ids for which you want to get the alerts
$policies = '5b50869efddeab63c76d4cc8'

# empty array of alerts to be exported to a CSV
$alertsList = @()

foreach($policy in $policies) {

    $alerts = Get-MCASAlert -Policy $policy
    
    foreach($alert in $alerts) {

        $app = ($alert.entities | where {$_.type -eq 'service'}).label
        $file = ($alert.entities | where {$_.type -eq 'file'}).id

        $fileDetails = Get-MCASFile -Identity $file
   
        $properties = @{
            "alertId" = $alert._id;
            "timeStamp" = ConvertFrom-MCASTimestamp $alert.timestamp;
            "alertTitle" = $alert.title;
            "alertStatus" = $alert.statusValue;
            "alertSeverity" = $alert.severityValue;
            "alertUrl" = $alert.URL;
            "application" = $app;
            "fileName" = $fileDetails.name;
            "filePath" = $fileDetails.alternateLink;
            "fileOwner" = $fileDetails.ownerAddress;
            "fileCreatedDate" = ConvertFrom-MCASTimestamp $fileDetails.createdDate;
            "fileModifiedDate" = ConvertFrom-MCASTimestamp $fileDetails.modifiedDate;
            "fileStatus" = $fileDetails.fileStatus[1];
            "fileAccessLevel" = $fileDetails.fileAccessLevel[1]
        }
      

        $obj = New-Object -TypeName psobject -Property $properties
        $alertsList += $obj

    }
}


$alertsList | Export-Csv $csvPath -NoTypeInformation -Encoding Unicode -Delimiter ';' -Force
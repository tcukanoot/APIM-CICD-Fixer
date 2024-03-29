$templatePath = "..\APIM";

<#
    Start Master ARM Template fix
#>

$ApiFolderList = Get-ChildItem -Directory $templatePath | Select-Object -Property Name;
$templatePath += "\<master>.template.json";
$armTemplate = Get-Content -Path $templatePath -Raw | ConvertFrom-Json;

$previousFolder = "First";

#number of templates before apitemplate
$index = $armTemplate.resources.Count - 1;
#$index = 8;

$ApiFolderList = $ApiFolderList | ? { $_.Name -ne "policies" };

for ($i = 0; $i -lt $index; $i++) {
    $armTemplate.resources[$i].properties.parameters.PolicyXMLBaseUrl.value = "[concat(parameters('PolicyXMLBaseUrl'), '/policies')]";
}

foreach ($folder in $ApiFolderList) {
#for ($folderIndex = 0; $folderIndex -lt $ApiFolderList.Count; $folderIndex++) {
    #$output = "'/" + $folder.Name + "/<master>.template.json'`r`n";
    #$output;

    if ($armTemplate.resources.Length -lt $index + 1) {
        #append new row here
        $tempRow = $armTemplate.resources[$index - 1];
        $armTemplate.resources += ConvertFrom-Json -InputObject (ConvertTo-Json -Depth 100 -InputObject $tempRow)
    }

    #change the last record the apitemplates file to each of the subfolder master files
    #update templateLink in resources/properties
    $armTemplate.resources[$index].properties.templateLink.uri = "[concat(parameters('LinkedTemplatesBaseUrl'), '/$($folder.Name)/<master>.template.json')]"

    #add LinkedTemplatesBaseUrl in resources/propertes/parameters
    if ($previousFolder.Equals("First")) {
        #$tempLinkedTemplatesBaseUrl = $armTemplate.resources[$index].properties.parameters.PolicyXMLBaseUrl;
        #$tempLinkedTemplatesBaseUrl.value = "[concat(parameters('LinkedTemplatesBaseUrl'), '/$($folder.Name)')]";

        $temp = "
            {
                ""value"":""[concat(parameters('LinkedTemplatesBaseUrl'), '/$($folder.Name)')]""
            }
        ";

        $tempLinkedTemplatesBaseUrl = ConvertFrom-Json -InputObject $temp;

        $armTemplate.resources[$index].properties.parameters | Add-Member -MemberType NoteProperty -Name "LinkedTemplatesBaseUrl" -Value $tempLinkedTemplatesBaseUrl;
    } else {
        #$armTemplate.resources[$index].properties.parameters | Add-Member -MemberType NoteProperty -Name "LinkedTemplatesBaseUrl" -Value "[concat(parameters('LinkedTemplatesBaseUrl'), '/$($folder.Name)')]" -Force;
        $armTemplate.resources[$index].properties.parameters.LinkedTemplatesBaseUrl.value = "[concat(parameters('LinkedTemplatesBaseUrl'), '/$($folder.Name)')]";
    }

    #modify PolicyXMLBaseUrl in resources/properties/parameters
    $armTemplate.resources[$index].properties.parameters.PolicyXMLBaseUrl.value = "[concat(parameters('PolicyXMLBaseUrl'), '/$($folder.Name)/policies')]";

    #update name in resources
    $tempName = $folder.Name + "Template";
    $armTemplate.resources[$index].Name = $tempName

    #modify dependsOn if not first api record
    if (!$previousFolder.Equals("First")) {
        $tempString = $previousFolder + "Template"
        $temp = @($tempString);
        $armTemplate.resources[$index].dependsOn = $temp;
    }

    $previousFolder = $folder.Name;
    $index++;
}

$armTemplate | ConvertTo-Json -Depth 100 | foreach { [System.Text.RegularExpressions.Regex]::Unescape($_) } | Set-Content -Path $templatePath

<#
    Start Backends ARM Template Parameterization Fix
#>


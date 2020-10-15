<# Install Updates Pending in Software Center #>

$AppEvalState0 = "0"
$AppEvalState1 = "1"

$ApplicationClass = [WmiClass]"root\ccm\clientSDK:CCM_SoftwareUpdatesManager"

$computer = $env:COMPUTERNAME 

$Application = (Get-WmiObject -Namespace "root\ccm\clientSDK" -Class CCM_SoftwareUpdate -ComputerName $Computer | Where-Object { $_.EvaluationState -like "*$($AppEvalState0)*" -or $_.EvaluationState -like "*$($AppEvalState1)*"})

Write-Host $Application
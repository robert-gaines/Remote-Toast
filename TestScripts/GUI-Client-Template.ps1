<# GUI Management Client for the EndPoint Toast Project #>

function LoadAssemblies()
{
    [reflection.assembly]::loadwithpartialname(“System.Windows.Forms”) | Out-Null
    [reflection.assembly]::loadwithpartialname(“System.Drawing”)       | Out-Null
}

function GenerateForm()
{
    $formObject = New-Object System.Windows.Forms.Form

    $presentationState = New-Object System.Windows.Forms.FormWindowState
}

function main()
{
    GenerateForm
}

main
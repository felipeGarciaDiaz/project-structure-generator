

$defaultPath = Get-Location
$projectPath = Read-Host "Enter the project path (Press Enter for default: $defaultPath)"


if (-not $projectPath) { $projectPath = $defaultPath }


if (!(Test-Path $projectPath)) {
    Write-Output "Errors: Project path '$projectPath' does not exist."
    exit
}



function Get-FolderArchitecture {
    param ($path)

    $structure = @{}

    $items = Get-ChildItem -Path $path -Force | Where-Object {
        $_.PSIsContainer -or ($_.FullName -notmatch "\\node_modules\\" -and $_.FullName -notmatch "\\.git\\objects\\")

    }

    foreach ($item in $items) {
        if ($item.PSIsContainer) {
            if ($item.Name -eq "node_modules" -or ($item.FullName -match "\\\.git\\objects$")) {
                $structure[$item.Name] = "[Folder Hidden]"

            } else { $structure[$item.Name] = Get-FolderArchitecture -path $item.FullName }
        } else { $structure[$item.Name] = "[File]"}

    }




    return $structure
}



$projectStructure = @{}
$projectStructure[(Split-Path $ProjectPath -Leaf)] = Get-FolderArchitecture -path $projectPath
$jsonOutput = $projectStructure | ConvertTo-Json -Depth 10 -Compress:$false
$jsonOutput = $jsonOutput -replace '\[\s*"Folder Hidden"\s*\]', '"[Folder Hidden]"'
$jsonOutput = $jsonOutput -replace '\[\s*"File"\s*\]', '"[File]"'

$outputFile = "$projectPath\project_architecture.json"
$jsonOutput  | Out-File -Encoding utf8 $outputFile

Write-Output "Project architecture saved to: $outputFile"

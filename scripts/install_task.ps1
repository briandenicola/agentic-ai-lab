[CmdletBinding()]
param (
    [Parameter(Mandatory=$true)]
    [String]
    $INSTALL_DIR = "c:\\bin"
)

function Install-TaskManually {
    param (
        [Parameter(Mandatory=$true)]
        [String]
        $Path
    )
    if (-not (Test-Path -Path $Path)) {
        New-Item -ItemType Directory -Path $Path | Out-Null
    }

    $repo = "go-task/task"
    
    function get_latest_release() {
        $releases = Invoke-RestMethod "https://api.github.com/repos/$repo/releases/latest"         
        return $releases.tag_name
    }

    $VERSION = get_latest_release
    $download_link = "https://github.com/{0}/releases/download/{1}/task_windows_amd64.zip" -f $repo, $VERSION
    Write-Host "»»» 📦 Installing Task $VERSION..."
    Write-Host "»»» 🔗 Downloading from $download_link ..."
    Invoke-WebRequest -Uri $download_link -OutFile "$env:TEMP\task.zip"
    Expand-Archive -Path "$env:TEMP\task.zip" -DestinationPath $Path -Force
    Remove-Item "$env:TEMP\task.zip"
    
    Write-Host "»»» 📦 Task installed at $PATH ..."
    Get-ChildItem -Path $Path -Filter "task.exe"
    Write-Host "" 
    Write-Host "»»» 📦 Task Version installed: "
    & "$Path\task.exe" --version
}   

winget --version | Out-Null
if ($LASTEXITCODE -eq 0) {
    winget search Task.Task | Out-Null

    if ($LASTEXITCODE -eq 0) {
        Write-Host "»»» 📦 Installing Lastest Task version using `winget`..."
        winget install Task.Task
    } else {
        Install-TaskManually -Path $INSTALL_DIR
    }
}
else {
    Install-TaskManually -Path $INSTALL_DIR
}
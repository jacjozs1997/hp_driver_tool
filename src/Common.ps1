function Progress {
    param (
        $Title,
        [Parameter(Mandatory)]
        $JobName
    )
    $spinner = @("-----","\\\\\","|||||","/////")
    $oldPos = $host.UI.RawUI.CursorPosition
    [System.Console]::CursorVisible = $False
    do { 
        $spin = 0
        do {
            [Console]::CursorLeft = 0; [Console]::CursorTop = $oldPos.Y
            Write-Host $spinner[$spin] " $title " $spinner[$spin] -fore Cyan
            Start-Sleep -m 100; $spin++
        }
        while ($spin -ne 4)
    }
    while ((Get-Job -name $jobName).State -eq "Running")
    $host.UI.RawUI.CursorPosition = $oldPos
    [System.Console]::CursorVisible = $True
    Write-Host "                                                 "
}
Import-Module '.\src\Modules\PSMenu\0.2.0\PSMenu.psm1'
. .\src\Models\ApiRequest.ps1

[ApiRequest] $ApiRequest = $null;
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
while ($true) {
    Write-Host "----------------`t-----------------------------------------"
    $readProductNumber = Read-Host "PRODUCT NUMBER`t"
    # while (ValidateSerialNumber -InputSerialNumber $readProductNumber) {
    #     $readProductNumber = Read-Host "PRODUCT NUMBER`t"
    # }
    $ApiRequest = [ApiRequest]::new($readProductNumber);
    $rawUnit = $ApiRequest.QueryGet()
    if (!$rawUnit) {
        #TODO Message
        continue
    }
    
}
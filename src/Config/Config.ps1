class Config {
    [string] $Efi_Drive
    [bool] $OnlyWriteToEfiBoot
    [bool] $ImageEnabled
    [string] $APIServer

    Config() {
        try {
            $userConfig = (Get-Content -Path ".\config.json" -Raw | ConvertFrom-Json)

            $this.Efi_Drive = $userConfig.Efi_Drive
            $this.OnlyWriteToEfiBoot = $userConfig.OnlyWriteToEfiBoot
            $this.ImageEnabled = $userConfig.ImageEnabled
            $this.APIServer = $userConfig.APIServer
        }
        catch {
            <#Do this if a terminating exception happens#>
        }
    }
}
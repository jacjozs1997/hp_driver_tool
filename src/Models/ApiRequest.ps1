. .\src\Common.ps1
class ApiRequest {
    [string] $ProductNumber = $null
    [string] $ProductName = $null
    [int] $SeriesOid = $null
    [int] $NameOid = $null
    [int] $NumberOid = $null
    [string] $OsName = $null
    [string] $OsId = $null

    hidden static [hashtable] $RequestHeader = @{
      "Accept"="application/json"
      'Accept-Charset'= 'UTF-8'
      'Accept-Language'= 'hu,hu-HU;q=0.9,en;q=0.8'
      'Accept-Encoding'= 'gzip, deflate, br'
      "Content-Type"="application/json"
    }

  ApiRequest([string] $productNumber) {
    $this.ProductNumber = $productNumber;
  }

    [Object] QueryGet() { 
      # https://support.hp.com/typeahead?q=3D6S5EA&resultLimit=10&store=tmsstore&languageCode=hu,en&printFields=tmspmseriesvalue,tmspmnamevalue,tmspmnumbervalue,activewebsupportflag,description
      # Primary Request
      Start-Job -Name PrimaryHPRequest -ScriptBlock { 
        param(
            $ProductNumber)
        try {
            $result = [Text.Encoding]::UTF8.GetString((Invoke-WebRequest -Uri "https://support.hp.com/typeahead?q=$ProductNumber&resultLimit=1&store=tmsstore&languageCode=hu,en&printFields=tmspmseriesvalue,tmspmnamevalue,tmspmnumbervalue,activewebsupportflag,description" -Method Get).RawContentStream.ToArray()) | ConvertFrom-Json
        }
        catch {
            $result = $_
        }
        return $result;
      } -ArgumentList $this.ProductNumber | Receive-Job
      
      Progress -Title "Searching..." -JobName PrimaryHPRequest

      $result = Receive-Job -Id (Get-Job -Name PrimaryHPRequest).Id

      if ($result.matches.Length -ne 0) {
        $this.ProductName = $result.matches[0].description;
        $this.SeriesOid = $result.matches[0].pmSeriesOid;
        $this.NameOid = $result.matches[0].pmNameOid;
        $this.NumberOid = $result.matches[0].pmNumberOid;
        
        Write-Host "Found product: $($this.ProductName)";
      } else {
        Write-Host "No match product";
        return $null;
      }

      Start-Job -Name SecondaryHpRequest -ScriptBlock { 
        param(
            $NameOid,
            $Header)
        try {
            $result = [Text.Encoding]::UTF8.GetString((Invoke-WebRequest -Uri "https://support.hp.com/wcc-services/swd-v2/osVersionData?cc=hu&lc=hu&productOid=$NameOid" -Method Get -Headers $Header).RawContentStream.ToArray()) | ConvertFrom-Json
        }
        catch {
            $result = $_
        }
        return $result;
      } -ArgumentList $this.NameOid,(Invoke-Expression [ApiRequest]::RequestHeader) | Receive-Job

      Progress -Title "Gathering data..." -JobName SecondaryHpRequest
        
      $result = Receive-Job -Id (Get-Job -Name SecondaryHpRequest).Id

      if ($result.data.osversions.Length -ne 0) {
        $Opts = @()
        foreach ($osversion in $result.data.osversions) {
            $Opts += $osversion.name
        }
        $this.OsName = Show-Menu -MenuItems $Opts;
        Clear-Host
        foreach ($osversion in $result.data.osversions) {
          if ($osversion.name -eq $this.OsName) {
            $Opts = @()
            foreach ($osVersionInfo in $osversion.osVersionList) {
              $Opts += $([OsVersionOption]::new($osVersionInfo.name, $osVersionInfo.id));
            }
            $this.osId = (Show-Menu -MenuItems $Opts).Id
          }
        }
      } else {
        Write-Host "Not found os version";
        return $null;
      }

      Start-Job -Name ThirdHpRequest -ScriptBlock { 
        param(
            $OsId,
            $OsName,
            $NameOid,
            $NumberOid,
            $SeriesOid,
            $Header)
        try {
            $postParams = @{
              lc='hu';
              cc='hu';
              osTMSId=$OsId;
              osName=$OsName;
              productNumberOid=$NumberOid;
              productSeriesOid=$SeriesOid;
              platformId=$OsId;
              productNameOid=$NameOid;
            } | ConvertTo-Json;
            $result = [Text.Encoding]::UTF8.GetString((Invoke-WebRequest -Uri "https://support.hp.com/wcc-services/swd-v2/driverDetails" -Method POST -Body $postParams -Headers $Header).RawContentStream.ToArray()) | ConvertFrom-Json
        }
        catch {
            $result = $_
        }
        return $result;
      } -ArgumentList $this.OsId,$this.OsName,$this.NameOid,$this.NumberOid,$this.SeriesOid,(Invoke-Expression [ApiRequest]::RequestHeader) | Receive-Job

      Progress -Title "Gathering drives data..." -JobName ThirdHpRequest
        
      $result = Receive-Job -Id (Get-Job -Name ThirdHpRequest).Id
      Clear-Host
      foreach ($software in $result.data.softwareTypes) {
        Write-Host "$($software.accordionName)";
        foreach ($driver in $software.softwareDriversList) {
          Write-Host "`t$($driver.latestVersionDriver.title)`t$($driver.latestVersionDriver.version)";
        }
      }
      #$result.data.softwareTypes | Format-Table;
      return $result
    }
  }

  class OsVersionOption {

    [String]$DisplayName
    [String]$Id

    OsVersionOption([string]$DisplayName, [string]$Id) {
        $this.DisplayName = $DisplayName;
        $this.Id = $Id;
    }

    [String]ToString() {
        Return $This.DisplayName
    }
}
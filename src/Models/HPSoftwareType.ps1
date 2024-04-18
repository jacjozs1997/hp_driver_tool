class HPSoftwareType {
    [string] $AccordionName = $null
    [string] $AccordionNameEn = $null
    [SoftwareDriver[]] $SoftwareDriversList = @()

    HPSoftwareType($rawSoftwareData) {
        $this.AccordionName = $rawSoftwareData.accordionName
        $this.AccordionNameEn = $rawSoftwareData.accordionNameEn
        
        foreach ($driver in $rawSoftwareData.softwareDriversList)
        {
            $this.SoftwareDriversList += [SoftwareDriver]::new($driver)
        }
    }
}

class SoftwareDriver {
    [string] $Title = $null
    [string] $Version = $null
    [string] $VersionUpdatedDateString = $null
    [string] $FileSize = $null
    [string] $FileUrl = $null
    [string] $FileName = $null

    SoftwareDriver($rawSoftwareDriverData) {
        $this.Title = $rawSoftwareDriverData.title
        $this.Version = $rawSoftwareDriverData.version
        $this.VersionUpdatedDate = $rawSoftwareDriverData.versionUpdatedDateString
        $this.FileSize = $rawSoftwareDriverData.fileSize
        $this.FileUrl = $rawSoftwareDriverData.fileUrl
        $this.FileName = $rawSoftwareDriverData.detailInformation.fileName
    }
}
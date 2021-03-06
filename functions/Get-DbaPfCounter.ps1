﻿function Get-DbaPfCounter {
    <#
        .SYNOPSIS
            Gets Peformance Counters

        .DESCRIPTION
            Gets Peformance Counters

        .PARAMETER ComputerName
            The target computer. Defaults to localhost.

        .PARAMETER Credential
            Allows you to login to $ComputerName using alternative credentials.

        .PARAMETER CollectorSet
            The Collector Set name
  
        .PARAMETER Collector
            The Collector name
    
        .PARAMETER InputObject
            Enables piped results from Get-DbaPfDataCollectorSet

        .PARAMETER EnableException
            By default, when something goes wrong we try to catch it, interpret it and give you a friendly warning message.
            This avoids overwhelming you with "sea of red" exceptions, but is inconvenient because it basically disables advanced scripting.
            Using this switch turns this "nice by default" feature off and enables you to catch exceptions with your own try/catch.
    
        .NOTES
            Tags: PerfMon

            Website: https://dbatools.io
            Copyright: (C) Chrissy LeMaire, clemaire@gmail.com
            License: GNU GPL v3 https://opensource.org/licenses/GPL-3.0
    
        .LINK
            https://dbatools.io/Get-DbaPfCounter

        .EXAMPLE
            Get-DbaPfCounter
    
            Gets all counters for all collector sets on localhost

        .EXAMPLE
            Get-DbaPfCounter -ComputerName sql2017
    
             Gets all counters for all collector sets on  on sql2017
    
        .EXAMPLE
            Get-DbaPfCounter -ComputerName sql2017, sql2016 -Credential (Get-Credential) -CollectorSet 'System Correlation'
    
            Gets all counters for 'System Correlation' Collector on sql2017 and sql2016 using alternative credentials
    
        .EXAMPLE
            Get-DbaPfDataCollectorSet -CollectorSet 'System Correlation' | Get-DbaPfDataCollector | Get-DbaPfCounter
    
            Gets all counters for 'System Correlation' Collector
    #>
    [CmdletBinding()]
    param (
        [DbaInstance[]]$ComputerName = $env:COMPUTERNAME,
        [PSCredential]$Credential,
        [string[]]$CollectorSet,
        [string[]]$Collector,
        [parameter(ValueFromPipeline)]
        [object[]]$InputObject,
        [switch]$EnableException
    )
    begin {
        $columns = 'ComputerName', 'Name', 'DataCollectorSet', 'Counters', 'DataCollectorType', 'DataSourceName', 'FileName', 'FileNameFormat', 'FileNameFormatPattern', 'LatestOutputLocation', 'LogAppend', 'LogCircular', 'LogFileFormat', 'LogOverwrite', 'SampleInterval', 'SegmentMaxRecords'
    }
    process {
        if ($InputObject.Credential -and (Test-Bound -ParameterName Credential -Not)) {
            $Credential = $InputObject.Credential
        }
        
        if (-not $InputObject -or ($InputObject -and (Test-Bound -ParameterName ComputerName))) {
            foreach ($computer in $ComputerName) {
                $InputObject += Get-DbaPfDataCollector -ComputerName $computer -Credential $Credential -CollectorSet $CollectorSet -Collector $Collector
            }
        }
        
        if (-not $InputObject.CollectorXml) {
            Stop-Function -Message "InputObject is not of the right type. Please use Get-DbaPfDataCollector"
            return
        }
        
        foreach ($counterobject in $InputObject) {
            foreach ($countername in $counterobject.Counters) {
                if ($Counter -and $Counter -notcontains $countername) { continue }
                [pscustomobject]@{
                    ComputerName                     = $counterobject.ComputerName
                    DataCollectorSet                 = $counterobject.DataCollectorSet
                    DataCollector                    = $counterobject.Name
                    Name                             = $countername
                    FileName                         = $counterobject.FileName
                    DataCollectorSetObject           = $counterobject.DataCollectorSetObject
                    CounterObject                    = $counterobject
                    Credential                       = $Credential
                } | Select-DefaultView -ExcludeProperty DataCollectorSetObject, Credential, CounterObject
            }
        }
    }
}
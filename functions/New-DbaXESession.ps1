﻿function New-DbaXESession {
 <#
    .SYNOPSIS
    Creates a new XESession object - for the dogged.

    .DESCRIPTION
    Creates a new XESession object - for the dogged (very manual, Import-DbaXESession is recommended). See the following for more info:

    https://docs.microsoft.com/en-us/sql/relational-databases/extended-events/use-the-powershell-provider-for-extended-events

    .PARAMETER SqlInstance
    The SQL Instances that you're connecting to.

    .PARAMETER SqlCredential
    Credential object used to connect to the SQL Server as a different user

    .PARAMETER Name
    The Name of the session

    .PARAMETER EnableException
    By default, when something goes wrong we try to catch it, interpret it and give you a friendly warning message.
    This avoids overwhelming you with "sea of red" exceptions, but is inconvenient because it basically disables advanced scripting.
    Using this switch turns this "nice by default" feature off and enables you to catch exceptions with your own try/catch.

    .NOTES
    Website: https://dbatools.io
    Copyright: (C) Chrissy LeMaire, clemaire@gmail.com
    License: GNU GPL v3 https://opensource.org/licenses/GPL-3.0

    .LINK
    https://dbatools.io/New-DbaXESession

    .EXAMPLE
    $session = New-DbaXESession -SqlInstance sql2017
    $event = $session.AddEvent("sqlserver.file_written")
    $event.AddAction("package0.callstack")
    $session.Create()

    Returns a new XE Session object from sql2017 then adds an event, an action then creates it.

#>
    [CmdletBinding()]
    param (
        [parameter(Mandatory, ValueFromPipeline)]
        [Alias("ServerInstance", "SqlServer")]
        [DbaInstanceParameter[]]$SqlInstance,
        [PSCredential]$SqlCredential,
        [parameter(Mandatory)]
        [string]$Name,
        [switch]$EnableException
    )
    process {
        foreach ($instance in $SqlInstance) {
            try {
                Write-Message -Level Verbose -Message "Connecting to $instance"
                $server = Connect-SqlInstance -SqlInstance $instance -SqlCredential $SqlCredential -MinimumVersion 11
            }
            catch {
                Stop-Function -Message "Failure" -Category ConnectionError -ErrorRecord $_ -Target $instance -Continue
            }

            $SqlConn = $server.ConnectionContext.SqlConnectionObject
            $SqlStoreConnection = New-Object Microsoft.SqlServer.Management.Sdk.Sfc.SqlStoreConnection $SqlConn
            $store = New-Object  Microsoft.SqlServer.Management.XEvent.XEStore $SqlStoreConnection

            $store.CreateSession($Name)
        }
    }
}
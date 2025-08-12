function Connect-MgIfNecessary {

    <#
    .Synopsis
        Ensures you are connected to Microsoft Graph with the 'Chat.Read' scope.
    .DESCRIPTION
        Checks if the current PowerShell session is connected to Microsoft Graph 
        with the necessary permissions (default: Chat.Read).

        If not connected, or if the required scope is missing, 
        attempts to connect using Connect-MgGraph.
        
        If Azure CLI is installed and logged in, 
        uses the current logged-in tenant ID for the connection.
        (TODO:  maybe parameterize whether that's actually desired behavior.)
    .EXAMPLE
        Connect-MgIfNecessary

        Should return $true to indicate that it is now connected.
        (Handy for Pester tests; not for much else.)
    .NOTES
        Author: Katie Kodes
        Date: 2025-08-12
        Company: Katie Kodes
    #>

    Begin {} # end BEGIN

    Process {
        $az_cli_installed = Get-Command 'az' -ErrorAction 'SilentlyContinue'
        $az_currently_logged_in_tenant_id = $null
        if ($az_cli_installed) {
            $az_currently_logged_in_tenant_id = az account show --query 'tenantId' --output 'tsv'
        }
        $connect_mg_parameters = @{
            Scopes = 'Chat.Read'
        }
        if ($az_currently_logged_in_tenant_id) {
            $connect_mg_parameters.TenantId = $az_currently_logged_in_tenant_id
        }
        $existing_context = Get-MgContext
        $existing_scopes = $existing_context.Scopes
        if ( `
                -not $existing_context `
                -or -not $existing_scopes `
                -or -not $existing_scopes -contains 'Chat.Read' `
        ) {
            Connect-MgGraph @connect_mg_parameters
            Write-Output([bool](Get-MgContext))
        }
        else {
            Write-Output($false)
        }
        
    } # end PROCESS

    End {} # end END

} #End Connect-MgIfNecessary
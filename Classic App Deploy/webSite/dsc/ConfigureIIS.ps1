Configuration SH360Website
{
	param
	(
		[Parameter(Mandatory)]
        [System.Management.Automation.PSCredential] $AppPoolCredential,

		[Parameter(Mandatory)]
		[string]$SH360FilesSAName,

		[Parameter(Mandatory)]
		[string]$SH360FilesSAKey,

		[Parameter(Mandatory)]
		[string]$SH360FilesContainerName,

		[Parameter(Mandatory)]
		[string]$SiteName,

		[Parameter(Mandatory)]
		[array]$ConfigReplacements,

		[Parameter(Mandatory)]
		[string]$AIKey
	)

	Import-DscResource -ModuleName xWebAdministration

    Import-DscResource -Module cAzureStorage  -ModuleVersion 1.0.0.1

  Node localhost
  {
    #Install the IIS Role
    WindowsFeature IIS
    {
      Ensure = “Present”
      Name = “Web-Server”
    }

    #Install ASP.NET 4.5
    WindowsFeature ASP
    {
      Ensure = “Present”
      Name = “Web-Asp-Net45”
    }

    WindowsFeature WebServerManagementConsole
    {
        Name = "Web-Mgmt-Console"
        Ensure = "Present"
    }

    WindowsFeature WebScriptingTools
    {
        Name = "Web-Scripting-Tools"
        Ensure = "Present"
        DependsOn = "[WindowsFeature]IIS"
    }

    WindowsFeature HttpActivation
    {
        Name = "NET-WCF-HTTP-Activation45"
        Ensure = "Present"
    }

    xWebAppPool CreateIisPool
    {
        Name = "sh360Pool"
        AutoStart = $true
        ManagedPipelineMode = "Integrated"
        ManagedRuntimeVersion = "v4.0"
        IdentityType = "SpecificUser"
        Credential = $AppPoolCredential
        Enable32BitAppOnWin64 = $false
    }

    cAzureStorage CopyFiles 
    {
        Path = "C:\inetpub\wwwroot\"
        StorageAccountName = $SH360FilesSAName
        StorageAccountContainer = $SH360FilesContainerName
        StorageAccountKey = $SH360FilesSAKey
        Blob = $SiteName
	}

#    Script AddRedirect
#    {
#        SetScript = {
#		Set-Content -Path 'C:\inetpub\wwwroot\Default.htm' -Value "<html><script language=""JavaScript"">window.location = window.location + ""$using:SiteName/"";</script></html>"
#		}
#        TestScript = { Test-Path "C:\inetpub\wwwroot\Default.htm" }
#        GetScript = { @{ } }
#        DependsOn = "[cAzureStorage]CopyFiles"
#    }

    Script ModifyWebConfig
    {
        SetScript = { 
			$configPath = "C:\inetpub\wwwroot\$using:SiteName\Web.config"
			$xml = [xml](Get-Content $configPath)
			foreach($replacement in $using:ConfigReplacements)
			{
				$node = $xml.SelectSingleNode($replacement.ConfigXPath)
				if($node -eq $null -or $node.NodeType -eq [System.Xml.XmlNodeType]::Element)
				{
					if($node -ne $null)
					{
						$node.ParentNode.RemoveChild($node)
					}
					$parentPath = (Split-Path $replacement.ConfigXPath -Parent) -replace '\\', '/'
					$nodeName = Split-Path $replacement.ConfigXPath -Leaf
					$parent = $xml.SelectSingleNode($parentPath)
					$node = $xml.ImportNode(([xml]$replacement.ConfigValue).DocumentElement, $true)
					$parent.AppendChild($node)
				}
				else
				{
					$node.Value = $replacement.ConfigValue
				}
			}
			$xml.Save($configPath)
		}
        TestScript = { $false }
        GetScript = { @{ } }
        DependsOn = "[cAzureStorage]CopyFiles"
    }

    Script ModifyAIConfig
    {
        SetScript = { 
			"$using:AIKey"|Set-Content "D:\aikey.txt"
			$configPath = "C:\inetpub\wwwroot\$using:SiteName\ApplicationInsights.config"
			if(Test-Path $configPath)
			{
				$xml = [xml](Get-Content $configPath)

				if($xml.ApplicationInsights.InstrumentationKey -eq $null)
				{
					$xml.ApplicationInsights.AppendChild($xml.CreateNode([System.Xml.XmlNodeType]::Element, 'InstrumentationKey', $xml.ApplicationInsights.NamespaceURI)).InnerText="$using:AIKey"
				}
				($xml.ApplicationInsights.ChildNodes|where Name -EQ "InstrumentationKey").InnerText = "$using:AIKey"
				$xml.Save($configPath)
			}
		}
        TestScript = { $false }
        GetScript = { @{ } }
        DependsOn = "[cAzureStorage]CopyFiles"
    }

	xWebSite CreateWebSite
	{
		Name = "Default Web Site"
		PhysicalPath = "C:\inetpub\wwwroot\$SiteName"
		ApplicationPool = "sh360Pool"
        DependsOn = "[Script]ModifyWebConfig"
	}

#	xWebApplication CreateWebApp
#	{
#		Name = $SiteName
#		Website = "Default Web Site"
#		WebAppPool = "sh360Pool"
#		PhysicalPath = "C:\inetpub\wwwroot\$SiteName"
#        DependsOn = "[Script]ModifyWebConfig"
#	}

  }
}
#Requires -RunAsAdministrator

[CmdletBinding(SupportsShouldProcess)]
param 
(
    [Parameter(ValueFromPipeline = $true)][switch]$RunDefaults,
    [Parameter(ValueFromPipeline = $true)][switch]$RunWin11Defaults,
    [Parameter(ValueFromPipeline = $true)][switch]$RemoveApps,
    [Parameter(ValueFromPipeline = $true)][switch]$DisableTelemetry,
    [Parameter(ValueFromPipeline = $true)][switch]$DisableBingSearches,
    [Parameter(ValueFromPipeline = $true)][switch]$DisableBing,
    [Parameter(ValueFromPipeline = $true)][switch]$DisableLockscreenTips,
    [Parameter(ValueFromPipeline = $true)][switch]$DisableWindowsSuggestions,
    [Parameter(ValueFromPipeline = $true)][switch]$DisableSuggestions,
    [Parameter(ValueFromPipeline = $true)][switch]$DisableChat,
    [Parameter(ValueFromPipeline = $true)][switch]$DisableWidgets,
    [Parameter(ValueFromPipeline = $true)][switch]$DisableOnedrive,
    [Parameter(ValueFromPipeline = $true)][switch]$Disable3dObjects,
    [Parameter(ValueFromPipeline = $true)][switch]$DisableMusic,
    [Parameter(ValueFromPipeline = $true)][switch]$DisableIncludeInLibrary,
    [Parameter(ValueFromPipeline = $true)][switch]$DisableGiveAccessTo,
    [Parameter(ValueFromPipeline = $true)][switch]$DisableShare
)

# Removes all apps in the list
function RemoveApps {
    Write-Output "> Removing pre-installed windows apps..."

    $apps = @(
        # These apps will be uninstalled by default:
        #
        # If you wish to KEEP any of the apps below simply add a # character
        # in front of the specific app in the list below.
        "*AdobeSystemsIncorporated.AdobePhotoshopExpress*"
        "*Clipchamp.Clipchamp*"
        "*Dolby*"
        "*Duolingo-LearnLanguagesforFree*"
        "*Facebook*"
        "*Flipboard*"
        "*HULULLC.HULUPLUS*"
        "*Microsoft.3DBuilder*"
        "*Microsoft.549981C3F5F10*"   #Cortana app
        "*Microsoft.Asphalt8Airborne*"
        "*Microsoft.BingFinance*"
        "*Microsoft.BingNews*"
        "*Microsoft.BingSports*"
        "*Microsoft.BingTranslator*"
        "*Microsoft.BingWeather*"
        "*Microsoft.GetHelp*"
        "*Microsoft.Getstarted*"   # Cannot be uninstalled in Windows 11
        "*Microsoft.Messaging*"
        "*Microsoft.Microsoft3DViewer*"
        "*Microsoft.MicrosoftOfficeHub*"
        "*Microsoft.MicrosoftSolitaireCollection*"
        "*Microsoft.MicrosoftStickyNotes*"
        "*Microsoft.MixedReality.Portal*"
        "*Microsoft.NetworkSpeedTest*"
        "*Microsoft.News*"
        "*Microsoft.Office.OneNote*"
        "*Microsoft.Office.Sway*"
        "*Microsoft.OneConnect*"
        "*Microsoft.Print3D*"
        "*Microsoft.RemoteDesktop*"
        "*Microsoft.SkypeApp*"
        "*Microsoft.Todos*"
        "*Microsoft.WindowsAlarms*"
        "*Microsoft.WindowsFeedbackHub*"
        "*Microsoft.WindowsMaps*"
        "*Microsoft.WindowsSoundRecorder*"
        "*Microsoft.ZuneMusic*"
        "*Microsoft.ZuneVideo*"
        "*PandoraMediaInc*"
        "*PICSART-PHOTOSTUDIO*"
        "*Royal Revolt*"
        "*Speed Test*"
        "*Spotify*"
        "*Twitter*"
        "*Wunderlist*"
        "*king.com.BubbleWitch3Saga*"
        "*king.com.CandyCrushSaga*"
        "*king.com.CandyCrushSodaSaga*"
        


        # These apps will NOT be uninstalled by default:
        # 
        # If you wish to REMOVE any of the apps below simply remove the # character
        # in front of the specific app in the list below.
        #"*Microsoft.GamingApp*"
        #"*Microsoft.MSPaint*"   # Paint 3D
        #"*Microsoft.People*"
        #"*Microsoft.PowerAutomateDesktop*"
        #"*Microsoft.ScreenSketch*"
        #"*Microsoft.Windows.Photos*"
        #"*Microsoft.WindowsCalculator*"
        #"*Microsoft.WindowsCamera*"
        #"*Microsoft.WindowsStore*"   # NOTE: This app cannot be reinstalled!
        #"*Microsoft.Xbox.TCUI*"
        #"*Microsoft.XboxApp*"
        #"*Microsoft.XboxGameOverlay*"
        #"*Microsoft.XboxGamingOverlay*"
        #"*Microsoft.XboxIdentityProvider*"
        #"*Microsoft.XboxSpeechToTextOverlay*"   # NOTE: This app may not be able to be reinstalled!
        #"*Microsoft.YourPhone*"
        #"*microsoft.windowscommunicationsapps*"   # Mail & Calendar
    )

    foreach ($app in $apps) {
        Write-Output "Attempting to remove $app"

        Get-AppxPackage -Name $app -AllUsers | Remove-AppxPackage

        Get-AppxProvisionedPackage -Online | Where-Object { $_.PackageName -like $app } | ForEach-Object { Remove-ProvisionedAppxPackage -Online -AllUsers -PackageName $_.PackageName }
    }
}

# Import & execute regfile
function RegImport {
    param 
    (
        $Message,
        $Path
    )

    Write-Output $Message
    reg import $path
}

# Change mode based on provided parameters or user input
if ((-NOT $PSBoundParameters.Count) -or $RunDefaults -or $RunWin11Defaults -or (($PSBoundParameters.Count -eq 1) -and ($PSBoundParameters.ContainsKey('WhatIf') -or $PSBoundParameters.ContainsKey('Confirm') -or $PSBoundParameters.ContainsKey('Verbose')))) {
    if ($RunDefaults) {
        $Mode = '1';
    }
    elseif ($RunWin11Defaults) {
        $Mode = '2';
    }
    else {
        Do { 
            Clear-Host
            Write-Output "-------------------------------------------------------------------------------------------"
            Write-Output " Universal Windows Debloater Script - Setup"
            Write-Output "-------------------------------------------------------------------------------------------"
            Write-Output "(1) Run Universal Windows Debloater with the Windows 10 default settings"
            Write-Output "(2) Run Universal Windows Debloater with the Windows 11 default settings"
            Write-Output "(3) Custom mode: Select which changes you want Universal Windows Debloater to make"
            Write-Output ""
            Write-Output "(0) Show information about the script"
            Write-Output ""
			Write-Output "Copyrights @ Samuel Jayasingh"

            $Mode = Read-Host "Please select an option (1/2/3/0)" 
		    
            if ($Mode -eq '0') {
                Clear-Host
                Write-Output "-------------------------------------------------------------------------------------------"
                Write-Output " Win10Debloat - Information"
                Write-Output "-------------------------------------------------------------------------------------------"
                Write-Output "Win10Debloat is a simple and lightweight powershell script that removes pre-installed"
                Write-Output "windows 10/11 bloatware apps, disables telemetry and declutters the experience by disabling"
                Write-Output "or removing intrusive interface elements, ads and context menu items. No need to"
                Write-Output "painstakingly go through all the settings yourself, or removing apps one by one!"
                Write-Output ""
                Write-Output "-------------------------------------------------------------------------------------------"
                Write-Output " Windows 10 default settings will:"
                Write-Output "-------------------------------------------------------------------------------------------"
                Write-Output "- Remove bloatware apps, full list can be found on github. (github.com/raphire/win10debloat)"
                Write-Output "- Disable telemetry, diagnostic data & targeted ads."
                Write-Output "- Disable bing search & cortana in windows search."
                Write-Output "- Disable tips & tricks on the lockscreen. (This may change your lockscreen wallpaper to the default)"
                Write-Output "- Disable tips, tricks and suggestions in the startmenu and settings, and ads in windows explorer."
                Write-Output "- Hide the Chat (meet now) & Widget (news and interests) icons from the taskbar."
                Write-Output "- Hide the 3D objects folder under 'This pc' in windows explorer."
                Write-Output "- Disable the 'Include in library' from context menu."
                Write-Output "- Disable the 'Give access to' from context menu."
                Write-Output "- Disable the 'Share' from context menu. (Does not remove the onedrive share option)"
                Write-Output ""
                Write-Output "-------------------------------------------------------------------------------------------"
                Write-Output " Windows 11 default settings will:"
                Write-Output "-------------------------------------------------------------------------------------------"
                Write-Output "- Remove bloatware apps, full list can be found on github. (github.com/raphire/win10debloat)"
                Write-Output "- Disable telemetry, diagnostic data & targeted ads."
                Write-Output "- Disable bing search, bing AI & cortana in windows search."
                Write-Output "- Disable tips & tricks on the lockscreen. (This may change your lockscreen wallpaper to the default)"
                Write-Output "- Disable tips, tricks and suggestions in the startmenu and settings, and ads in windows explorer."
                Write-Output "- Hide the Chat & Widget icons from the taskbar."
                Write-Output ""
                Write-Output ""
                Write-Output "Press any key to go back..."
                $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
            }
        }
        while ($Mode -ne '1' -and $Mode -ne '2' -and $Mode -ne '3') 
    }

    # Add execution parameters based on the mode
    switch ($Mode) {
        '1' { 
            Clear-Host
            Write-Output "-------------------------------------------------------------------------------------------"
            Write-Output " Universal Windows Debloater Script - Windows 10 Default Configuration"
            Write-Output "-------------------------------------------------------------------------------------------"
            $PSBoundParameters.Add('RemoveApps', $RemoveApps) 
            $PSBoundParameters.Add('DisableTelemetry', $DisableTelemetry)  
            $PSBoundParameters.Add('DisableBing', $DisableBing) 
            $PSBoundParameters.Add('DisableLockscreenTips', $DisableLockscreenTips)  
            $PSBoundParameters.Add('DisableSuggestions', $DisableSuggestions)  
            $PSBoundParameters.Add('DisableChat', $DisableChat) 
            $PSBoundParameters.Add('DisableWidgets', $DisableWidgets) 
            $PSBoundParameters.Add('Disable3dObjects', $Disable3dObjects)   
            $PSBoundParameters.Add('DisableIncludeInLibrary', $DisableIncludeInLibrary)   
            $PSBoundParameters.Add('DisableGiveAccessTo', $DisableGiveAccessTo)  
            $PSBoundParameters.Add('DisableShare', $DisableShare)  
        }

        '2' { 
            Clear-Host
            Write-Output "-------------------------------------------------------------------------------------------"
            Write-Output " Universal Windows Debloater Script - Windows 11 Default Configuration"
            Write-Output "-------------------------------------------------------------------------------------------"
            $PSBoundParameters.Add('RemoveApps', $RemoveApps) 
            $PSBoundParameters.Add('DisableTelemetry', $DisableTelemetry)  
            $PSBoundParameters.Add('DisableBing', $DisableBing) 
            $PSBoundParameters.Add('DisableLockscreenTips', $DisableLockscreenTips)  
            $PSBoundParameters.Add('DisableSuggestions', $DisableSuggestions) 
            $PSBoundParameters.Add('DisableChat', $DisableChat) 
            $PSBoundParameters.Add('DisableWidgets', $DisableWidgets) 
        }

        '3' { 
            Clear-Host
            Write-Output "-------------------------------------------------------------------------------------------"
            Write-Output " Universal Windows Debloater - Custom Configuration"
            Write-Output "-------------------------------------------------------------------------------------------"

            if ($( Read-Host -Prompt "Remove the pre-installed windows apps? (y/n)" ) -eq 'y') {
                $PSBoundParameters.Add('RemoveApps', $RemoveApps)   
            }

            if ($( Read-Host -Prompt "Disable telemetry, diagnostic data and targeted ads? (y/n)" ) -eq 'y') {
                $PSBoundParameters.Add('DisableTelemetry', $DisableTelemetry)   
            }

            if ($( Read-Host -Prompt "Disable bing search, bing AI & cortana in windows search? (y/n)" ) -eq 'y') {
                $PSBoundParameters.Add('DisableBing', $DisableBing)   
            }

            if ($( Read-Host -Prompt "Disable tips & tricks on the lockscreen? (y/n)" ) -eq 'y') {
                $PSBoundParameters.Add('DisableLockscreenTips', $DisableLockscreenTips)   
            } 

            if ($( Read-Host -Prompt "Disable tips, tricks and suggestions in the startmenu and settings, and ads in windows explorer? (y/n)" ) -eq 'y') {
                $PSBoundParameters.Add('DisableSuggestions', $DisableSuggestions)   
            }

            if ($( Read-Host -Prompt "Do you want to hide any icons from the taskbar? (y/n)" ) -eq 'y') {
                if ($( Read-Host -Prompt "Hide the chat (meet now) icon on the taskbar? (y/n)" ) -eq 'y') {
                    $PSBoundParameters.Add('DisableChat', $DisableChat)   
                }

                if ($( Read-Host -Prompt "Hide the widget (news and interests) icon on the taskbar? (y/n)" ) -eq 'y') {
                    $PSBoundParameters.Add('DisableWidgets', $DisableWidgets)   
                }
            }

            if ($( Read-Host -Prompt "Do you want to hide any folders from the windows explorer sidepanel? (y/n)" ) -eq 'y') {
                if ($( Read-Host -Prompt "Hide the onedrive folder in windows explorer? (y/n)" ) -eq 'y') {
                    $PSBoundParameters.Add('DisableOnedrive', $DisableOnedrive)   
                }

                # Only show option for disabling these specific folders in windows 10
                if (get-ciminstance -query "select caption from win32_operatingsystem where caption like '%Windows 10%'"){
                    if ($( Read-Host -Prompt "Hide the 3D objects folder in windows explorer? (y/n)" ) -eq 'y') {
                        $PSBoundParameters.Add('Disable3dObjects', $Disable3dObjects)   
                    }

                    if ($( Read-Host -Prompt "Hide the music folder in windows explorer? (y/n)" ) -eq 'y') {
                        $PSBoundParameters.Add('DisableMusic', $DisableMusic)   
                    }
                }
            }

            # Only show option for disabling context menu items in windows 10
            if (get-ciminstance -query "select caption from win32_operatingsystem where caption like '%Windows 10%'"){
                if ($( Read-Host -Prompt "Do you want to disable any context menu options? (y/n)" ) -eq 'y') {
                    if ($( Read-Host -Prompt "Disable the 'Include in library' option in the context menu? (y/n)" ) -eq 'y') {
                        $PSBoundParameters.Add('DisableIncludeInLibrary', $DisableIncludeInLibrary)   
                    }

                    if ($( Read-Host -Prompt "Disable the 'Give access to' option in the context menu? (y/n)" ) -eq 'y') {
                        $PSBoundParameters.Add('DisableGiveAccessTo', $DisableGiveAccessTo)   
                    }

                    if ($( Read-Host -Prompt "Disable the 'Share' option in the context menu? (y/n)" ) -eq 'y') {
                        $PSBoundParameters.Add('DisableShare', $DisableShare)   
                    }
                }
            }

            Write-Output "" 
        }
    }
}
else {
    Clear-Host
    Write-Output "-------------------------------------------------------------------------------------------"
    Write-Output " Universal Windows Debloater - Custom Configuration"
    Write-Output "-------------------------------------------------------------------------------------------"
}

# Execute all selected/provided parameters
switch ($PSBoundParameters.Keys) {
    'RemoveApps' {
        RemoveApps
    }
    'DisableTelemetry' {
        RegImport "> Disabling telemetry, diagnostic data and targeted ads..." $PSScriptRoot\Regfiles\Disable_Telemetry.reg
    }
    'DisableBingSearches' {
        RegImport "> Disabling bing search, bing AI & cortana in windows search..." $PSScriptRoot\Regfiles\Disable_Bing_Cortana_In_Search.reg
    }
    'DisableBing' {
        RegImport "> Disabling bing search, bing AI & cortana in windows search..." $PSScriptRoot\Regfiles\Disable_Bing_Cortana_In_Search.reg
    }
    'DisableLockscreenTips' {
        RegImport "> Disabling tips & tricks on the lockscreen..." $PSScriptRoot\Regfiles\Disable_Lockscreen_Tips.reg
    }
    'DisableWindowsSuggestions' {
        RegImport "> Disabling tips, tricks and suggestions in the startmenu and settings, and ads in windows explorer..." $PSScriptRoot\Regfiles\Disable_Windows_Suggestions.reg
    }
    'DisableSuggestions' {
        RegImport "> Disabling tips, tricks and suggestions in the startmenu and settings, and ads in windows explorer..." $PSScriptRoot\Regfiles\Disable_Windows_Suggestions.reg
    }
    'DisableChat' {
        RegImport "> Hiding the chat icon on the taskbar..." $PSScriptRoot\Regfiles\Disable_Chat_Taskbar.reg
    }
    'DisableWidgets' {
        RegImport "> Hiding the widget icon on the taskbar..." $PSScriptRoot\Regfiles\Disable_Widgets_Taskbar.reg
    }
    'DisableOnedrive' {
        RegImport "> Hiding the onedrive folder in windows explorer..." $PSScriptRoot\Regfiles\Hide_Onedrive_Folder.reg
    }
    'Disable3dObjects' {
        RegImport "> Hiding the 3D objects folder in windows explorer..." $PSScriptRoot\Regfiles\Hide_3D_Objects_Folder.reg
    }
    'DisableMusic' {
        RegImport "> Hiding the music folder in windows explorer..." $PSScriptRoot\Regfiles\Hide_Music_folder.reg
    }
    'DisableIncludeInLibrary' {
        RegImport "> Disabling 'Include in library' in the context menu..." $PSScriptRoot\Regfiles\Disable_Include_in_library_from_context_menu.reg
    }
    'DisableGiveAccessTo' {
        RegImport "> Disabling 'Give access to' in the context menu..." $PSScriptRoot\Regfiles\Disable_Give_access_to_context_menu.reg
    }
    'DisableShare' {
        RegImport "> Disabling 'Share' in the context menu..." $PSScriptRoot\Regfiles\Disable_Share_from_context_menu.reg
    }
}

Write-Output ""
Write-Output "Script completed! Please restart your PC to make sure all changes are properly applied."
Write-Output ""
Write-Output ""
Write-Output "Press any key to continue..."
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")

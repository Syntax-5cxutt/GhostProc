@echo off
title Ottimizzazioni Avanzate di Sistema e Rete
color 1F

echo ================================================
echo     Avvio delle ottimizzazioni di sistema...
echo ================================================
echo.

:: 🛡️ Controllo privilegi
whoami /groups | find "S-1-5-32-544" >nul
if errorlevel 1 (
    echo Devi eseguire questo script come amministratore!
    pause
    exit /b
)

:: ---------------- SEZIONE 1: COMANDI CMD ----------------
echo Esecuzione comandi di rete...

ipconfig /flushdns
netsh winsock reset
netsh int tcp set heuristics disabled
netsh int tcp set global autotuninglevel=disabled
netsh int tcp set global congestionprovider=ctcp
netsh interface ipv6 set teredo disabled
netsh interface ipv6 set global disablepathmtudiscovery=enabled
netsh int tcp set global ecncapability=enabled
netsh interface ipv4 set subinterface "Ethernet" mtu=1500 store=persistent
netsh interface ipv4 set interface "Ethernet" dscp=46
netsh int tcp set global maxsynretries=2
netsh int tcp set global timewaitdelay=30
netsh int tcp set global tcpglobalbacklog=65535
netsh int tcp set global quickack=enabled
netsh int tcp set global rcvwindow=65536
netsh interface ipv4 set interface "Ethernet" forwarding=enabled
netsh interface ipv6 set interface "Ethernet" disabled
fsutil behavior set disablecompression 1
netsh int tcp set global initialRto=2000
netsh int tcp set global rsc=disabled
netsh int tcp set global chimney=disabled
netsh int tcp set global dca=enabled
netsh int tcp set global netdma=disabled
netsh int tcp set global timestamps=disabled
netsh int tcp set global nonsackrttresiliency=disabled
netsh int tcp set global rss=enabled
netsh interface tcp set global fastopen=enabled
netsh interface tcp set global prr=enabled
netsh interface tcp set global pacingprofile=slowstart
netsh interface tcp set global hystart=enabled
netsh int ipv4 set dynamicport tcp start=10000 num=55535
netsh int ipv4 set dynamicport udp start=10000 num=55535
bcdedit /set bootux disabled
bcdedit /set tscsyncpolicy enhanced
bcdedit /set uselegacyapicmode No
bcdedit /deletevalue useplatformclock
bcdedit /deletevalue useplatformtick
netsh interface isatap set state disabled

echo Comandi CMD completati.
echo.




:: ---------------- SEZIONE 2: MODIFICHE AL REGISTRO ----------------

echo Applicazione tweaks al registro...

:: Alcuni valori esadecimali sono stati convertiti in decimale (es. 0xFFFFFFFF → 4294967295)

reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile" /v NetworkThrottlingIndex /t REG_DWORD /d 4294967295 /f
reg add "HKLM\SYSTEM\CurrentControlSet\Services\LanmanServer\Parameters" /v autodisconnect /t REG_DWORD /d 4294967295 /f
reg add "HKLM\SYSTEM\CurrentControlSet\Services\LanmanServer\Parameters" /v Size /t REG_DWORD /d 3 /f
reg add "HKLM\SYSTEM\CurrentControlSet\Services\LanmanServer\Parameters" /v EnableOplocks /t REG_DWORD /d 0 /f
reg add "HKLM\SYSTEM\CurrentControlSet\Services\LanmanServer\Parameters" /v IRPStackSize /t REG_DWORD /d 32 /f
reg add "HKLM\SYSTEM\CurrentControlSet\Services\LanmanServer\Parameters" /v SharingViolationDelay /t REG_DWORD /d 0 /f
reg add "HKLM\SYSTEM\CurrentControlSet\Services\LanmanServer\Parameters" /v SharingViolationRetries /t REG_DWORD /d 1 /f
reg add "HKLM\SYSTEM\CurrentControlSet\Control\PriorityControl" /v ConvertibleSlateMode /t REG_DWORD /d 0 /f
reg add "HKLM\SYSTEM\CurrentControlSet\Control\PriorityControl" /v Win32PrioritySeparation /t REG_DWORD /d 56 /f
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\Psched" /v NonBestEffortLimit /t REG_DWORD /d 0 /f
reg add "HKLM\SYSTEM\CurrentControlSet\Control\GraphicsDrivers" /v HwSchMode /t REG_DWORD /d 2 /f
reg add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" /v TcpAckFrequency /t REG_DWORD /d 1 /f
reg add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" /v TCPNoDelay /t REG_DWORD /d 1 /f
reg add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\Interfaces" /v TcpAckFrequency /t REG_DWORD /d 1 /f
reg add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\Interfaces" /v TCPDelAckTicks /t REG_DWORD /d 1 /f
reg add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\Interfaces" /v TCPNoDelay /t REG_DWORD /d 1 /f
reg add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\Interfaces" /v TcpIpDSCP /t REG_DWORD /d 28 /f
reg add "HKLM\SYSTEM\CurrentControlSet\Services\ServiceHost" /v Start /t REG_DWORD /d 2 /f
reg add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" /v PrioritizeLocalDns /t REG_DWORD /d 1 /f
reg add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" /v UDPSegmentationOffload /t REG_DWORD /d 1 /f
reg add "HKLM\SYSTEM\CurrentControlSet\Services\NetBT\Parameters\Interfaces\Tcpip_{GUID}" /v NetbiosOptions /t REG_DWORD /d 2 /f
reg add "HKLM\SYSTEM\CurrentControlSet\Services\Browser\Parameters" /v IsDomainMaster /t REG_SZ /d FALSE /f
reg add "HKLM\SYSTEM\CurrentControlSet\Services\LanmanServer\Parameters" /v SMB1 /t REG_DWORD /d 0 /f
reg add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" /v RSS /t REG_DWORD /d 0 /f
reg add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" /v EnableTCPChimney /t REG_DWORD /d 0 /f
reg add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" /v MaxUserPort /t REG_DWORD /d 65534 /f
reg add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" /v TcpTimedWaitDelay /t REG_DWORD /d 30 /f
reg add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" /v DisableTaskOffload /t REG_DWORD /d 1 /f
reg add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" /v EnableTcpFastOpen /t REG_DWORD /d 1 /f
reg add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" /v ECNCapability /t REG_DWORD /d 0 /f
reg add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\Interfaces\{GUID}" /v MTU /t REG_DWORD /d 1500 /f
reg add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" /v DisableLargeSendOffloadV2IPv4 /t REG_DWORD /d 1 /f
reg add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" /v DisableLargeSendOffloadV2IPv6 /t REG_DWORD /d 1 /f
reg add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\Interfaces\{GUID}" /v TcpNoDelay /t REG_DWORD /d 1 /f


:: Sezioni avanzate del registro (Performance, CPU, UX ecc.)

reg add "HKLM\SYSTEM\CurrentControlSet\Control\PriorityControl" /v IoPriorityCritical /t REG_DWORD /d 2 /f
reg add "HKLM\SYSTEM\CurrentControlSet\Control\PriorityControl" /v DynamicThreadCountEnabled /t REG_DWORD /d 0 /f
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Kernel" /v DisablePagingExecutive /t REG_DWORD /d 1 /f
reg add "HKLM\SYSTEM\CurrentControlSet\Services\CpuParkControl" /v StopOnIdleEnable /t REG_DWORD /d 0 /f
reg add "HKLM\SYSTEM\CurrentControlSet\Services\CpuParkControl" /v ParkControlRegisterState /t REG_DWORD /d 0 /f
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" /v LargeSystemCache /t REG_DWORD /d 1 /f
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" /v EnablePrefetcher /t REG_DWORD /d 0 /f
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" /v NtfsMemoryUsage /t REG_DWORD /d 2 /f
reg add "HKLM\SYSTEM\CurrentControlSet\Services\SysMain" /v Start /t REG_DWORD /d 4 /f
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager" /v AllocatePPINoMMU /t REG_DWORD /d 1 /f
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Power" /v HibernateEnabled /t REG_DWORD /d 0 /f
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Power\PowerSettings\8c5e7fd3-fe8a-4a6e-8cb4-395f79a70c12" /v ACSettingIndex /t REG_DWORD /d 0 /f
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Power\PowerSettings\6738e2c4-e8a5-4a42-b16a-e040e769756e" /v ACSettingIndex /t REG_DWORD /d 0 /f
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Class\{36fc9e60-c465-11cf-8056-444553540000}\0000" /v EnhancedPowerManagementEnabled /t REG_DWORD /d 0 /f
reg add "HKLM\SYSTEM\CurrentControlSet\Services\Processor\Parameters" /v DisableCStates /t REG_DWORD /d 1 /f
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Class\{4d36e972-e325-11ce-bfc1-08002be10318}\0001" /v PnPCapabilities /t REG_DWORD /d 36 /f
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Class\{4d36e972-e325-11ce-bfc1-08002be10318}\0002" /v PnPCapabilities /t REG_DWORD /d 36 /f
reg add "HKLM\SYSTEM\CurrentControlSet\Control" /v WaitToKillServiceTimeout /t REG_SZ /d 1000 /f
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Serialize" /v StartupDelayInMSec /t REG_DWORD /d 0 /f
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Power" /v HiberbootEnabled /t REG_DWORD /d 1 /f
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Power" /v FastBootInputReady /t REG_DWORD /d 1 /f
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Authentication\LogonUI" /v ShowTabletKeyboard /t REG_DWORD /d 0 /f
reg add "HKLM\SOFTWARE\Microsoft\Windows Search\Gather\Windows\SystemIndex" /v GatherLogs /t REG_DWORD /d 0 /f
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management\PrefetchParameters" /v EnableBootTrace /t REG_DWORD /d 0 /f
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" /v DisableEUDC /t REG_DWORD /d 1 /f
reg add "HKLM\SOFTWARE\Microsoft\Windows\Windows Error Reporting" /v Disabled /t REG_DWORD /d 1 /f
reg add "HKCU\Control Panel\Desktop" /v MenuShowDelay /t REG_SZ /d 0 /f
reg add "HKCU\Control Panel\Desktop" /v MenuFade /t REG_SZ /d 0 /f
reg add "HKCU\Control Panel\Desktop" /v ComboBoxAnimation /t REG_SZ /d 0 /f
reg add "HKCU\Software\Microsoft\Windows\DWM" /v Composition /t REG_DWORD /d 0 /f
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects" /v VisualFXSetting /t REG_DWORD /d 2 /f
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Framework" /v UseAcrylic /t REG_DWORD /d 0 /f
reg add "HKCU\Software\Microsoft\Windows\DWM" /v EnableAeroPeek /t REG_DWORD /d 0 /f
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer" /v AltTabSettings /t REG_DWORD /d 1 /f
:: Ottimizzazioni TCP/IP e Networking
reg add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" /v KeepAliveTime /t REG_DWORD /d 600000 /f
reg add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" /v TcpWindowSize /t REG_DWORD /d 372620 /f
reg add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" /v EnableTCPA /t REG_DWORD /d 0 /f
reg add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters" /v EnableRSS /t REG_DWORD /d 0 /f
reg add "HKLM\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters\Interfaces\{GUID}" /v MTU /t REG_DWORD /d 1500 /f
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\Psched" /v NonBestEffortLimit /t REG_DWORD /d 0 /f
reg add "HKLM\SOFTWARE\Microsoft\Dfrg\BootOptimizeFunction" /v Enable /t REG_SZ /d N /f
reg add "HKLM\SYSTEM\CurrentControlSet\Services\PartMgr" /v DisableDeleteNotification /t REG_DWORD /d 0 /f
reg add "HKLM\SYSTEM\CurrentControlSet\Control\FileSystem" /v NtfsDisableCompression /t REG_DWORD /d 1 /f
reg add "HKLM\SYSTEM\CurrentControlSet\Control\FileSystem" /v NtfsDisableLastAccessUpdate /t REG_DWORD /d 1 /f
reg add "HKLM\SYSTEM\CurrentControlSet\Control\FileSystem" /v NtfsDisable8dot3NameCreation /t REG_DWORD /d 1 /f
reg add "HKLM\SYSTEM\CurrentControlSet\Control\FileSystem" /v EnableOplocks /t REG_DWORD /d 0 /f
reg add "HKLM\SYSTEM\CurrentControlSet\Services\LanmanServer\Parameters" /v Size /t REG_DWORD /d 3 /f
reg add "HKLM\SYSTEM\CurrentControlSet\Services\Disk\TimeOutValue" /v TimeOutValue /t REG_DWORD /d 30 /f

:: HID & Tastiera
reg add "HKLM\SYSTEM\CurrentControlSet\Services\HidUsb" /v MaxEventFilterLatency /t REG_DWORD /d 0 /f
reg add "HKLM\SYSTEM\CurrentControlSet\Control\Keyboard Layout" /v Scancode Map /t REG_BINARY /d 000000000000000000000000 /f
reg add "HKLM\SYSTEM\CurrentControlSet\Control\HidUsb" /v PollInterval /t REG_DWORD /d 1 /f

:: Mouse e Tastiera UX
reg add "HKCU\Control Panel\Mouse" /v MouseAcceleration /t REG_SZ /d 0 /f
reg add "HKCU\Control Panel\Mouse" /v MouseSpeed /t REG_SZ /d 2 /f
reg add "HKCU\Control Panel\Mouse" /v MouseThreshold1 /t REG_SZ /d 0 /f
reg add "HKCU\Control Panel\Mouse" /v MouseThreshold2 /t REG_SZ /d 0 /f
reg add "HKCU\Control Panel\Keyboard" /v KeyboardSpeed /t REG_SZ /d 31 /f
reg add "HKCU\Control Panel\Keyboard" /v KeyboardDelay /t REG_SZ /d 0 /f

:: Polling Tastiera
reg add "HKLM\SYSTEM\CurrentControlSet\Services\Kbdclass\Parameters" /v PollingInterval /t REG_DWORD /d 1 /f

:: Accessibilità
reg add "HKCU\Control Panel\Accessibility\Keyboard Response" /v AutoRepeatDelay /t REG_SZ /d 100 /f
reg add "HKCU\Control Panel\Accessibility\Keyboard Response" /v BounceTime /t REG_SZ /d 0 /f

:: Touchpad Synaptics
reg add "HKCU\SOFTWARE\Synaptics\SynTP\TouchPadPS2" /v PalmDetect /t REG_DWORD /d 0 /f
reg add "HKCU\SOFTWARE\Synaptics\SynTP\TouchPadPS2" /v PalmSensitivity /t REG_DWORD /d 0 /f

:: Fine ottimizzazioni
echo.
echo Tutti i tweak sono stati applicati correttamente! 🔧
echo Riavvia il PC per rendere effettive tutte le modifiche.
pause
exit

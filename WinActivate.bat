
@echo off
   mode con cols=85 lines=32
    set "Apply=%*"
    cd /d "%~dp0" && ( if exist "%temp%\getadmin.vbs" del "%temp%\getadmin.vbs" ) && fsutil dirty query "%systemdrive%" 1>nul 2>nul || (  cmd /u /c echo Set UAC = CreateObject^("Shell.Application"^) : UAC.ShellExecute "cmd.exe", "/k cd ""%~sdp0"" && ""%~0"" %Apply%", "", "runas", 1 >> "%temp%\getadmin.vbs" && "%temp%\getadmin.vbs" /f && exit /B )
    color 02
    title Windows 10 activate
    pushd "%~dp0"
    setlocal enabledelayedexpansion
    cls
    if /i "%PROCESSOR_IDENTIFIER:~0,3%" equ "x86" (
    set "digit=System32\spp\tokens\skus"
    ) else (
    set "digit=SysNative\spp\tokens\skus"
        )

    for /f "tokens=6 delims=[]. " %%a in ('ver') do (set version=%%a)

goto ProfessionalWorkstation
goto Professional

    :start
    cls
    wmic path SoftwareLicensingProduct where (LicenseStatus='1' and GracePeriodRemaining='0') get Name 2>nul | findstr /i "Windows" >nul 2>&1 && (echo. & echo 您使用的计算机已永久激活，无需再次激活。 & echo 请在未激活的计算机上运行此脚本，或输入2选择激活其它版本。 & echo 按任意键退出脚本。 & pause >nul && exit )

    for /f "tokens=3 delims= " %%i in ('cscript /nologo %SystemRoot%\System32\slmgr.vbs /dli ^| findstr /i "edition"') do (set edition=%%i)
    goto %edition%

    :activation
    cls
    if /i "%License:~-4%" equ "GVLK" (
    set "ActiveType=KMS38"
    echo ---------------------------------------------------------------
cscript /nologo %SystemRoot%\system32\slmgr.vbs /ckms
    ) else (
    set "ActiveType=Digital"
      )

    if not exist "%SystemRoot%\System32\spp\tokens\skus\%skus%" (
    title Windows 10 activate－Installing License

    ".\bin\7z.exe" x ".\skus\%version%.7z" -o"%SystemRoot%\%digit%" %skus% -aoa >nul 2>nul 
    if not exist "%SystemRoot%\System32\spp\tokens\skus\%skus%" goto end
    echo ---------------------------------------------------------------
    echo Installing License, it may take some time, please wait for finish
    cscript /nologo %SystemRoot%\System32\slmgr.vbs /rilc >nul
    ) else (
    goto next
        )

    :next
    title Windows 10 activate-Activating
    if /i "%skus%" equ "ServerRdsh" goto ActiveSR
    for /f "tokens=3" %%k in ('reg query "HKLM\SYSTEM\CurrentControlSet\Services\wuauserv" /v "start"') do (set services=%%k)
    if /i "%services:~-1%" gtr "3" (
    echo ---------------------------------------------------------------
    echo Starting 'Windows Update' service。
    sc config wuauserv start= auto >nul 2>nul
    ) else (
    goto activation1
        )

    :activation1

    echo ---------------------------------------------------------------
    echo      Installing Product Key，Please Wait
    echo ---------------------------------------------------------------
    cscript /nologo %SystemRoot%\System32\slmgr.vbs /ipk %pidkey% || goto error1
    timeout /nobreak /t 2 >nul
    wmic path SoftwareLicensingProduct where (LicenseStatus='1' and GracePeriodRemaining='0') get Name 2>nul | findstr /i "Windows" >nul 2>&1 && (echo. & echo 您使用的计算机已永久激活，无需再次激活。 & echo 请在未激活的计算机上运行此脚本。 & echo 按任意键退出脚本。 & pause >nul && exit )

    sc start wuauserv >nul 2>nul
    echo ---------------------------------------------------------------
    echo 正在添加注册表。
    reg add "HKLM\SYSTEM\Tokens" /v "Channel" /t REG_SZ /d "%License%" /f >nul
    reg add "HKLM\SYSTEM\Tokens\Kernel" /v "Kernel-ProductInfo" /t REG_DWORD /d "%sku%" /f >nul
    reg add "HKLM\SYSTEM\Tokens\Kernel" /v "Security-SPP-GenuineLocalStatus" /t REG_DWORD /d "1" /f >nul
    reg add "HKCU\SOFTWARE\Microsoft\Windows NT\CurrentVersion\AppCompatFlags\Layers" /v "\"%~dp0bin\%ActiveType%\gatherosstate.exe"\" /d "^ WIN7RTM" /f >nul

    echo ---------------------------------------------------------------
    echo     Geting Digital Tickets，Please Wait
    echo ---------------------------------------------------------------

    set "number=0"
    :Reset
    set /a "number=%number%+1"
    start /wait "" ".\bin\%ActiveType%\gatherosstate.exe"
    timeout /nobreak /t 3 >nul
    if exist ".\bin\%ActiveType%\GenuineTicket.xml" (
    goto app
        )

    if "%number%" lss "3" (
    goto Reset
        )
    goto end1

    :app
    clipup -v -o -altto .\bin\%ActiveType%\

    if /i "%License:~-4%" equ "GVLK" (
    echo ---------------------------------------------------------------
    cscript /nologo %SystemRoot%\system32\slmgr.vbs /skms "127.0.0.1"
    ) else (
    echo ---------------------------------------------------------------
    cscript /nologo %SystemRoot%\system32\slmgr.vbs /ato
      )

    echo ---------------------------------------------------------------
    echo 正在删除注册表。
    reg delete "HKLM\SYSTEM\Tokens" /f >nul
    reg delete "HKCU\SOFTWARE\Microsoft\Windows NT\CurrentVersion\AppCompatFlags\Layers" /v "\"%~dp0bin\%ActiveType%\gatherosstate.exe"\" /f >nul

    :ActiveSR
    echo ---------------------------------------------------------------
    echo       Installing Product Key，Please Wait
    cscript /nologo %SystemRoot%\System32\slmgr.vbs /ipk %pidkey%
    echo ---------------------------------------------------------------
    echo      Activating Windows
    cscript /nologo %SystemRoot%\system32\slmgr.vbs /ato



    :install
    title Windows 10 数字权利激活脚本－安装产品密钥
    echo ---------------------------------------------------------------
    set /p "install=请输入或粘贴需要安装的密钥，按 Enter 安装:"
    cls
    echo ---------------------------------------------------------------
    echo      正在安装产品密钥，请等待完成。
    echo ---------------------------------------------------------------
    cscript /nologo %SystemRoot%\System32\slmgr.vbs /ipk %install% || goto error
    echo ---------------------------------------------------------------

    for /f "tokens=3" %%k in ('cscript /nologo %SystemRoot%\System32\slmgr.vbs /dti') do (set ID=%%k)
    for /f "delims=" %%g in ("%ID%") do (
    set "pid0=%%g"
    set "pid1=!pid0:~0,7!"
    set "pid2=!pid0:~7,7!"
    set "pid3=!pid0:~14,7!"
    set "pid4=!pid0:~21,7!"
    set "pid5=!pid0:~28,7!"
    set "pid6=!pid0:~35,7!"
    set "pid7=!pid0:~42,7!"
    set "pid8=!pid0:~49,7!"
    set "pid9=!pid0:~56,7!"
    echo 安装 ID: !pid1! !pid2! !pid3! !pid4! !pid5! !pid6! !pid7! !pid8! !pid9!
        )

    :error
    echo ---------------------------------------------------------------
    pause
    exit

    :uninstall
    title Windows 10 数字权利激活脚本－卸载 KEY
    echo ---------------------------------------------------------------
    echo     正在卸载默认密钥，请稍等。
    echo ---------------------------------------------------------------
    cscript /nologo %SystemRoot%\system32\slmgr.vbs /upk
    echo ---------------------------------------------------------------
    pause
    exit

    :end
    echo ---------------------------------------------------------------
    echo 证书复制失败，请检查 skus 目录是否完整。
    echo 或检查选择的目标版本，当前系统是否支持转换。
    echo ---------------------------------------------------------------
    echo 按任意键退出脚本。
    pause >nul
    exit

    :end1
    echo ---------------------------------------------------------------
    echo 数字门票获取失败， Windows 10 %skus% 未能激活。
    echo ---------------------------------------------------------------
    echo 正在删除注册表。
    reg delete "HKLM\SYSTEM\Tokens" /f >nul
    reg delete "HKCU\SOFTWARE\Microsoft\Windows NT\CurrentVersion\AppCompatFlags\Layers" /v "\"%~dp0bin\%ActiveType%\gatherosstate.exe"\" /f >nul
    echo ---------------------------------------------------------------
    echo 按任意键退出。
    pause >nul
    exit

    :Professional
    set "sku=48"
    set "pidkey=VK7JG-NPHTM-C97JM-9MPGT-3V66T"
    set "License=Retail"
    set "skus=Professional"
    goto activation

    :ProfessionalWorkstation
    set "sku=161"
    set "pidkey=DXG7C-N36C4-C4HTG-X4T3X-2YV77"
    set "License=Retail"
    set "skus=ProfessionalWorkstation"
    goto activation

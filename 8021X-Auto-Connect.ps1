# このスクリプトは、指定したSSIDと認証情報を使って、ワイヤレスネットワークに接続するためのものです。
# スクリプトの実行時に、以下のことを行います。
# 1. ログファイルのパスを変数に格納します。
# 2. スクリプトの起動時刻をログファイルに記録します。
# 3. 10秒待機します。
# 4. ワイヤレスアダプターを取得します。
# 5. 接続状態を確認し、既に接続済みならば、スクリプトの実行を終了します。
# 6. SSIDと認証情報を変数に格納します。
# 7. 該当のSSIDが既に登録されているか確認し、あれば削除します。
# 8. 新しいワイヤレスプロファイルを作成し、適用します。
# 9. プロファイル作成後10秒待機します。
# 10. 再度接続状態を確認し、未接続ならば、接続コマンドを実行します。そうでなければ、何もしません。
# 11. 接続結果やエラーがあればログファイルに記録します。

# ログファイルのパスを変数に格納
$logFile = "c:\Temp\Logfile.txt"

# スクリプトの起動時刻をログに記録
"[$(Get-Date)] Script started." | Out-File -FilePath $logFile -Append

# 10秒待機する
Start-Sleep 10

# ワイヤレスアダプターを取得
$adapter = Get-NetAdapter | Where-Object {$_.InterfaceDescription -like "*Wireless*"}

# 接続状態を確認
$connectionStatus = Get-NetworkAdapterStatusInfoByIndex($adapter.InterfaceIndex)

# 接続状態が接続済みならば、スクリプトの実行終了する。
if ($connectionStatus.StatusText.Contains("Connected")) {
    # 接続済みであることをログに記録
    "[$(Get-Date)] Already connected to SSID: $ssid. No need to run the rest of the script."
    | Out-File -FilePath $logFile -Append
    
    # スクリプトの実行終了
    Exit
}

# SSIDと認証情報を変数に格納
$ssid = "test"
$username = "username"
$password = "password"

# 該当のSSIDが既に登録されているか確認し、あれば削除
if (Get-NetAdapter | Where-Object {$_.InterfaceDescription -like "*Wireless*"} | Get-NetConnectionProfile | Where-Object {$_.Name -eq $ssid}) {
    Remove-NetConnectionProfile -Name $ssid
    # 削除したことをログに記録
    "[$(Get-Date)] Removed existing profile for SSID: $ssid."
    | Out-File -FilePath $logFile -Append
    
}

# 新しいワイヤレスプロファイルを作成
New-EapConfiguration -Mode EapPeap -PeapIdentity $username -PeapPassword $password -ValidateServerCertificate:$false | Add-VpnConnectionTriggerApplication -Name $ssid

# ワイヤレスプロファイルを適用
Set-NetConnectionProfile -Name $ssid -NetworkCategory Private

# 作成したことをログに記録
"[$(Get-Date)] Created new profile for SSID: $ssid." | Out-File -FilePath $logFile -Append

# 10秒待機する
Start-Sleep 10

# 接続状態を確認
$connectionStatus = Get-NetworkAdapterStatusInfoByIndex($adapter.InterfaceIndex)

# 接続状態が未接続ならば、接続コマンドを実行し、結果をログに記録する関数を定義する。
function Connect-Wireless {
    Connect-NetworkAdapterByIndex($adapter.InterfaceIndex)
    if ($?) {
        "[$(Get-Date)] Successfully connected to SSID: $ssid."
        | Out-File -FilePath $logFile
    }
    else {
        "[$(Get-Date)] Failed to connect to SSID: $ssid. Error: $_"
        | Out-File -FilePath $logFile 
    }
}

# 接続状態が未接続ならば、関数を呼び出す。そうでなければ、既に接続済みであることをログに記録する。
if ($connectionStatus.StatusText.Contains("Not connected")) {
    Connect-Wireless()
}
else {
    "[$(Get-Date)] Already connected to SSID: $ssid. No need to run connection command."
    | Out-File -FilePath $logFile -Append
}
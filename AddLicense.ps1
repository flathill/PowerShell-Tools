# カレントディレクトリ移動
Set-Location -Path z:\work\PowerShell-Tools

# モジュールをインポート
Import-Module Microsoft.Graph.Users

# ユーザ情報定義ファイル
# UserPrincipalName,JobTitle,Department,Password
$userFile = "Z:\work\PowerShell-Tools\Users.csv"

# Microsoft Graphに接続
Write-Host Connect to Microsoft Graph
Connect-MgGraph -Scopes "User.ReadWrite.All,Organization.ReadWrite.All,Directory.ReadWrite.All"

# ユーザ情報定義ファイルを読み込み
$users = Import-Csv -Path $userFile

# ユーザ情報からAzureADユーザにライセンスを割り当てる
ForEach ($user in $users) {
    # CSVファイル中のユーザIdを指定
    $userId = $user.UserPrincipalName
    
    # JobTitleに応じてライセンスのSKU IDとサービスプランIDを設定
    If ($user.JobTitle -eq "sales") {
        # sales-templateはsales用テンプレートユーザ
        $mgUser = Get-MgUser -UserId "sales-template@example.com" -Property AssignedLicenses
    }
    ElseIf ($user.JobTitle -eq "marketing") {
        # marketing-templateはmarketing用テンプレートユーザ
        $mgUser = Get-MgUser -UserId "marketing-template@example.com" -Property AssignedLicenses
    }

    # ログ
    Write-Host Add License to $user.UserPrincipalName
    
    # テンプレートユーザのライセンス情報と同じ内容を割り当て
    Set-MgUserLicense -UserId $userId -AddLicenses $mgUser.AssignedLicenses -RemoveLicenses @()
}

# Microsoft Graphから切断
Write-Host Disconnect from Microsoft Graph
Disconnect-MgGraph

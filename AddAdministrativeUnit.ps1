# カレントディレクトリ移動
Set-Location -Path z:\work\PowerShell-Tools

# モジュール読み込み
Import-Module Microsoft.Graph.Identity.DirectoryManagement

# ユーザ情報定義ファイル
# UserPrincipalName,JobTitle,Department,Password
$userFile = "Z:\work\PowerShell-Tools\Users.csv"

# ExchangeOnlineに接続
Write-Host Connect to Exchange Online
Connect-ExchangeOnline

# Microsoft Graphに接続
Write-Host Connect to Microsoft Graph
Connect-MgGraph -Scopes "User.ReadWrite.All,Organization.ReadWrite.All,Directory.ReadWrite.All,AdministrativeUnit.ReadWrite.All"

# ユーザ情報定義ファイルを読み込み
$users = Import-Csv -Path $userFile

# 所属（Department）を元に管理組織にユーザを割り当てる
ForEach ($user in $users) {
    # CSVファイル中のユーザIdを指定
    $userId = $user.UserPrincipalName
    
    # 所属に応じて管理組織を設定
    If ($user.Department -eq "com") {
        $unit = Get-AdministrativeUnit -Identity "AU-com"
    }
    ElseIf ($user.Department -eq "org") {
        $unit = Get-AdministrativeUnit -Identity "AU-org"
    }

    # ログ    
    Write-Host Add User $userId to AdministrativeUnit ${unit}.DisplayName

    # 管理組織に対してユーザを登録
    New-MgDirectoryAdministrativeUnitMemberByRef -AdministrativeUnitId $unit.id -BodyParameter @{
"@odata.id" = "https://graph.microsoft.com/v1.0/users/$userId" }
}

# Microsoft Graphから切断
Write-Host Disconnect from Microsoft Graph
Disconnect-MgGraph

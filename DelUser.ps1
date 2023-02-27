# カレントディレクトリ移動
Set-Location -Path z:\work\PowerShell-Tools

# モジュールをインポート
Import-Module Microsoft.Graph.Users

# ユーザ情報定義ファイル
# UserPrincipalName,JobTitle,Department,Password
$userFile = "Z:\work\PowerShell-Tools\Users.csv"

# Microsoft Graphに接続
Write-Host Connect to Microsoft Graph
Connect-MgGraph -Scopes "User.ReadWrite.All,Organization.ReadWrite.All,Directory.ReadWrite.All,AdministrativeUnit.ReadWrite.All"

# ユーザ情報定義ファイルを読み込み
$users = Import-Csv -Path $userFile

# CSVファイルの各行に対して関数を実行
foreach ($user in $users) {
    # ログ
    Write-Host Delete User $user.UserPrincipalName

    # パラメータに従いユーザを登録
    Remove-MgUser -UserId $user.UserPrincipalName
}

# Microsoft Graphから切断
Write-Host Disconnect from Microsoft Graph
Disconnect-MgGraph

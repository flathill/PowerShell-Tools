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

    # UserPrincipalNameをユーザ部とドメイン部に分割
    $UserName, $Domain = $user.UserPrincipalName.Split("@")

    # Departmentに応じて管理組織を設定

    # sales
    If ($user.Department -eq "sales") {
        $params = @{
            AccountEnabled = $true
            DisplayName = $UserName
            MailNickname = $UserName
            UserPrincipalName = $user.UserPrincipalName
            PasswordProfile = @{
                # 初回ログオン時のパスワード変更を強制
                ForceChangePasswordNextSignIn = $true
                Password = $user.Password
            }
            # パスワード期限を無期限に設定
            PasswordPolicies = "DisablePasswordExpiration"

            Department = $user.Department
            JobTitle = $user.JobTitle
            UsageLocation = "JP"
        }

    }
    # marketing
    ElseIf ($user.Department -eq "marketing") {

        $params = @{
            AccountEnabled = $true
            DisplayName = $UserName
            MailNickname = $UserName
            UserPrincipalName = $user.UserPrincipalName
            PasswordProfile = @{
                # 初回ログオン時のパスワード変更を強制しない
                ForceChangePasswordNextSignIn = $false
                Password = $user.Password
            }
            # パスワード期限を無期限に設定
            PasswordPolicies = "DisablePasswordExpiration"

            Department = $user.Department
            JobTitle = $user.JobTitle
            UsageLocation = "JP"
        }
    }

    # ログ
    Write-Host Add User $user.UserPrincipalName

    # パラメータに従いユーザを登録
    New-MgUser -BodyParameter $params
}

# Microsoft Graphから切断
Write-Host Disconnect from Microsoft Graph
Disconnect-MgGraph

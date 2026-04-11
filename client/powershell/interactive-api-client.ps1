# -- Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope Process
[CmdletBinding()]
param (
    [string]$BaseUrl = "http://localhost:8080"
)

# 出力をUTF-8に設定
$OutputEncoding = [System.Text.Encoding]::UTF8
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

$ErrorActionPreference = "Stop"
$Headers = @{ "Accept" = "application/json" }

# -- Global parameter ------
# 初期状態のパス
$CurrentPath = "/"
$CurrentId = 1
$History = New-Object 'System.Collections.Generic.Stack[int]'

# -- const ------
$SLEEP_TIME = 3 #second
$FILE_ICON = "[FILE]"
$FOLDER_ICON = "[DIR]"

# --- 関数定義 ---
# ---- 画面描画関数定義 ----
function Enter-ApiItemsView {
# - Descriotion -------
# - APIへ接続し、ファイルサーバのファイル構造を反映する。
# - 表示単位はフォルダ単位とし、中の内容を一覧で表現する。
# - また、メインメニューとしての役割も兼任する。
# - Buttons -------
# - [Num]   : 一覧の左にある番号を指定してフォルダを移動する。ファイルである場合無視する。
# - [..]    : 親フォルダへ移動する。現在地がルートディレクトリだった場合無視する。
# - [c]     : 現在のフォルダに対して新しいフォルダを作成する。
# -           作成予定のフォルダ名称の入力画面へ移行する。
# - [q]     : アプリを終了する。
# ---------------------
    param([string[]]$ItemsVeiw, [bool]$ErrorFlg)
    Write-Host "================================================" -ForegroundColor Cyan
    Write-Host "  API File Explorer"
    Write-Host ("  Current Path: " + $CurrentPath) -ForegroundColor Yellow
    Write-Host "================================================"

    if ($ErrorFlg) {
        Write-Host "Error: Failed to get items." -ForegroundColor Red
    }
    else {
        foreach ($itemVeiw in $ItemsVeiw) {
            Write-Host ($itemVeiw)
        }
    }

    Write-Host "------------------------------------------------"
    Write-Host " [Num]:Move  [..]:Up  [c]:NewFolder  [q]:Quit"

    $inputVal = Read-Host "`nChoice"
    if ($null -eq $inputVal) { $inputVal = "" }
    return $inputVal.Trim()
}

function Get-ApiItems {
# - items -------
# fileId       ファイルID
# publicId     ファイル識別子
# typeCode     種別（F:ファイル, D:フォルダ）
# name         ファイル名
# physicalName ファイル実体名
# createAt     ファイル作成日
# ---------------
    param([int32]$ParentId)
    $uri = "$BaseUrl/api/items?parentId=$($ParentId)"
    $items = Invoke-RestMethod -Method Get -Uri $uri -Headers $Headers
    return $items
}

function New-ApiFolder {
    param([int32]$ParentId, [string]$FolderName)
    $uri = "$BaseUrl/api/folders"
    $body = @{
        parentId = $ParentId
        name = $FolderName
    } | ConvertTo-Json -Compress

    $encodeBody = [Text.Encoding]::UTF8.GetBytes($body)

    Write-Host ("`nCreating: " + $FolderName) -ForegroundColor Cyan
    $response = Invoke-RestMethod -Uri $uri -Method Post -Body $encodeBody -Headers $Headers -ContentType "application/json"
    Write-Host ("Success Create {0} AS {1}." -f $response.physicalName, $response.name) -ForegroundColor Green
}

# --- メインループ ---

while ($true) {
    Clear-Host

    $itemsVeiw = New-Object string[] 0
    $errorFlg = $false

    # APIからITEMを取得
    $itemMap = @{}
    try {
        $items = Get-ApiItems -ParentId $CurrentId
        $i = 1
        foreach ($item in $items) {
            $icon = $FILE_ICON
            if ($item.typeCode -eq "D") { $icon = $FOLDER_ICON }
            
            $itemsVeiw += (" {0,2} : {1} {2}" -f $i, $icon, $item.name)
            $itemMap[$i] = $item
            $i++
        }
    }
    catch {
        $errorFlg = $true
    }

    $inputVal = Enter-ApiItemsView -ItemsVeiw $itemsVeiw -ErrorFlg $errorFlg

    # --- 条件分岐 ---
    if ($inputVal -eq "q") {
        break
    }
    elseif ($inputVal -eq "..") {
        if ($CurrentPath -ne "/") {
            $CurrentPath = Split-Path $CurrentPath -Parent
            $CurrentPath = $CurrentPath.Replace("\", "/")
            if (-not $CurrentPath.StartsWith("/")) { $CurrentPath = "/" + $CurrentPath }

            # 親フォルダのIDを取り出す
            $CurrentId = $History.Pop()
        }
    }
    elseif ($inputVal -eq "c") {
        $name = Read-Host "Folder Name"
        if ($name) { New-ApiFolder -ParentId $CurrentId -FolderName $name }
        Start-Sleep -Seconds $SLEEP_TIME
    }
    elseif ($inputVal -match "^\d+$") {
        $idx = [int]$inputVal
        if ($itemMap.ContainsKey($idx)) {
            $target = $itemMap[$idx]
            if ($target.typeCode -eq "D") {
                if ($CurrentPath -eq "/") { $CurrentPath = "/" + $target.Name }
                else { $CurrentPath = $CurrentPath + "/" + $target.Name }

                $History.Push($CurrentId)
                $CurrentId = $target.fileId
            } else {
                Write-Host ("Selected File: " + $target.Name) -ForegroundColor Magenta
                Pause
            }
        } else {
            Write-Host "Invalid Number." -ForegroundColor Red
            Start-Sleep -Seconds $SLEEP_TIME
        }
    }
}
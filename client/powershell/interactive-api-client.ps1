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

# 初期状態のパス
$CurrentPath = "/"
$CurrentId = 1
$History = New-Object 'System.Collections.Generic.Stack[int]'

# -- const ------
$SLEEP_TIME = 3 #second

# --- 関数定義 ---

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
    Write-Host "================================================" -ForegroundColor Cyan
    Write-Host "  API File Explorer"
    Write-Host ("  Current Path: " + $CurrentPath) -ForegroundColor Yellow
    Write-Host "================================================"

    $itemMap = @{}
    try {
        $items = Get-ApiItems -ParentId $CurrentId
        $i = 1
        foreach ($item in $items) {
            # 互換性の高いif文
            $icon = "[FILE]"
            if ($item.typeCode -eq "D") { $icon = "[DIR] " }
            
            Write-Host (" {0,2} : {1} {2}" -f $i, $icon, $item.name)
            $itemMap[$i] = $item
            $i++
        }
    }
    catch {
        Write-Host "Error: Failed to get items." -ForegroundColor Red
    }

    Write-Host "------------------------------------------------"
    Write-Host " [Num]:Move  [..]:Up  [c]:NewFolder  [q]:Quit"
    
    $inputVal = Read-Host "`nChoice"
    if ($null -eq $inputVal) { $inputVal = "" }
    $inputVal = $inputVal.Trim()

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
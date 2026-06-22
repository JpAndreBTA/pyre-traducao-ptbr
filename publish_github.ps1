$ErrorActionPreference = 'Stop'

$RepoName = 'pyre-traducao-ptbr'
$ReleaseTag = 'v1.0.2'
$Exe = Join-Path $PSScriptRoot 'release\Pyre-Traducao-PTBR-Installer-v1.0.2.exe'
$Notes = Join-Path $PSScriptRoot 'RELEASE_NOTES_v1.0.2.md'

if (-not (Get-Command gh -ErrorAction SilentlyContinue)) {
    throw 'GitHub CLI não encontrado. Instale em: https://cli.github.com/'
}

gh auth status

if (-not (Test-Path (Join-Path $PSScriptRoot '.git'))) {
    git -C $PSScriptRoot init
    git -C $PSScriptRoot branch -M main
}

git -C $PSScriptRoot add README.md CHANGELOG.md STEAM_GUIDE.md SHA256.txt RELEASE_NOTES_v1.0.2.md publish_github.ps1
git -C $PSScriptRoot commit -m "Publica documentação da tradução PT-BR de Pyre" 2>$null

$existing = gh repo view $RepoName --json name --jq .name 2>$null
if (-not $existing) {
    gh repo create $RepoName --public --source $PSScriptRoot --remote origin --description "Tradução PT-BR feita por fã para Pyre"
}

git -C $PSScriptRoot push -u origin main

$releaseExists = gh release view $ReleaseTag --repo $RepoName 2>$null
if ($releaseExists) {
    gh release upload $ReleaseTag $Exe --repo $RepoName --clobber
} else {
    gh release create $ReleaseTag $Exe --repo $RepoName --title "Pyre Tradução PT-BR v1.0.2" --notes-file $Notes
}

gh repo view $RepoName --web


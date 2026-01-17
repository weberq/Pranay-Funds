# release.ps1
# Automates tagging and pushing for PranayFunds

$pubspecToken = "version: "
$pubspecFile = "pubspec.yaml"
$changelogFile = "changelogs.json"

# 1. Read Version
if (-not (Test-Path $pubspecFile)) {
    Write-Error "pubspec.yaml not found!"
    exit 1
}

$content = Get-Content $pubspecFile
$versionLine = $content | Where-Object { $_.TrimStart().StartsWith($pubspecToken) } | Select-Object -First 1

if (-not $versionLine) {
    Write-Error "Version not found in pubspec.yaml"
    exit 1
}

$version = $versionLine -replace "$pubspecToken", "" -replace " ", ""
Write-Host "Detected Version: $version" -ForegroundColor Cyan

# 2. Get Changelog
$changelogVars = Get-Content $changelogFile -Raw | ConvertFrom-Json
$changelog = $changelogVars."$version"

if (-not $changelog) {
    Write-Warning "No changelog found for version $version in $changelogFile"
    $changelog = Read-Host "Enter changelog message for this release"
    if (-not $changelog) {
        Write-Error "Changelog cannot be empty."
        exit 1
    }
} else {
    Write-Host "Changelog found:" -ForegroundColor Green
    Write-Host $changelog -ForegroundColor Gray
}

# 3. Confirm
$confirm = Read-Host "Create tag v$version with this changelog? (y/n)"
if ($confirm -ne 'y') {
    Write-Host "Aborted."
    exit 0
}

# 4. Extract API Key & Build
$launchJson = ".vscode/launch.json"
$apiKey = ""

if (Test-Path $launchJson) {
    try {
        $json = Get-Content $launchJson -Raw | ConvertFrom-Json
        # Navigate to configurations -> toolArgs
        $config = $json.configurations | Where-Object { $_.name -eq "pranayfunds" }
        if ($config) {
            $arg = $config.toolArgs | Where-Object { $_ -match "API_KEY=" }
            if ($arg) {
                $apiKey = $arg -replace "--dart-define=API_KEY=", ""
            }
        }
    } catch {
        Write-Warning "Failed to parse launch.json for API KEY."
    }
}

if (-not $apiKey) {
    $apiKey = Read-Host "Enter API_KEY for release build"
}

Write-Host "Building Release APK with API_KEY..." -ForegroundColor Cyan
flutter build apk --release --dart-define=API_KEY=$apiKey

if ($LASTEXITCODE -ne 0) {
    Write-Error "Build failed!"
    exit 1
}

# 5. Tag and Push
$tagName = "v$version"
git tag -a $tagName -m "$changelog"
if ($LASTEXITCODE -eq 0) {
    Write-Host "Tag $tagName created." -ForegroundColor Green
    
    $push = Read-Host "Push tags and create GitHub Release? (y/n)"
    if ($push -eq 'y') {
        git push origin $tagName
        
        # Check for gh CLI
        if (Get-Command "gh" -ErrorAction SilentlyContinue) {
            Write-Host "Creating GitHub Release..." -ForegroundColor Cyan
            $apkPath = "build/app/outputs/flutter-apk/app-release.apk"
            gh release create $tagName "$apkPath" --notes "$changelog"
            if ($LASTEXITCODE -eq 0) {
                Write-Host "Release created and APK uploaded!" -ForegroundColor Green
            } else {
                Write-Error "Failed to create GitHub release."
            }
        } else {
            Write-Warning "'gh' CLI not found. Please upload 'build/app/outputs/flutter-apk/app-release.apk' manually to GitHub Releases."
        }
    }
} else {
    Write-Error "Failed to create tag. Does it already exist?"
}

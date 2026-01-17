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
Write-Host "Current Version: $version" -ForegroundColor Cyan

# Parse Version (x.y.z+n)
if ($version -match "^(\d+)\.(\d+)\.(\d+)\+(\d+)$") {
    $major = [int]$matches[1]
    $minor = [int]$matches[2]
    $patch = [int]$matches[3]
    $build = [int]$matches[4]
} else {
    Write-Error "Version format $version not supported. Expected x.y.z+n"
    exit 1
}

# Prompt for Update Type
Write-Host "Select update type:" -ForegroundColor Yellow
Write-Host "1) Patch ($major.$minor.$($patch+1))"
Write-Host "2) Minor ($major.$($minor+1).0)"
Write-Host "3) Major ($($major+1).0.0)"
Write-Host "4) No Change (Keep $version)"

$choice = Read-Host "Choice (1-4)"

switch ($choice) {
    '1' { $patch++; $build++; $newVersion = "$major.$minor.$patch+$build" }
    '2' { $minor++; $patch=0; $build++; $newVersion = "$major.$minor.$patch+$build" }
    '3' { $major++; $minor=0; $patch=0; $build++; $newVersion = "$major.$minor.$patch+$build" }
    '4' { $newVersion = $version }
    Default { Write-Warning "Invalid choice. keeping current version."; $newVersion = $version }
}

if ($newVersion -ne $version) {
    Write-Host "Bumping version to: $newVersion" -ForegroundColor Green
    
    # Update pubspec.yaml
    (Get-Content $pubspecFile) | ForEach-Object {
        if ($_.TrimStart().StartsWith($pubspecToken)) {
            "$pubspecToken$newVersion"
        } else {
            $_
        }
    } | Set-Content $pubspecFile
    
    $version = $newVersion
} else {
    Write-Host "Keeping version: $version"
}

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
        # Read file, remove comments (lines starting with //), then parse
        $jsonContent = Get-Content $launchJson | Where-Object { -not $_.Trim().StartsWith("//") } | Out-String
        $json = $jsonContent | ConvertFrom-Json
        
        # Navigate to configurations -> toolArgs
        $config = $json.configurations | Where-Object { $_.name -eq "pranayfunds" }
        if ($config) {
            $arg = $config.toolArgs | Where-Object { $_ -match "API_KEY=" }
            if ($arg) {
                $apiKey = $arg -replace "--dart-define=API_KEY=", ""
            }
        }
    } catch {
        Write-Warning "Failed to parse launch.json for API KEY: $_"
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

# Check if tag exists
if (git rev-parse -q --verify "refs/tags/$tagName") {
    Write-Warning "Tag $tagName already exists."
    $overwrite = Read-Host "Overwrite tag? (y/n)"
    if ($overwrite -eq 'y') {
        git tag -d $tagName
        # Attempt to delete remote tag too, just in case
        git push origin --delete $tagName 2>$null
        Write-Host "Old tag deleted."
    } else {
        Write-Host "Using existing tag..."
    }
}

# Create tag only if it doesn't exist (or was just deleted)
if (-not (git rev-parse -q --verify "refs/tags/$tagName")) {
    git tag -a $tagName -m "$changelog"
}

if ($LASTEXITCODE -eq 0) {
    Write-Host "Tag $tagName ready." -ForegroundColor Green
    
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

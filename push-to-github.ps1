# Script to push local repositories to MicroCODE-Gravity-Current organization
# This script will:
# 1. Create remote repositories on GitHub (requires GitHub CLI)
# 2. Initialize git in each folder if needed
# 3. Add remote and push code

$orgName = "MicroCODE-Gravity-Current"
$baseDir = "d:\MicroCODE\gravity-current"

# List of repositories to push
$repos = @(
    "client-react-native",
    "client-react-web",
    "free-saas-boilerplate",
    "how-to-build-a-saas-product",
    "mission-control",
    "server",
    "supernova"
)

Write-Host "================================" -ForegroundColor Cyan
Write-Host "GitHub Repository Setup Script" -ForegroundColor Cyan
Write-Host "================================" -ForegroundColor Cyan
Write-Host ""

# Check if GitHub CLI is installed
try {
    $ghVersion = gh --version
    Write-Host "✓ GitHub CLI is installed" -ForegroundColor Green
}
catch {
    Write-Host "✗ GitHub CLI (gh) is not installed or not in PATH" -ForegroundColor Red
    Write-Host "Please install it from: https://cli.github.com/" -ForegroundColor Yellow
    exit 1
}

# Check if authenticated
Write-Host ""
Write-Host "Checking GitHub authentication..." -ForegroundColor Yellow
try {
    $authStatus = gh auth status 2>&1
    Write-Host "✓ Authenticated with GitHub" -ForegroundColor Green
}
catch {
    Write-Host "✗ Not authenticated with GitHub" -ForegroundColor Red
    Write-Host "Please run: gh auth login" -ForegroundColor Yellow
    exit 1
}

Write-Host ""
Write-Host "================================================" -ForegroundColor Cyan
Write-Host "Step 1: Creating remote repositories on GitHub" -ForegroundColor Cyan
Write-Host "================================================" -ForegroundColor Cyan
Write-Host ""

foreach ($repo in $repos) {
    Write-Host "Creating repository: $orgName/$repo" -ForegroundColor Yellow

    # Create repository without README (to avoid conflicts)
    try {
        gh repo create "$orgName/$repo" --public --description "Licensed template repository" 2>&1 | Out-Null
        Write-Host "✓ Created $repo" -ForegroundColor Green
    }
    catch {
        Write-Host "⚠ Repository $repo may already exist or error occurred" -ForegroundColor Yellow
    }
}

Write-Host ""
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "Step 2: Initializing and pushing repos" -ForegroundColor Cyan
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host ""

foreach ($repo in $repos) {
    $repoPath = Join-Path $baseDir $repo
    Write-Host ""
    Write-Host "-----------------------------------" -ForegroundColor Cyan
    Write-Host "Processing: $repo" -ForegroundColor Cyan
    Write-Host "-----------------------------------" -ForegroundColor Cyan

    if (Test-Path $repoPath) {
        Set-Location $repoPath

        # Check if .git directory exists
        if (-not (Test-Path ".git")) {
            Write-Host "  Initializing git repository..." -ForegroundColor Yellow
            git init
            Write-Host "  ✓ Git initialized" -ForegroundColor Green
        }
        else {
            Write-Host "  ✓ Git repository already exists" -ForegroundColor Green
        }

        # Add remote if it doesn't exist
        $remoteUrl = "https://github.com/$orgName/$repo.git"
        $existingRemote = git remote get-url origin 2>&1

        if ($LASTEXITCODE -ne 0) {
            Write-Host "  Adding remote origin..." -ForegroundColor Yellow
            git remote add origin $remoteUrl
            Write-Host "  ✓ Remote added: $remoteUrl" -ForegroundColor Green
        }
        else {
            Write-Host "  ✓ Remote already exists: $existingRemote" -ForegroundColor Green
            # Update remote URL to match organization
            git remote set-url origin $remoteUrl
            Write-Host "  ✓ Remote URL updated to: $remoteUrl" -ForegroundColor Green
        }

        # Check if there are any commits
        $hasCommits = git rev-parse HEAD 2>&1
        if ($LASTEXITCODE -ne 0) {
            Write-Host "  Creating initial commit..." -ForegroundColor Yellow
            git add .
            git commit -m "Initial commit: Licensed template repository"
            Write-Host "  ✓ Initial commit created" -ForegroundColor Green
        }
        else {
            Write-Host "  ✓ Repository has commits" -ForegroundColor Green

            # Check if there are uncommitted changes
            $status = git status --porcelain
            if ($status) {
                Write-Host "  ⚠ There are uncommitted changes. Staging all files..." -ForegroundColor Yellow
                git add .
                git commit -m "Update: Syncing with organization"
                Write-Host "  ✓ Changes committed" -ForegroundColor Green
            }
        }

        # Push to remote
        Write-Host "  Pushing to GitHub..." -ForegroundColor Yellow
        git branch -M main
        git push -u origin main --force

        if ($LASTEXITCODE -eq 0) {
            Write-Host "  ✓ Successfully pushed to $orgName/$repo" -ForegroundColor Green
        }
        else {
            Write-Host "  ✗ Failed to push $repo" -ForegroundColor Red
        }
    }
    else {
        Write-Host "  ✗ Directory not found: $repoPath" -ForegroundColor Red
    }
}

# Return to base directory
Set-Location $baseDir

Write-Host ""
Write-Host "================================" -ForegroundColor Cyan
Write-Host "✓ All repositories processed!" -ForegroundColor Green
Write-Host "================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "You can view your repositories at:" -ForegroundColor Yellow
Write-Host "https://github.com/orgs/$orgName/repositories" -ForegroundColor Cyan
Write-Host ""

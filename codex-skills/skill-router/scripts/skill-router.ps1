param(
    [ValidateSet("list", "recommend", "enable", "disable", "only")]
    [string]$Action = "recommend",

    [string]$Task = "",

    [string[]]$Skills = @(),

    [Parameter(ValueFromRemainingArguments = $true)]
    [string[]]$Roots = @()
)

$ErrorActionPreference = "Stop"

function Get-DefaultRoots {
    $items = @()
    if ($HOME) {
        $items += (Join-Path $HOME ".codex\skills")
    }
    $items += (Join-Path (Get-Location) ".agents\skills")
    $items += (Split-Path -Parent $PSScriptRoot)
    $items | Select-Object -Unique
}

function Normalize-List {
    param([string[]]$Items)

    foreach ($item in $Items) {
        if (-not $item) {
            continue
        }

        $item -split "," |
            ForEach-Object { $_.Trim() } |
            Where-Object { $_ }
    }
}

function Read-SkillMetadata {
    param([System.IO.FileInfo]$SkillFile)

    $text = Get-Content -LiteralPath $SkillFile.FullName -Raw
    $name = $null
    $description = ""

    if ($text -match "(?s)^---\s*(.*?)\s*---") {
        $frontmatter = $Matches[1]
        if ($frontmatter -match "(?m)^name:\s*[""']?([^""'\r\n]+)[""']?\s*$") {
            $name = $Matches[1].Trim()
        }
        if ($frontmatter -match "(?m)^description:\s*[""']?(.+?)[""']?\s*$") {
            $description = $Matches[1].Trim()
        }
    }

    if (-not $name) {
        $name = $SkillFile.Directory.Name
    }

    [pscustomobject]@{
        Name = $name
        Description = $description
        Directory = $SkillFile.Directory.FullName
        SkillFile = $SkillFile.FullName
        IsSystem = $SkillFile.FullName -match "\\\.system\\"
    }
}

function Get-Skills {
    param([string[]]$SearchRoots)

    $resolved = foreach ($root in $SearchRoots) {
        if (Test-Path -LiteralPath $root) {
            (Resolve-Path -LiteralPath $root).Path
        }
    }

    $seenFiles = @{}
    $result = foreach ($root in ($resolved | Select-Object -Unique)) {
        Get-ChildItem -LiteralPath $root -Recurse -Filter "SKILL.md" -File -ErrorAction SilentlyContinue |
            Where-Object {
                -not $_.FullName.Contains("\downloaded-candidate-skills\") -or $root.Contains("downloaded-candidate-skills")
            } |
            ForEach-Object {
                if (-not $seenFiles.ContainsKey($_.FullName)) {
                    $seenFiles[$_.FullName] = $true
                    Read-SkillMetadata -SkillFile $_
                }
            }
    }

    $result | Sort-Object Name, Directory
}

function Get-OpenAiYamlPath {
    param([object]$Skill)
    Join-Path $Skill.Directory "agents\openai.yaml"
}

function Set-ImplicitInvocation {
    param(
        [object]$Skill,
        [bool]$Enabled
    )

    $yamlPath = Get-OpenAiYamlPath -Skill $Skill
    $agentDir = Split-Path -Parent $yamlPath
    if (-not (Test-Path -LiteralPath $agentDir)) {
        New-Item -ItemType Directory -Path $agentDir | Out-Null
    }

    $value = if ($Enabled) { "true" } else { "false" }

    if (Test-Path -LiteralPath $yamlPath) {
        $content = Get-Content -LiteralPath $yamlPath -Raw

        if ($content -match "(?m)^policy:\s*$") {
            if ($content -match "(?m)^\s+allow_implicit_invocation:\s*(true|false)\s*$") {
                $content = $content -replace "(?m)^(\s+allow_implicit_invocation:\s*)(true|false)\s*$", "`${1}$value"
            } else {
                $content = $content.TrimEnd() + "`r`n  allow_implicit_invocation: $value`r`n"
            }
        } else {
            $content = $content.TrimEnd() + "`r`npolicy:`r`n  allow_implicit_invocation: $value`r`n"
        }

        Set-Content -LiteralPath $yamlPath -Value $content -NoNewline
    } else {
        $content = @"
interface:
  display_name: "$($Skill.Name)"
  short_description: "Managed by skill-router."
  default_prompt: "Use `$$($Skill.Name) for a relevant task."
policy:
  allow_implicit_invocation: $value
"@
        Set-Content -LiteralPath $yamlPath -Value $content -NoNewline
    }
}

function Get-TaskTokens {
    param([string]$Text)
    if (-not $Text) { return @() }

    $tokens = New-Object System.Collections.Generic.List[string]

    [regex]::Matches($Text.ToLowerInvariant(), "[a-z0-9\+\#\.\-]{2,}") |
        ForEach-Object { $_.Value } |
        Where-Object { $_ -notin @("the", "and", "for", "with", "use", "skill", "skills") } |
        ForEach-Object { [void]$tokens.Add($_) }

    foreach ($match in [regex]::Matches($Text, "[\u4e00-\u9fff]{2,}")) {
        $value = $match.Value
        [void]$tokens.Add($value)

        $maxN = [Math]::Min(4, $value.Length)
        for ($n = 2; $n -le $maxN; $n++) {
            for ($i = 0; $i -le $value.Length - $n; $i++) {
                [void]$tokens.Add($value.Substring($i, $n))
            }
        }
    }

    $tokens | Select-Object -Unique
}

function Get-Recommendations {
    param(
        [object[]]$AllSkills,
        [string]$TaskText
    )

    $tokens = @(Get-TaskTokens -Text $TaskText)
    $taskAscii = $TaskText.ToLowerInvariant()
    $rules = @(
        @{ Pattern = "skill|startup|boot|load|enable|disable|router|routing|\u6280\u80fd|\u8c03\u7528|\u547d\u4e2d|\u8def\u7531|\u81ea\u52a8\u52a0\u8f7d|\u9690\u5f0f|\u542f\u7528|\u7981\u7528"; Skills = @("skill-router", "skill-creator", "using-agent-skills"); Score = 30 },
        @{ Pattern = "pdf|\u8bba\u6587|\u6587\u6863|\u7248\u5f0f|\u6392\u7248|\u6e32\u67d3|\u9875\u9762|\u63d0\u53d6\u6587\u5b57"; Skills = @("pdf"); Score = 20 },
        @{ Pattern = "figma|\u8bbe\u8ba1\u7a3f|\u8282\u70b9|\u5207\u56fe|\u8fd8\u539f"; Skills = @("figma-use", "figma-implement-design", "figma"); Score = 20 },
        @{ Pattern = "react|vue|frontend|ui|html|css|page|dashboard|\u524d\u7aef|\u9875\u9762|\u754c\u9762|\u7ec4\u4ef6|\u4eea\u8868\u76d8|\u7f51\u9875"; Skills = @("frontend-ui-engineering"); Score = 15 },
        @{ Pattern = "browser|playwright|chrome|e2e|\u6d4f\u89c8\u5668|\u622a\u56fe|\u7aef\u5230\u7aef|\u81ea\u52a8\u5316\u6d4b\u8bd5"; Skills = @("playwright", "browser-testing-with-devtools"); Score = 15 },
        @{ Pattern = "debug|bug|error|failed|failure|fix|exception|\u62a5\u9519|\u5931\u8d25|\u5f02\u5e38|\u8c03\u8bd5|\u5b9a\u4f4d|\u4fee\u590d"; Skills = @("debugging-and-error-recovery"); Score = 15 },
        @{ Pattern = "test|unit|integration|tdd|spec|\u6d4b\u8bd5|\u5355\u6d4b|\u96c6\u6210\u6d4b\u8bd5"; Skills = @("test-driven-development"); Score = 15 },
        @{ Pattern = "review|audit|code review|\u5ba1\u67e5|\u8bc4\u5ba1|\u4ee3\u7801\u5ba1\u67e5|\u98ce\u9669"; Skills = @("code-review-and-quality", "review"); Score = 15 },
        @{ Pattern = "openai|chatgpt|responses api|api|\u6a21\u578b|\u5e94\u7528|apps sdk"; Skills = @("openai-docs"); Score = 15 },
        @{ Pattern = "chatgpt app|apps sdk|window\.openai|mcp app|widget|\u5c0f\u7ec4\u4ef6"; Skills = @("chatgpt-apps", "openai-docs"); Score = 25 },
        @{ Pattern = "mcp|model context protocol|server|\u5de5\u5177\u670d\u52a1\u5668|\u534f\u8bae\u670d\u52a1\u5668"; Skills = @("mcp-builder"); Score = 20 },
        @{ Pattern = "stm32|embedded|firmware|mcu|\u5355\u7247\u673a|\u5d4c\u5165\u5f0f|\u56fa\u4ef6|\u5916\u8bbe|\u4e2d\u65ad|\u4e32\u53e3|\u5b9a\u65f6\u5668|\u6807\u51c6\u5e93|hal|cubemx"; Skills = @("embedded-development"); Score = 15 },
        @{ Pattern = "\u6307\u5357\u8005|\u91ce\u706b|embedfire|stm32f103|stm32f10x|f103vet6|\u5b9e\u9a8c\u62a5\u544a|\u8bfe\u7a0b\u8bbe\u8ba1|\u5b9e\u9a8c\u8bb0\u5f55|\u6309\u952e|\u8702\u9e23\u5668|\u89e6\u6478\u5c4f|esp8266"; Skills = @("stm32f103-zhinanzhe-design"); Score = 30 },
        @{ Pattern = "vscode|vs code|intellisense|eide|uv4|st-link|j-link|cmsis-dap|\u7ea2\u6ce2\u6d6a|\u5934\u6587\u4ef6|\u70e7\u5f55|\u4e0b\u8f7d\u5931\u8d25|\u7f16\u8bd1\u65e5\u5fd7"; Skills = @("stm32-vscode"); Score = 30 },
        @{ Pattern = "\u84dd\u7259|\u519c\u4e1a|\u6e29\u5ba4|\u5927\u68da|pyserial|\u4e32\u53e3\u901a\u4fe1|\u7ee7\u7535\u5668|\u6c34\u6cf5|\u98ce\u6247|\u8865\u5149\u706f|\u4f20\u611f\u5668"; Skills = @("stm32-bluetooth-agri-control"); Score = 30 },
        @{ Pattern = "swjtu|\u897f\u5357\u4ea4\u5927|\u667a\u80fd\u5d4c\u5165\u5f0f|\u5b9e\u9a8c\u6307\u5bfc\u4e66|openocd|arm gnu|\u64cd\u4f5c\u6307\u5357|\u5b9e\u9a8c[1-8\u4e00\u4e8c\u4e09\u56db\u4e94\u516d\u4e03\u516b]"; Skills = @("embedded-stm32-labs-windows"); Score = 30 },
        @{ Pattern = "prd|requirements|\u9700\u6c42|\u4ea7\u54c1\u9700\u6c42"; Skills = @("create-prd"); Score = 15 },
        @{ Pattern = "ppt|powerpoint|slide|slides|\u5e7b\u706f\u7247|\u6f14\u793a\u6587\u7a3f"; Skills = @("ppt-master", "image-to-editable-ppt"); Score = 15 },
        @{ Pattern = "jupyter|ipynb|notebook|\u7b14\u8bb0\u672c|\u5b9e\u9a8c\u8bb0\u5f55|\u6570\u636e\u5206\u6790"; Skills = @("jupyter-notebook"); Score = 20 },
        @{ Pattern = "\u8f6c\u5199|\u8f6c\u5f55|\u5b57\u5e55|\u5f55\u97f3|\u97f3\u9891|\u89c6\u9891|\u4f1a\u8bae|\u8bbf\u8c08|\u8bf4\u8bdd\u4eba|diarization"; Skills = @("transcribe"); Score = 20 },
        @{ Pattern = "tts|text-to-speech|\u8bed\u97f3\u5408\u6210|\u6587\u672c\u8f6c\u8bed\u97f3|\u914d\u97f3|\u65c1\u767d|\u6717\u8bfb"; Skills = @("speech"); Score = 20 }
    )

    $scores = @{}
    foreach ($skill in $AllSkills) {
        $haystack = (($skill.Name + " " + $skill.Description).ToLowerInvariant())
        $score = 0
        foreach ($token in $tokens) {
            if ($haystack.Contains($token.ToLowerInvariant())) {
                $score += 1
            }
        }
        if ($score -ge 3) {
            $scores[$skill.Name] = [math]::Max($scores[$skill.Name], $score)
        }
    }

    foreach ($rule in $rules) {
        if ($taskAscii -match $rule.Pattern) {
            $ruleScore = if ($rule.ContainsKey("Score")) { [int]$rule.Score } else { 10 }
            foreach ($name in $rule.Skills) {
                $scores[$name] = [math]::Max($scores[$name], $ruleScore)
            }
        }
    }

    $seen = @{}
    $AllSkills |
        Where-Object { $scores.ContainsKey($_.Name) } |
        Sort-Object @{ Expression = { -1 * $scores[$_.Name] } }, Name |
        Where-Object {
            if ($seen.ContainsKey($_.Name)) {
                $false
            } else {
                $seen[$_.Name] = $true
                $true
            }
        } |
        Select-Object -First 8 Name, Description, Directory
}

$Roots = @(Normalize-List -Items $Roots)
$Skills = @(Normalize-List -Items $Skills)
$searchRoots = if ($Roots.Count -gt 0) { $Roots } else { Get-DefaultRoots }
$allSkills = @(Get-Skills -SearchRoots $searchRoots)

if ($Action -eq "list") {
    $allSkills | Select-Object Name, Directory, Description | Format-Table -AutoSize
    exit 0
}

if ($Action -eq "recommend") {
    if (-not $Task) {
        throw "Pass -Task when using -Action recommend."
    }

    $recommendations = @(Get-Recommendations -AllSkills $allSkills -TaskText $Task)
    if ($recommendations.Count -eq 0) {
        Write-Output "No strong match. Start with skill-router and explicitly invoke a domain skill if the task reveals one."
    } else {
        $recommendations | Format-Table -AutoSize
    }
    exit 0
}

if ($Skills.Count -eq 0) {
    throw "Pass -Skills for -Action $Action."
}

$skillMap = @{}
foreach ($skill in $allSkills) {
    if (-not $skillMap.ContainsKey($skill.Name)) {
        $skillMap[$skill.Name] = $skill
    }
}

foreach ($name in $Skills) {
    if (-not $skillMap.ContainsKey($name)) {
        throw "Skill not found: $name"
    }
}

if ($Action -eq "enable" -or $Action -eq "disable") {
    $enabled = $Action -eq "enable"
    foreach ($name in $Skills) {
        Set-ImplicitInvocation -Skill $skillMap[$name] -Enabled $enabled
        Write-Output "$Action $name"
    }
    exit 0
}

if ($Action -eq "only") {
    $keep = @{}
    foreach ($name in ($Skills + "skill-router")) {
        $keep[$name] = $true
    }

    foreach ($skill in $allSkills) {
        if ($skill.IsSystem) {
            continue
        }
        $enabled = $keep.ContainsKey($skill.Name)
        Set-ImplicitInvocation -Skill $skill -Enabled $enabled
        if ($enabled) {
            Write-Output "enable $($skill.Name)"
        } else {
            Write-Output "disable $($skill.Name)"
        }
    }
}

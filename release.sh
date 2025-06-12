#!/bin/bash

# Pawcus 자동 릴리즈 스크립트

set -e

echo "🐾 Pawcus Release Automation"
echo "============================="

echo "📦  Zipping Pawcus.app..."
mkdir -p ./dist
cp -R "/Applications/Pawcus.app" ./dist/Pawcus.app
cd dist
zip -r Pawcus.zip Pawcus.app
cd ..

# 버전 입력받기
read -p "🏷️  Enter release version (e.g., 0.2.0): " version

if [ -z "$version" ]; then
    echo "❌ Version is required"
    exit 1
fi

echo "📝 Creating release for version: $version"

# Git 상태 확인
if ! git diff --quiet || ! git diff --cached --quiet; then
    echo "⚠️  Uncommitted changes detected:"
    git status --short
    echo ""
    read -p "🤔 Do you want to commit these changes first? (y/N): " -n 1 -r
    echo
    
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        read -p "📝 Enter commit message: " commit_msg
        git add .
        git commit -m "$commit_msg"
        echo "✅ Changes committed"
    else
        echo "❌ Please commit or stash changes before creating a release"
        exit 1
    fi
fi

# 태그 생성
tag="v$version"
echo "🏷️  Creating tag: $tag"

if git tag -l | grep -q "^$tag$"; then
    echo "❌ Tag $tag already exists"
    exit 1
fi

# 릴리즈 노트 작성
echo ""
echo "📋 Creating release notes..."
release_notes_file="release_notes_$version.md"

cat > "$release_notes_file" << EOF
## Pawcus $version

### 🚀 새로운 기능
- 

### 🐛 버그 수정
- 

### 🔧 개선사항
- 

### 📋 시스템 요구사항
- macOS 13.0 이상
- 접근성 권한 필요

### 📦 설치 방법

**Homebrew (추천):**
\`\`\`bash
brew tap swmaeStrong/pawcus
brew install --cask pawcus
\`\`\`

**직접 다운로드:**
- \`Pawcus.dmg\` - 설치 프로그램
- \`Pawcus.zip\` - 포터블 버전
EOF

echo "📝 Please edit the release notes:"
echo "   $release_notes_file"
echo ""
read -p "🤔 Press Enter after editing the release notes..."

# 릴리즈 노트 읽기
if [ ! -f "$release_notes_file" ]; then
    echo "❌ Release notes file not found"
    exit 1
fi

release_body=$(cat "$release_notes_file")

# 태그 생성 및 푸시
git tag -a "$tag" -m "Release $version"
git push origin "$tag"

echo "✅ Tag created and pushed"

# GitHub CLI로 릴리즈 생성
echo "🚀 Creating GitHub release..."

gh release create "$tag" \
    ./dist/Pawcus.zip \
    --title "Pawcus $version" \
    --notes "$release_body" \
    --draft=false \
    --prerelease=false

echo "✅ GitHub release created successfully!"

# 정리
rm "$release_notes_file"

echo ""
echo "🎉 Release $version created successfully!"
echo ""
echo "📋 Next steps:"
echo "1. GitHub Actions will automatically build and upload assets"
echo "2. Homebrew cask will be automatically updated"
echo "3. Check the release at: https://github.com/swmaeStrong/MVP_Mac/releases/tag/$tag"
echo ""
echo "🔗 Useful commands:"
echo "   - Monitor build: gh run list"
echo "   - View release: gh release view $tag"

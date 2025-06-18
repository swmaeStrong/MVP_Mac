# Pawcus 자동 릴리즈 프로세스

## 개요

Pawcus는 GitHub Actions를 통해 완전히 자동화된 릴리즈 프로세스를 사용합니다. 버전 태그가 푸시되거나 수동으로 워크플로우를 실행하면, 앱이 빌드되고 서명되며, Sparkle 업데이트가 Supabase에 업로드되고, GitHub 릴리즈가 생성됩니다.

## 사전 요구사항

### GitHub Secrets 설정
다음 시크릿들이 GitHub 저장소에 설정되어 있어야 합니다:

- **`TEAM_ID`**: Apple Developer Team ID (Xcode 앱 서명용)
- **`DEVELOPER_ID_APPLICATION_CERT`**: Developer ID Application 인증서 (Base64 인코딩된 .p12 파일)
- **`DEVELOPER_ID_APPLICATION_PASSWORD`**: Developer ID Application 인증서 비밀번호
- **`KEYCHAIN_PASSWORD`**: CI 환경 키체인 비밀번호 (임의 설정)
- **`BASE_DOMAIN`**: 백엔드 도메인 (예: 3.39.105.127)
- **`SUPABASE_KEY`**: Supabase JWT 토큰
- **`SUPABASE_DOMAIN`**: Supabase 프로젝트 도메인
- **`SUPABASE_ANON_KEY`**: Supabase 익명 키
- **`SUPABASE_URL`**: Supabase 프로젝트 URL
- **`SUPABASE_SERVICE_ROLE_KEY`**: Supabase 서비스 역할 키 (스토리지 업로드용)
- **`HOMEBREW_UPDATE_TOKEN`**: Homebrew cask 업데이트 트리거용 GitHub 토큰
- **`SPARKLE_EDDSA_PRIVATE_KEY`**: (권장) Sparkle EdDSA 개인 키 (업데이트 서명용)
- **`APPLE_ID`**: (선택사항) Notarization을 위한 Apple ID
- **`APPLE_ID_PASSWORD`**: (선택사항) App-specific password for notarization

### Developer ID 인증서 설정
1. **인증서 내보내기**:
   - Keychain Access에서 Developer ID Application 인증서 선택
   - 우클릭 → "Export" → .p12 파일로 저장
   - 비밀번호 설정

2. **Base64 인코딩**:
   ```bash
   base64 -i certificate.p12 | pbcopy
   ```

3. **GitHub Secrets에 추가**:
   - `DEVELOPER_ID_APPLICATION_CERT`: Base64 인코딩된 인증서 내용
   - `DEVELOPER_ID_APPLICATION_PASSWORD`: 인증서 비밀번호
   - `KEYCHAIN_PASSWORD`: 임의의 강력한 비밀번호

### Sparkle EdDSA 키 설정 (권장)
1. **EdDSA 키 쌍 생성**:
   ```bash
   # Sparkle의 generate_keys 도구 사용
   ./bin/generate_keys
   ```

2. **개인 키를 GitHub Secrets에 추가**:
   - `SPARKLE_EDDSA_PRIVATE_KEY`: 생성된 개인 키 파일의 내용
   - 공개 키는 앱의 Info.plist `SUPublicEDKey`에 설정

3. **보안 주의사항**:
   - 개인 키는 절대 저장소에 커밋하지 마세요
   - GitHub Secrets에만 저장하세요

### Supabase 스토리지 설정
1. Supabase 대시보드에서 `sparkle-updates`라는 public 버킷 생성
2. 버킷이 public 읽기 권한을 가지도록 설정
3. 서비스 역할 키가 업로드 권한을 가지도록 확인

### Sparkle 설정
앱의 `Info.plist`에 다음이 포함되어 있어야 합니다:
```xml
<key>SUFeedURL</key>
<string>https://agsrumeaczdydskvqxlr.supabase.co/storage/v1/object/public/sparkle-updates/appcast.xml</string>
<key>SUPublicEDKey</key>
<string>XYqUVZF83dzRohHy5RGDM0wYkGdJlKVqvsikWBAKAmk=</string>
```

## 릴리즈 프로세스

### 자동 트리거 (권장)
```bash
# 버전 태그를 푸시하여 릴리즈 트리거
git tag v1.0.0
git push origin v1.0.0
```

### 수동 트리거
1. GitHub 저장소의 Actions 탭으로 이동
2. "Build and Release" 워크플로우 선택
3. "Run workflow" 클릭
4. 버전 번호 입력 (예: 1.0.0)
5. "Run workflow" 클릭

## 워크플로우 단계

1. **빌드 준비**
   - Xcode 최신 버전 설정
   - 코드 체크아웃
   - 버전 정보 설정

2. **앱 빌드 및 서명**
   - Developer ID Application으로 코드 서명된 앱 아카이브
   - 자동 프로비저닝으로 앱 익스포트
   - Notarization (APPLE_ID가 설정된 경우)

3. **Sparkle 업데이트 준비**
   - Sparkle 도구 다운로드
   - EdDSA로 ZIP 파일 서명
   - 체크섬 및 파일 크기 계산

4. **appcast.xml 생성**
   - 버전 정보, 서명, 파일 크기 포함
   - Supabase 스토리지 URL 참조

5. **Supabase 업로드**
   - `Pawcus.zip`을 `sparkle-updates` 버킷에 업로드
   - `appcast.xml`을 동일한 버킷에 업로드
   - 기존 파일 덮어쓰기 (`x-upsert: true`)

6. **GitHub 릴리즈 생성**
   - 릴리즈 노트와 함께 GitHub 릴리즈 생성
   - DMG, ZIP, 체크섬, appcast.xml 파일 첨부

7. **Homebrew 업데이트**
   - Homebrew cask 저장소에 업데이트 트리거

## 파일 구조

### Supabase 스토리지
```
sparkle-updates/
├── Pawcus.zip          # 최신 버전 앱 (서명됨)
└── appcast.xml         # Sparkle 업데이트 피드
```

### GitHub 릴리즈 자산
```
- Pawcus.dmg            # 설치 프로그램
- Pawcus.zip            # 휴대용 버전
- Pawcus.dmg.sha256     # DMG 체크섬
- Pawcus.zip.sha256     # ZIP 체크섬
- appcast.xml           # 업데이트 피드
```

## 업데이트 흐름

1. 사용자가 앱을 실행하면 Sparkle이 자동으로 업데이트 확인
2. Supabase의 `appcast.xml` 파일을 확인
3. 새 버전이 있으면 사용자에게 알림
4. 사용자가 업데이트를 승인하면 `Pawcus.zip` 다운로드
5. EdDSA 서명 검증
6. 앱 업데이트 및 재시작

## 문제 해결

### 빌드 실패
- Xcode 버전이 프로젝트 요구사항과 일치하는지 확인
- Team ID가 올바르게 설정되었는지 확인
- Developer ID Application 인증서가 키체인에 설치되어 있는지 확인
- GitHub Actions runner에서 인증서 접근 권한이 있는지 확인

### Notarization 실패 (선택사항)
- Apple ID와 App-specific password가 올바른지 확인
- Team ID가 Apple Developer 계정과 일치하는지 확인
- 인터넷 연결이 안정적인지 확인

### 업로드 실패
- Supabase URL과 서비스 역할 키가 올바른지 확인
- `sparkle-updates` 버킷이 존재하고 public인지 확인
- 서비스 역할 키가 스토리지 쓰기 권한이 있는지 확인

### 업데이트가 표시되지 않음
- 앱의 `SUFeedURL`이 올바른 Supabase URL을 가리키는지 확인
- `appcast.xml`이 올바르게 생성되고 업로드되었는지 확인
- 버전 번호가 현재 설치된 버전보다 높은지 확인

## 보안 고려사항

- EdDSA 개인 키는 로컬에 안전하게 보관 (저장소에 커밋하지 않음)
- Supabase 서비스 역할 키는 GitHub Secrets에만 저장
- 모든 업데이트는 암호화 서명으로 검증됨

## 참고 자료

- [Sparkle Documentation](https://sparkle-project.org/)
- [Supabase Storage Documentation](https://supabase.com/docs/guides/storage)
- [GitHub Actions Documentation](https://docs.github.com/en/actions)
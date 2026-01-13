# 🔔 FCM 푸시 알림 실습 앱

Firebase Cloud Messaging(FCM)을 사용한 푸시 알림 구현 실습 프로젝트입니다.

## 📚 학습 내용

- FCM 초기화 및 권한 요청
- FCM 토큰 관리
- 포그라운드/백그라운드 메시지 처리
- 토픽 구독/해제
- 알림 클릭 시 딥링크 처리

---

## 🚀 시작하기 (git clone 이후)

### 1단계: 패키지 설치

```bash
flutter pub get
```

### 2단계: Firebase 프로젝트 생성

1. [Firebase 콘솔](https://console.firebase.google.com/)에 접속합니다.
2. **"프로젝트 추가"** 버튼을 클릭합니다.
3. 프로젝트 이름을 입력합니다. (예: `fcm-push-demo`)
4. Google 애널리틱스는 선택사항입니다. (실습에서는 비활성화해도 됨)
5. **"프로젝트 만들기"**를 클릭하고 완료될 때까지 기다립니다.

### 3단계: FlutterFire CLI 설치 및 설정

#### 3-1. FlutterFire CLI 설치 (최초 1회)

```bash
dart pub global activate flutterfire_cli
```

> ⚠️ **PATH 설정 안내**  
> 설치 후 `flutterfire` 명령어가 인식되지 않으면 아래 경로를 PATH에 추가하세요:
>
> - macOS/Linux: `~/.pub-cache/bin`
> - Windows: `%LOCALAPPDATA%\Pub\Cache\bin`

com.회사명.어플명 <-

#### 3-2. Firebase 로그인 (최초 1회)

```bash
firebase login
```

브라우저가 열리면 Google 계정으로 로그인합니다.

#### 3-3. Firebase 프로젝트 연결

프로젝트 루트 디렉토리에서 실행합니다:

```bash
flutterfire configure
```

실행하면 다음과 같은 질문이 나옵니다:

1. **Select a Firebase project**: 위에서 생성한 프로젝트 선택
2. **Which platforms should your configuration support?**:
   - `android`, `ios` 선택 (Space로 선택, Enter로 확인)
3. **Android package name**: 엔터 (기본값 사용: `com.spartaadvanced_flutter`)
4. **iOS bundle id**: 엔터 (기본값 사용)

완료되면 자동으로 다음 파일들이 생성/수정됩니다:

- `lib/firebase_options.dart` (자동 생성)
- `android/app/google-services.json` (자동 생성)
- `ios/Runner/GoogleService-Info.plist` (자동 생성)
- `ios/firebase_app_id_file.json` (자동 생성)

### 4단계: main.dart 수정

`lib/main.dart` 파일에서 Firebase 초기화 부분을 수정합니다:

```dart
import 'firebase_options.dart';  // 이 줄 추가

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Firebase 초기화 (options 추가)
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,  // 이 줄 수정
  );

  runApp(const MyApp());
}
```

### 5단계: iOS 추가 설정 (macOS에서 iOS로 빌드하는 경우)

#### 5-1. CocoaPods 설치 확인

```bash
pod --version
```

설치되어 있지 않다면:

```bash
sudo gem install cocoapods
```

#### 5-2. Pod 설치

```bash
cd ios
pod install
cd ..
```

#### 5-3. Xcode에서 Signing 설정

1. `ios/Runner.xcworkspace`를 Xcode에서 엽니다.
2. Runner 프로젝트 선택 → Signing & Capabilities 탭
3. Team을 본인의 Apple Developer 계정으로 설정
4. **+ Capability** 클릭 → **Push Notifications** 추가
5. **+ Capability** 클릭 → **Background Modes** 추가 후:
   - ✅ Background fetch
   - ✅ Remote notifications

### 6단계: 앱 실행

```bash
# Android
flutter run

# iOS (macOS에서만)
flutter run -d ios
```

---

## 🧪 푸시 알림 테스트 방법

### Firebase 콘솔에서 테스트 알림 보내기

1. [Firebase 콘솔](https://console.firebase.google.com/) → 프로젝트 선택
2. 왼쪽 메뉴에서 **Run** → **Messaging** 클릭
3. **"첫 번째 캠페인 만들기"** 또는 **"새 캠페인"** 클릭
4. **"Firebase 알림 메시지"** 선택

#### 알림 작성

| 항목        | 입력값 예시                   |
| ----------- | ----------------------------- |
| 알림 제목   | `안녕하세요! 🎉`              |
| 알림 텍스트 | `FCM 푸시 알림 테스트입니다.` |

#### 타겟 설정

**방법 1: 특정 기기로 전송 (FCM 토큰 사용)**

1. 앱에서 FCM 토큰 복사
2. 타겟 → 단일 기기 → 토큰 붙여넣기

**방법 2: 토픽 구독자에게 전송**

1. 앱에서 토픽 구독 (예: `news`, `promo`)
2. 타겟 → 토픽 → 토픽명 입력

#### 딥링크용 커스텀 데이터 추가

**추가 옵션** → **맞춤 데이터**에서 키-값 쌍 추가:

| Key      | Value    | 설명                    |
| -------- | -------- | ----------------------- |
| `screen` | `detail` | 알림 상세 화면으로 이동 |
| `screen` | `promo`  | 프로모션 화면으로 이동  |
| `id`     | `123`    | 화면에 전달할 ID        |

---

## 📁 프로젝트 구조

```
lib/
├── main.dart                           # 앱 진입점 및 라우팅
├── firebase_options.dart               # Firebase 설정 (자동 생성)
├── services/
│   └── fcm_service.dart                # FCM 서비스 클래스
└── screens/
    ├── home_screen.dart                # 홈 화면 (토픽 구독/해제)
    ├── notification_detail_screen.dart # 알림 상세 화면 (딥링크)
    └── promo_screen.dart               # 프로모션 화면 (딥링크)
```

---

## 🔗 딥링크 URL 스킴

| URL                                        | 대상 화면      |
| ------------------------------------------ | -------------- |
| `advancedflutter://app/detail?id=123`      | 알림 상세 화면 |
| `advancedflutter://app/promo?id=PROMO2024` | 프로모션 화면  |

---

## ❓ 트러블슈팅

### `flutterfire` 명령어를 찾을 수 없음

```bash
# PATH에 pub cache bin 추가 (macOS/Linux)
export PATH="$PATH":"$HOME/.pub-cache/bin"

# 또는 직접 실행
dart pub global run flutterfire_cli:flutterfire configure
```

### Android 빌드 실패 - `google-services.json` 없음

`flutterfire configure`를 다시 실행하여 파일을 생성하세요.

### iOS 빌드 실패 - Pod 관련 에러

```bash
cd ios
pod deintegrate
pod install
cd ..
flutter clean
flutter pub get
```

### 알림이 오지 않음 (Android)

1. 앱 설정에서 알림 권한이 허용되어 있는지 확인
2. Android 13 이상에서는 앱 최초 실행 시 권한 요청 팝업이 표시됨
3. 배터리 최적화 예외 목록에 앱 추가

### 알림이 오지 않음 (iOS)

1. 실제 기기에서 테스트 (시뮬레이터는 푸시 알림 미지원)
2. Xcode에서 Push Notifications capability 추가 확인
3. Apple Developer에서 푸시 인증서/키 설정 확인

---

## 📖 참고 자료

- [Firebase Cloud Messaging 공식 문서](https://firebase.google.com/docs/cloud-messaging)
- [FlutterFire 공식 문서](https://firebase.flutter.dev/docs/messaging/overview)
- [flutter_local_notifications 패키지](https://pub.dev/packages/flutter_local_notifications)
- [go_router 패키지](https://pub.dev/packages/go_router)

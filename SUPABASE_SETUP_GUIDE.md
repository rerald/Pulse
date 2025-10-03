# 🚀 Supabase 연결 가이드

## 1단계: Supabase 프로젝트 생성

### 1.1 계정 생성 및 로그인
1. [Supabase 웹사이트](https://supabase.com) 접속
2. "Start your project" 클릭
3. GitHub 계정으로 로그인

### 1.2 새 프로젝트 생성
1. "New Project" 클릭
2. 프로젝트 설정:
   - **Name**: `주휴수당관리시스템`
   - **Database Password**: 강력한 비밀번호 생성 (기억해두세요!)
   - **Region**: `Northeast Asia (Seoul)` 선택
   - **Pricing Plan**: `Free` 선택
3. "Create new project" 클릭

## 2단계: 데이터베이스 스키마 생성

### 2.1 SQL Editor 접속
1. 프로젝트 대시보드에서 **SQL Editor** 클릭
2. **New Query** 클릭

### 2.2 스키마 실행
1. `database_schema.sql` 파일 내용을 복사
2. SQL Editor에 붙여넣기
3. **Run** 버튼 클릭하여 실행
4. 성공 메시지 확인

## 3단계: API 키 확인

### 3.1 API 설정 페이지 접속
1. 왼쪽 메뉴에서 **Settings** 클릭
2. **API** 탭 클릭

### 3.2 필요한 정보 복사
- **Project URL**: `https://your-project-id.supabase.co`
- **anon public key**: `eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...`

## 4단계: 프론트엔드 연결 설정

### 4.1 설정 파일 수정
`supabase-config.js` 파일을 열고 다음 정보를 실제 값으로 교체:

```javascript
const SUPABASE_CONFIG = {
    url: 'https://your-actual-project-id.supabase.co', // 실제 Project URL
    anonKey: 'your-actual-anon-key' // 실제 anon public key
};
```

### 4.2 연결 테스트
1. HTML 파일을 브라우저에서 열기
2. 개발자 도구 (F12) → Console 탭 확인
3. "✅ Supabase 데이터베이스 연결 완료" 메시지 확인

## 5단계: 데이터 확인

### 5.1 Table Editor에서 확인
1. Supabase 대시보드에서 **Table Editor** 클릭
2. 생성된 테이블들 확인:
   - `businesses` - 사업장 정보
   - `employees` - 직원 정보
   - `work_logs` - 근무 기록
   - `weekly_allowances` - 주휴수당
   - `salaries` - 급여 정보
   - `admins` - 관리자 계정
   - `business_admins` - 사업장-관리자 연결
   - `system_settings` - 시스템 설정

### 5.2 샘플 데이터 확인
각 테이블에 샘플 데이터가 자동으로 삽입되었는지 확인

## 6단계: 보안 설정 (선택사항)

### 6.1 Row Level Security (RLS) 설정
- 현재 스키마에 RLS 정책이 포함되어 있음
- 필요에 따라 추가 보안 정책 설정 가능

### 6.2 API 키 보안
- `anon` key는 공개되어도 안전함
- `service_role` key는 절대 공개하지 말 것

## 🔧 문제 해결

### 연결 실패 시
1. **URL과 API 키 확인**: 올바른 값인지 다시 확인
2. **네트워크 확인**: 인터넷 연결 상태 확인
3. **브라우저 콘솔 확인**: 에러 메시지 확인

### 데이터베이스 오류 시
1. **SQL 문법 확인**: 스키마 파일의 SQL 문법 확인
2. **권한 확인**: Supabase 프로젝트 권한 확인
3. **테이블 상태 확인**: Table Editor에서 테이블 생성 여부 확인

## 📞 지원

문제가 발생하면:
1. Supabase 공식 문서: https://supabase.com/docs
2. Supabase 커뮤니티: https://github.com/supabase/supabase/discussions
3. 프로젝트 설정 재확인

---

**다음 단계**: 연결이 완료되면 실제 데이터 CRUD 작업을 구현할 수 있습니다!

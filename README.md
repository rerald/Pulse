# 주휴수당 계산기 및 근무관리 MVP

세무법인 청년들을 위한 주휴수당 계산기 및 근무관리 시스템의 MVP 버전입니다.

## 📋 프로젝트 개요

### 배경
- 세무법인 청년들이 거래처에서 주휴수당 계산을 요청받고 있음
- 노무 리스크 최소화를 위한 자율적 관리 도구 필요
- ERP(블루홀) 및 모바일 앱(콜베르) 연동 기반 마련

### 목적
1. 청년들의 직접 계산 리스크 최소화
2. 거래처의 자율적 관리 지원
3. 향후 시스템 연동 기반 구축

## 🚀 주요 기능

### 직원 화면
- ✅ 출근·퇴근·휴게시간 입력
- ✅ 이전 입력값 자동 불러오기
- ✅ 실시간 예상 급여·주휴수당 확인
- ✅ 히스토리 카드뷰 (날짜별 기록, 승인 여부 표시)
- ✅ 월별 캘린더 뷰
- ✅ 로컬스토리지 데이터 저장

### 주휴수당 계산
- **계산 공식**: `(소정근로시간 ÷ 40시간) × 8시간 × 시급`
- **요건**: 주 15시간 이상 근무
- **실시간 계산**: 입력값 변경 시 즉시 반영

### UI/UX
- 토스 스타일 디자인 (심플·가독성·카드형 레이아웃)
- 모바일 최적화 (424px 최대 너비)
- 시간 입력 강조 (28px 굵은 글씨)
- 상태 표시 (정상/지각/결근)

## 🛠 기술 스택

- **Frontend**: HTML5, CSS3, Vanilla JavaScript
- **Storage**: LocalStorage (프론트엔드 전용)
- **Design**: 토스 UI 톤 벤치마킹
- **Backend**: Supabase (향후 연동 예정)

## 📁 파일 구조

```
Pulse/
├── employee-mvp-enhanced.html  # 메인 앱 (직원 화면)
├── 기획서                      # 프로젝트 기획서
├── README.md                   # 프로젝트 문서
└── .gitignore                  # Git 무시 파일
```

## 🎯 사용 방법

1. **근무 기록 입력**
   - 출근/퇴근 시간 선택
   - 휴게시간 입력
   - 실시간 계산 결과 확인

2. **제출 및 저장**
   - "검토 완료 후 제출" 클릭
   - 로컬스토리지에 자동 저장

3. **히스토리 확인**
   - 주차별 근무 기록 확인
   - 승인 상태 확인
   - 주휴수당 계산 결과 확인

4. **캘린더 뷰**
   - 상단 달력 아이콘 클릭
   - 월별 근무 현황 확인
   - 날짜별 상태 표시

## 📊 계산 로직

### 주휴수당
```javascript
function calculateWeeklyAllowance(totalHours, hourlyWage) {
  if (totalHours >= 15) {
    return (totalHours / 40) * 8 * hourlyWage;
  }
  return 0;
}
```

### 근무시간
```javascript
function calculateWorkHours(inTime, outTime, breakMin) {
  const inMinutes = hmToMinutes(inTime);
  const outMinutes = hmToMinutes(outTime);
  const breakMinutes = parseInt(breakMin) || 0;
  const totalMinutes = Math.max(0, outMinutes - inMinutes - breakMinutes);
  return totalMinutes / 60;
}
```

## 🔄 확장 로드맵

1. **현재 단계**: 프론트엔드 MVP (완료)
2. **다음 단계**: Supabase 백엔드 연동
3. **향후 계획**: 사장님 화면, 승인 시스템
4. **최종 목표**: ERP 및 모바일 앱 연동

## ⚠️ 면책 조항

> 본 계산은 입력값과 단순 규칙에 따른 참고치입니다. 최종 확정은 사업주의 책임입니다.

## 👥 기여자

- **개발자**: 이규상 (카스)
- **기획**: 세무법인 청년들

## 📅 개발 일정

- **2025-01-15**: MVP 프론트엔드 완성
- **향후**: 백엔드 연동 및 확장 기능 개발

---

*세무법인 청년들 - 주휴수당 계산기 MVP*

-- 주휴수당 계산기 및 근무관리 시스템 데이터베이스 스키마
-- Supabase 프로젝트: omplskojbargxeiodqdr
-- 실행일: 2025년 1월

-- ==============================================
-- 1. 기본 테이블 생성
-- ==============================================

-- 사업장 테이블
CREATE TABLE businesses (
    id VARCHAR(20) PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    registration_number VARCHAR(20) UNIQUE NOT NULL,
    owner_name VARCHAR(50) NOT NULL,
    business_type VARCHAR(50) NOT NULL,
    address TEXT NOT NULL,
    phone VARCHAR(20),
    email VARCHAR(100),
    contract_start_date DATE,
    status VARCHAR(20) DEFAULT 'active' CHECK (status IN ('active', 'inactive', 'suspended')),
    memo TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- 직원 테이블
CREATE TABLE employees (
    id VARCHAR(20) PRIMARY KEY,
    business_id VARCHAR(20) NOT NULL,
    name VARCHAR(50) NOT NULL,
    id_number VARCHAR(20) UNIQUE NOT NULL,
    position VARCHAR(50),
    employment_type VARCHAR(20) NOT NULL CHECK (employment_type IN ('regular', 'part-time', 'short-time')),
    start_date DATE NOT NULL,
    hourly_wage INTEGER NOT NULL CHECK (hourly_wage > 0),
    monthly_hours INTEGER DEFAULT 0 CHECK (monthly_hours >= 0),
    phone VARCHAR(20),
    address TEXT,
    memo TEXT,
    status VARCHAR(20) DEFAULT 'active' CHECK (status IN ('active', 'inactive')),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (business_id) REFERENCES businesses(id) ON DELETE CASCADE
);

-- 근무 기록 테이블
CREATE TABLE work_logs (
    id VARCHAR(20) PRIMARY KEY,
    employee_id VARCHAR(20) NOT NULL,
    work_date DATE NOT NULL,
    clock_in TIME NOT NULL,
    clock_out TIME NOT NULL,
    break_minutes INTEGER DEFAULT 0 CHECK (break_minutes >= 0),
    work_hours DECIMAL(4,2) NOT NULL CHECK (work_hours >= 0),
    status VARCHAR(20) NOT NULL CHECK (status IN ('normal', 'late', 'absent')),
    approval_status VARCHAR(20) DEFAULT 'pending' CHECK (approval_status IN ('pending', 'approved', 'rejected', 'hold')),
    approved_at TIMESTAMP WITH TIME ZONE NULL,
    rejected_at TIMESTAMP WITH TIME ZONE NULL,
    note TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (employee_id) REFERENCES employees(id) ON DELETE CASCADE,
    UNIQUE (employee_id, work_date)
);

-- 주휴수당 테이블
CREATE TABLE weekly_allowances (
    id VARCHAR(20) PRIMARY KEY,
    employee_id VARCHAR(20) NOT NULL,
    week_start_date DATE NOT NULL,
    week_end_date DATE NOT NULL,
    total_hours DECIMAL(5,2) NOT NULL CHECK (total_hours >= 0),
    hourly_wage INTEGER NOT NULL CHECK (hourly_wage > 0),
    allowance_amount INTEGER NOT NULL CHECK (allowance_amount >= 0),
    status VARCHAR(20) DEFAULT 'pending' CHECK (status IN ('pending', 'approved', 'rejected')),
    approved_at TIMESTAMP WITH TIME ZONE NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (employee_id) REFERENCES employees(id) ON DELETE CASCADE,
    UNIQUE (employee_id, week_start_date)
);

-- 급여 테이블
CREATE TABLE salaries (
    id VARCHAR(20) PRIMARY KEY,
    employee_id VARCHAR(20) NOT NULL,
    year INTEGER NOT NULL CHECK (year >= 2020 AND year <= 2100),
    month INTEGER NOT NULL CHECK (month >= 1 AND month <= 12),
    total_hours DECIMAL(6,2) NOT NULL CHECK (total_hours >= 0),
    basic_salary INTEGER NOT NULL CHECK (basic_salary >= 0),
    overtime_hours DECIMAL(5,2) DEFAULT 0 CHECK (overtime_hours >= 0),
    overtime_pay INTEGER DEFAULT 0 CHECK (overtime_pay >= 0),
    weekly_allowance INTEGER DEFAULT 0 CHECK (weekly_allowance >= 0),
    total_salary INTEGER NOT NULL CHECK (total_salary >= 0),
    status VARCHAR(20) DEFAULT 'pending' CHECK (status IN ('pending', 'approved', 'paid')),
    paid_at TIMESTAMP WITH TIME ZONE NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (employee_id) REFERENCES employees(id) ON DELETE CASCADE,
    UNIQUE (employee_id, year, month)
);

-- 관리자 테이블
CREATE TABLE admins (
    id VARCHAR(20) PRIMARY KEY,
    username VARCHAR(50) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    name VARCHAR(50) NOT NULL,
    role VARCHAR(20) DEFAULT 'staff' CHECK (role IN ('super_admin', 'admin', 'staff')),
    status VARCHAR(20) DEFAULT 'active' CHECK (status IN ('active', 'inactive')),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- 사업장 관리자 연결 테이블
CREATE TABLE business_admins (
    id VARCHAR(20) PRIMARY KEY,
    business_id VARCHAR(20) NOT NULL,
    admin_id VARCHAR(20) NOT NULL,
    assigned_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (business_id) REFERENCES businesses(id) ON DELETE CASCADE,
    FOREIGN KEY (admin_id) REFERENCES admins(id) ON DELETE CASCADE,
    UNIQUE (business_id, admin_id)
);

-- 시스템 설정 테이블
CREATE TABLE system_settings (
    id VARCHAR(20) PRIMARY KEY,
    setting_key VARCHAR(100) UNIQUE NOT NULL,
    setting_value TEXT,
    description TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- ==============================================
-- 2. 인덱스 생성
-- ==============================================

-- 자주 조회되는 컬럼에 인덱스 추가
CREATE INDEX idx_work_logs_employee_date ON work_logs(employee_id, work_date);
CREATE INDEX idx_work_logs_approval_status ON work_logs(approval_status);
CREATE INDEX idx_work_logs_work_date ON work_logs(work_date);
CREATE INDEX idx_employees_business_id ON employees(business_id);
CREATE INDEX idx_employees_status ON employees(status);
CREATE INDEX idx_weekly_allowances_employee_week ON weekly_allowances(employee_id, week_start_date);
CREATE INDEX idx_weekly_allowances_status ON weekly_allowances(status);
CREATE INDEX idx_salaries_employee_month ON salaries(employee_id, year, month);
CREATE INDEX idx_salaries_status ON salaries(status);
CREATE INDEX idx_businesses_status ON businesses(status);
CREATE INDEX idx_business_admins_business_id ON business_admins(business_id);
CREATE INDEX idx_business_admins_admin_id ON business_admins(admin_id);

-- ==============================================
-- 3. 트리거 함수 생성 (업데이트 시간 자동 갱신)
-- ==============================================

-- 업데이트 시간 자동 갱신 함수
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ language 'plpgsql';

-- 각 테이블에 트리거 적용
CREATE TRIGGER update_businesses_updated_at BEFORE UPDATE ON businesses FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_employees_updated_at BEFORE UPDATE ON employees FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_work_logs_updated_at BEFORE UPDATE ON work_logs FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_weekly_allowances_updated_at BEFORE UPDATE ON weekly_allowances FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_salaries_updated_at BEFORE UPDATE ON salaries FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_admins_updated_at BEFORE UPDATE ON admins FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_system_settings_updated_at BEFORE UPDATE ON system_settings FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- ==============================================
-- 4. 샘플 데이터 삽입
-- ==============================================

-- 시스템 설정 기본값
INSERT INTO system_settings (id, setting_key, setting_value, description) VALUES
('SET001', 'min_weekly_hours', '15', '주휴수당 최소 주간 근무시간'),
('SET002', 'standard_weekly_hours', '40', '표준 주간 근무시간'),
('SET003', 'overtime_multiplier', '1.5', '연장근무 가산율'),
('SET004', 'night_work_multiplier', '0.5', '야간근무 가산율'),
('SET005', 'holiday_multiplier', '1.5', '휴일근무 가산율'),
('SET006', 'late_threshold_minutes', '10', '지각 기준 시간(분)');

-- 샘플 사업장 데이터
INSERT INTO businesses (id, name, registration_number, owner_name, business_type, address, phone, email, contract_start_date, status, memo) VALUES
('BIZ001', '카페 모닝', '123-45-67890', '김사장', '음식점업', '서울시 강남구 테헤란로 123', '02-1234-5678', 'morning@cafe.com', '2024-01-01', 'active', '주휴수당 관리 서비스 이용 중'),
('BIZ002', '편의점 24', '234-56-78901', '이사장', '소매업', '서울시 서초구 서초대로 456', '02-2345-6789', 'convenience24@store.com', '2024-02-15', 'active', '신규 계약'),
('BIZ003', '헬스장 피트니스', '345-67-89012', '박사장', '체육시설업', '서울시 송파구 올림픽로 789', '02-3456-7890', 'fitness@gym.com', '2023-12-01', 'inactive', '계약 만료 예정');

-- 샘플 직원 데이터
INSERT INTO employees (id, business_id, name, id_number, position, employment_type, start_date, hourly_wage, monthly_hours, phone, address, memo) VALUES
('EMP001', 'BIZ001', '김영희', '901201-1234567', '매니저', 'regular', '2023-01-15', 12000, 160, '010-1234-5678', '서울시 강남구 테헤란로 123', '책임감 있는 직원'),
('EMP002', 'BIZ001', '박민수', '950315-2345678', '바리스타', 'part-time', '2023-06-01', 10000, 80, '010-2345-6789', '서울시 서초구 서초대로 456', '커피 전문가'),
('EMP003', 'BIZ001', '이지은', '980720-3456789', '서빙', 'short-time', '2024-01-01', 9620, 40, '010-3456-7890', '서울시 송파구 올림픽로 789', '신입 직원'),
('EMP004', 'BIZ001', '최현우', '920508-4567890', '주방보조', 'part-time', '2023-09-15', 11000, 100, '010-4567-8901', '서울시 마포구 홍대입구역 1번출구', '요리 경험 있음'),
('EMP005', 'BIZ001', '정수진', '960912-5678901', '카운터', 'short-time', '2024-02-01', 9620, 30, '010-5678-9012', '서울시 강동구 천호동 123', '주말 근무 전문'),
('EMP006', 'BIZ002', '강동호', '880425-6789012', '점장', 'regular', '2022-03-01', 15000, 160, '010-6789-0123', '서울시 서초구 서초대로 456', '편의점 운영 경험 풍부'),
('EMP007', 'BIZ002', '한소영', '940618-7890123', '직원', 'part-time', '2023-08-01', 10000, 60, '010-7890-1234', '서울시 서초구 서초대로 456', '야간 근무 담당'),
('EMP008', 'BIZ002', '윤태현', '970203-8901234', '직원', 'short-time', '2024-01-15', 9620, 25, '010-8901-2345', '서울시 서초구 서초대로 456', '아르바이트 학생');

-- 샘플 근무 기록 데이터
INSERT INTO work_logs (id, employee_id, work_date, clock_in, clock_out, break_minutes, work_hours, status, approval_status, note) VALUES
('LOG001', 'EMP001', '2025-01-15', '09:00', '18:00', 60, 8.0, 'normal', 'approved', '정상 근무'),
('LOG002', 'EMP001', '2025-01-14', '09:05', '18:00', 60, 7.92, 'late', 'approved', '5분 지각'),
('LOG003', 'EMP001', '2025-01-13', '09:00', '19:00', 60, 9.0, 'normal', 'approved', '연장근무 1시간'),
('LOG004', 'EMP002', '2025-01-15', '10:00', '18:00', 60, 7.0, 'normal', 'pending', ''),
('LOG005', 'EMP002', '2025-01-14', '10:00', '18:00', 60, 7.0, 'normal', 'approved', ''),
('LOG006', 'EMP003', '2025-01-15', '09:00', '13:00', 30, 3.5, 'normal', 'approved', '오전 근무'),
('LOG007', 'EMP003', '2025-01-14', '09:00', '13:00', 30, 3.5, 'normal', 'approved', ''),
('LOG008', 'EMP006', '2025-01-15', '08:00', '20:00', 60, 11.0, 'normal', 'approved', '연장근무 3시간'),
('LOG009', 'EMP006', '2025-01-14', '08:00', '20:00', 60, 11.0, 'normal', 'approved', '연장근무 3시간');

-- 샘플 주휴수당 데이터
INSERT INTO weekly_allowances (id, employee_id, week_start_date, week_end_date, total_hours, hourly_wage, allowance_amount, status) VALUES
('WA001', 'EMP001', '2025-01-13', '2025-01-19', 24.92, 12000, 5976, 'approved'),
('WA002', 'EMP002', '2025-01-13', '2025-01-19', 14.0, 10000, 0, 'pending'),
('WA003', 'EMP003', '2025-01-13', '2025-01-19', 7.0, 9620, 0, 'pending'),
('WA004', 'EMP006', '2025-01-13', '2025-01-19', 22.0, 15000, 6600, 'approved');

-- 샘플 급여 데이터
INSERT INTO salaries (id, employee_id, year, month, total_hours, basic_salary, overtime_hours, overtime_pay, weekly_allowance, total_salary, status) VALUES
('SAL001', 'EMP001', 2025, 1, 24.92, 299040, 0, 0, 5976, 305016, 'pending'),
('SAL002', 'EMP002', 2025, 1, 14.0, 140000, 0, 0, 0, 140000, 'pending'),
('SAL003', 'EMP003', 2025, 1, 7.0, 67340, 0, 0, 0, 67340, 'pending'),
('SAL004', 'EMP006', 2025, 1, 22.0, 330000, 0, 0, 6600, 336600, 'pending');

-- 샘플 관리자 데이터
INSERT INTO admins (id, username, password_hash, name, role, status) VALUES
('ADM001', 'admin', '$2a$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', '시스템 관리자', 'super_admin', 'active'),
('ADM002', 'staff1', '$2a$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', '김직원', 'staff', 'active'),
('ADM003', 'staff2', '$2a$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', '이직원', 'staff', 'active');

-- 사업장 관리자 연결 데이터
INSERT INTO business_admins (id, business_id, admin_id) VALUES
('BA001', 'BIZ001', 'ADM002'),
('BA002', 'BIZ002', 'ADM002'),
('BA003', 'BIZ003', 'ADM003');

-- ==============================================
-- 5. 뷰 생성 (자주 사용되는 조회)
-- ==============================================

-- 직원별 근무 현황 뷰
CREATE VIEW employee_work_summary AS
SELECT 
    e.id as employee_id,
    e.name as employee_name,
    e.business_id,
    b.name as business_name,
    e.employment_type,
    e.hourly_wage,
    COUNT(wl.id) as total_work_days,
    COALESCE(SUM(wl.work_hours), 0) as total_work_hours,
    COALESCE(SUM(CASE WHEN wl.status = 'late' THEN 1 ELSE 0 END), 0) as late_days,
    COALESCE(SUM(CASE WHEN wl.status = 'absent' THEN 1 ELSE 0 END), 0) as absent_days,
    COALESCE(SUM(CASE WHEN wl.approval_status = 'pending' THEN 1 ELSE 0 END), 0) as pending_approvals
FROM employees e
LEFT JOIN businesses b ON e.business_id = b.id
LEFT JOIN work_logs wl ON e.id = wl.employee_id
WHERE e.status = 'active'
GROUP BY e.id, e.name, e.business_id, b.name, e.employment_type, e.hourly_wage;

-- 사업장별 통계 뷰
CREATE VIEW business_statistics AS
SELECT 
    b.id as business_id,
    b.name as business_name,
    b.status as business_status,
    COUNT(DISTINCT e.id) as total_employees,
    COUNT(DISTINCT CASE WHEN e.employment_type = 'regular' THEN e.id END) as regular_employees,
    COUNT(DISTINCT CASE WHEN e.employment_type = 'part-time' THEN e.id END) as part_time_employees,
    COUNT(DISTINCT CASE WHEN e.employment_type = 'short-time' THEN e.id END) as short_time_employees,
    COALESCE(SUM(wl.work_hours), 0) as total_work_hours_current_month,
    COUNT(DISTINCT CASE WHEN wl.approval_status = 'pending' THEN wl.id END) as pending_approvals
FROM businesses b
LEFT JOIN employees e ON b.id = e.business_id AND e.status = 'active'
LEFT JOIN work_logs wl ON e.id = wl.employee_id 
    AND wl.work_date >= DATE_TRUNC('month', CURRENT_DATE)
    AND wl.work_date < DATE_TRUNC('month', CURRENT_DATE) + INTERVAL '1 month'
GROUP BY b.id, b.name, b.status;

-- ==============================================
-- 6. 함수 생성 (비즈니스 로직)
-- ==============================================

-- 주휴수당 계산 함수
CREATE OR REPLACE FUNCTION calculate_weekly_allowance(
    p_total_hours DECIMAL,
    p_hourly_wage INTEGER
) RETURNS INTEGER AS $$
DECLARE
    min_weekly_hours INTEGER;
    standard_weekly_hours INTEGER;
    allowance_amount INTEGER;
BEGIN
    -- 시스템 설정에서 값 가져오기
    SELECT setting_value::INTEGER INTO min_weekly_hours 
    FROM system_settings WHERE setting_key = 'min_weekly_hours';
    
    SELECT setting_value::INTEGER INTO standard_weekly_hours 
    FROM system_settings WHERE setting_key = 'standard_weekly_hours';
    
    -- 주휴수당 계산: (주간근무시간 ÷ 40시간) × 8시간 × 시급
    IF p_total_hours >= min_weekly_hours THEN
        allowance_amount := (p_total_hours / standard_weekly_hours) * 8 * p_hourly_wage;
    ELSE
        allowance_amount := 0;
    END IF;
    
    RETURN allowance_amount;
END;
$$ LANGUAGE plpgsql;

-- 근무시간 계산 함수
CREATE OR REPLACE FUNCTION calculate_work_hours(
    p_clock_in TIME,
    p_clock_out TIME,
    p_break_minutes INTEGER DEFAULT 0
) RETURNS DECIMAL AS $$
DECLARE
    total_minutes INTEGER;
    work_hours DECIMAL;
BEGIN
    -- 시간을 분으로 변환하여 계산
    total_minutes := EXTRACT(EPOCH FROM (p_clock_out - p_clock_in)) / 60;
    total_minutes := total_minutes - p_break_minutes;
    
    -- 시간으로 변환 (소수점 둘째자리까지)
    work_hours := ROUND(total_minutes / 60.0, 2);
    
    -- 음수 방지
    IF work_hours < 0 THEN
        work_hours := 0;
    END IF;
    
    RETURN work_hours;
END;
$$ LANGUAGE plpgsql;

-- 근무 상태 판정 함수
CREATE OR REPLACE FUNCTION determine_work_status(
    p_work_hours DECIMAL,
    p_clock_in TIME,
    p_expected_start TIME DEFAULT '09:00'
) RETURNS VARCHAR AS $$
BEGIN
    IF p_work_hours = 0 THEN
        RETURN 'absent';
    ELSIF p_clock_in > p_expected_start THEN
        RETURN 'late';
    ELSE
        RETURN 'normal';
    END IF;
END;
$$ LANGUAGE plpgsql;

-- ==============================================
-- 7. 완료 메시지
-- ==============================================

-- 스키마 생성 완료 확인
DO $$
BEGIN
    RAISE NOTICE '✅ 데이터베이스 스키마가 성공적으로 생성되었습니다!';
    RAISE NOTICE '📊 생성된 테이블: businesses, employees, work_logs, weekly_allowances, salaries, admins, business_admins, system_settings';
    RAISE NOTICE '📈 생성된 뷰: employee_work_summary, business_statistics';
    RAISE NOTICE '⚙️ 생성된 함수: calculate_weekly_allowance, calculate_work_hours, determine_work_status';
    RAISE NOTICE '📝 샘플 데이터가 삽입되었습니다.';
    RAISE NOTICE '🔗 프로젝트 ID: omplskojbargxeiodqdr';
    RAISE NOTICE '🌐 URL: https://omplskojbargxeiodqdr.supabase.co';
END $$;
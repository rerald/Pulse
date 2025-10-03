// Supabase 설정
const SUPABASE_CONFIG = {
    url: 'https://omplskojbargxeiodqdr.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im9tcGxza29qYmFyZ3hlaW9kcWRyIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTk0NzY5NjIsImV4cCI6MjA3NTA1Mjk2Mn0.oIB3jJUQEHI2HOSisNpHQRn5CWF9oKiRMCmcfnO5bNY'
};

// ✅ Supabase 프로젝트 연결 완료!
// Project ID: omplskojbargxeiodqdr
// URL: https://omplskojbargxeiodqdr.supabase.co

// Supabase 클라이언트 초기화
const { createClient } = supabase;
const supabaseClient = createClient(SUPABASE_CONFIG.url, SUPABASE_CONFIG.anonKey);

// 전역 변수로 사용할 수 있도록 설정
window.supabase = supabaseClient;

// 연결 테스트 함수
async function testSupabaseConnection() {
    try {
        const { data, error } = await supabaseClient
            .from('businesses')
            .select('count')
            .limit(1);
        
        if (error) {
            console.error('Supabase 연결 실패:', error);
            return false;
        }
        
        console.log('Supabase 연결 성공!');
        return true;
    } catch (err) {
        console.error('Supabase 연결 오류:', err);
        return false;
    }
}

// 페이지 로드 시 연결 테스트
document.addEventListener('DOMContentLoaded', async function() {
    const isConnected = await testSupabaseConnection();
    if (isConnected) {
        console.log('✅ Supabase 데이터베이스 연결 완료');
    } else {
        console.log('❌ Supabase 데이터베이스 연결 실패');
    }
});
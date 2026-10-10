// ตั้งค่าการเชื่อมต่อ Supabase (ดูวิธีหาค่าใน README.md)
// ค่า anon key เปิดเผยได้ ข้อมูลถูกป้องกันด้วยสิทธิ์ใน supabase/schema.sql
// ถ้าเว้นว่างไว้ เว็บจะเก็บข้อมูลในเบราว์เซอร์ของเครื่องนั้นแทน
window.DORM_CONFIG = {
  supabaseUrl: 'https://ggdguyudsvzwnrffehqy.supabase.co',
  supabaseAnonKey: '',  // วางคีย์ sb_publishable_... (หรือ anon key ที่ขึ้นต้นด้วย eyJ...) จาก Project Settings > API Keys
  googleLogin: false    // เปลี่ยนเป็น true หลังเปิดใช้ Google ใน Supabase แล้ว
};

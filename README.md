# BUKO — بوكو

تطبيق Flutter لسوق السيارات المستعملة في السودان، بواجهة عربية RTL.

## التشغيل

```bash
flutter pub get
flutter run
```

## إنشاء APK

```bash
flutter build apk --release
```

## المميزات الحالية

- تسجيل ودخول حقيقي برقم الهاتف السوداني عبر Firebase Authentication وSMS.
- حفظ ملف المستخدم في Firestore.
- تحميل إعلانات السيارات من Firestore بشكل مباشر.
- البحث بالاسم أو المدينة أو نوع السيارة.
- إرسال إعلان جديد إلى حالة `pending` للمراجعة قبل النشر.
- إرسال طلب شراء محفوظ في Firestore.
- Firebase Storage جاهز لرفع صور السيارات.
- قواعد Firestore بصلاحيات تعتمد على تسجيل الدخول وAdmin custom claim.
- GitHub Actions لبناء APK تلقائياً.

## ملاحظة الإدارة

صلاحيات الإدارة الحقيقية تعتمد على Firebase Admin custom claim باسم `admin=true`. لا توجد كلمة مرور Admin ثابتة داخل التطبيق.

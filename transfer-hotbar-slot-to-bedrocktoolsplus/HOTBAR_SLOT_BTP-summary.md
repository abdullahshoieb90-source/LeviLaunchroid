# نقل ميزة Hotbar Slot Module إلى BedrockToolsPlus-

## الملخص

تم نقل ميزة **Hotbar Slot** المدمجة في `LeviLaunchroid`
(module `hotbar_slot`) إلى مستودعك **`abdullahshoieb90-source/BedrockToolsPlus-`**
(المود الناتيف C++ للعبة Minecraft Bedrock).

> ملاحظة: توكن GitHub في هذه الجلسة يملك صلاحيات على مستودع `LeviLaunchroid`
> (fork) فقط، فتعذّر الدفع المباشر إلى `BedrockToolsPlus-`. لذلك جهّزت:
> 1. نسخة كاملة من الكود منفّذة ومثبّتة داخل `/home/user/bedrock-tools-plus`
>    (فرع `hotbar-slot-module` مبني على آخر commit).
> 2. ملف باتش جاهز للتطبيق: `/home/user/hotbar-slot-module.patch`
> 3. نسخة احتياطية داخل مستودع LeviLaunchroid (فرع الجلسة) في `transfer-hotbar-slot-to-bedrocktoolsplus/`.
> 4. (تم تنظيف كل أثر لمحاولة V Client السابقة — ملخصها موجود في تاريخ الفرع لو احتجته).

## طريقة التطبيق على مستودع BedrockToolsPlus-

```bash
cd BedrockToolsPlus-
git am ~/hotbar-slot-module.patch     # أو: git apply ثم commit
```

## الملفات المضافة/المعدّلة

**جديد:**
- `src/modules/hud/hotbarslot.hpp` — تعريف المودول وإعداداته.
- `src/modules/hud/hotbarslot.cpp` — التنفيذ (قراءة الخانات + الرسم + إعدادات المنيو).

**تعديل:**
- `src/modules/ModuleRegistry.cpp` — تسجيل المودول (`HotbarSlotModule`).
- `README.md` — تحديث العدد (54) وقائمة HUD + قسم شرح النقل.

## كيف تُرجمت الميزة داخل اللعبة

في LeviLauncher الميزة Overlay في اللانشر: 9 أزرار (1–9) فوق اللعبة لاختيار
خانة الهوت بار + وضع "أيقونات العناصر" الذي يجعل الزر إطارًا أجوفًا تكشف أيقونة
الهوت بار الحقيقية. داخل اللعبة (هنا) صارت **صف HUD** يعرض نفس الخانات:

- كل خانة تعرض رقمها (1–9) افتراضيًا — مثل أزرار اللانشر.
- وضع **Use Item Icons**: الخانة التي فيها عنصر تُرسم كنافذة شبه شفافة بدون رقم،
  فتبقى أيقونة الهوت بار الفعلية مرئية تحتها (محاكاة الزر الأجوف الأصلي).
- إخفاء كل خانة على حدة (مجموعة chips "Show Slots") + تحكم في الحجم والمسافة
  والخلفية والشفافية، وعنصر سحب من HUD Editor، وموضع افتراضي يتركّز تلقائيًا فوق
  الهوت بار الفعلية.

## ملاحظات النقل (مكتوبة أيضًا في README)

- وجود العنصر في كل خانة يُقرأ بنفس طريقة `core/InventoryAccess.cpp`
  (خانات الهوت بار = فهارس 0–8 من الـ container) — نفس الأوفستات الموثّقة.
- **تمييز الخانة المختارة حاليًا** لم يُضف عمدًا: يحتاج signature/offset لم يُحل
  بعد في الكود، والسياسة هنا عدم تخمين الأوفستات (مثل `MinecraftLoader`). عند
  إضافة signature يصبح التمييز إضافة بسيطة في `onFrame()`.
- المودول Display-only بالتصميم: داخل اللعبة "اختيار الخانة" يتم بالهوت بار
  الفعلية نفسها، فلا حاجة لنقل منطق الضغط/الاختيار من اللانشر.

## مرجع الملفات الأصلية في LeviLaunchroid

- `.../inbuilt/overlay/HotbarSlotOverlay.java`
- `.../inbuilt/overlay/InbuiltOverlayManager.java` (تخطيط صف `refreshHotbarSlots`)
- `.../inbuilt/manager/InbuiltModManager.java` (المفاتيح والإعدادات)
- `.../inbuilt/nativemod/HotbarSlotMod.java`

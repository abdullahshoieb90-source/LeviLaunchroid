# نقل ميزة Hotbar Slot Module إلى V Client (مستودع Client)

## ملخص

تم نقل ميزة **Hotbar Slot** المدمجة في `LeviLaunchroid`
(الـ module المعروف باسم `hotbar_slot`) إلى مستودعك **`abdullahshoieb90-source/Client`**
(مشروع V Client — اللانشر البديل الذي يُعيد بناء مودولات LeviLaunchroid بلغة Kotlin).

> ملاحظة: لم أستطع الدفع مباشرة إلى `Client` لأن توكن الجلسة يملك صلاحيات على
> مستودع `LeviLaunchroid` (fork) فقط. لذلك جهّزت:
> 1. نسخة كاملة من الكود منفّذة ومثبّتة داخل `/home/user/client-port`
>    (فرع `hotbar-slot-module-port` مبني على `main`).
> 2. ملف باتش جاهز للتطبيق: `/home/user/hotbar-slot-module-port.patch`
> 3. هذه النسخة الاحتياطية داخل مستودع LeviLaunchroid (فرع الجلسة) في `transfer-hotbar-slot-to-client/`.

## طريقة التطبيق على مستودع Client

```bash
cd Client          # مستودعك المحلي
git am ~/hotbar-slot-module-port.patch   # أو: git apply ثم commit
```

## الملفات المضافة/المعدّلة في Client

**جديد (Kotlin — واجهة الأزرار والإعدادات):**
- `app/src/main/java/com/bedrock/client/modules/hotbarslot/HotbarSlotPrefs.kt`
  إعدادات كل خانة (بنفس أسماء مفاتيح الأصلية `hotbar_slot_enabled_<n>` …) + مفتاح `hotbar_slot_item_icons`.
- `app/src/main/java/com/bedrock/client/modules/hotbarslot/HotbarSlotButton.kt`
  زر خانة واحد: رقم في المنتصف، حالة ضغط، وضع إطار أجوف لأيقونات العناصر، سحب بضغطة مطوّلة.
- `app/src/main/java/com/bedrock/client/modules/hotbarslot/HotbarSlotHost.kt`
  نافذة فوق شاشة اللعبة (WindowManager كما في `BaseOverlayButton`) توزّع الأزرار
  تلقائيًا كصف سفلي متوسط (120dp من الأسفل، مسافة 4dp)، وتحفظ المواضع بعد السحب.
- `app/src/main/java/com/bedrock/client/modules/hotbarslot/HotbarSlotController.kt`
  ربط دورة حياة المودول بـ GameActivity (WeakReference حتى لا يُسرّب الـ Activity).
- `app/src/main/java/com/bedrock/client/modules/impl/HotbarSlotModule.kt`
  الـ GameModule نفسه (Category.CLIENT) مع استدعاءات JNI محمية.

**جديد (C++ — الجزء داخل اللعبة):**
- `cpp/modules/impl/hotbar_slot.h` / `hotbar_slot.cpp`
  Module مسجّل باسم "Hotbar Slot" يستقبل الضغطات و`hasItem`، مع TODO صريحة
  (بدون تخمين أوفستات — نفس أسلوب `MinecraftLoader.cpp`).

**تعديل:**
- `ModuleManager.kt` — تسجيل المودول (يظهر تلقائيًا في قائمة Mods).
- `GameActivity.kt` — attach/detach للـ Controller.
- `cpp/modules/module_manager.cpp` — تسجيل الـ module الناتيف.
- `README.md` — قسم يشرح النقل ونقطتي الـ TODO.

## السلوك المنقول كما هو في LeviLaunchroid

- 9 أزرار (1..9) تظهر فوق اللعبة عند تفعيل المودول من قائمة Mods ثم فتح اللعبة.
- الضغط/الإمساك يرسل ضغطة اختيار الخانة للعبة (KeyEvent + المسار الناتيف).
- سحب (ضغطة مطوّلة) لنقل كل زر، ويُحفظ موضعه في SharedPreferences.
- إعدادات: إظهار/حجم(56dp افتراضي)/شفافية(100 افتراضي) لكل خانة، ووضع أيقونات العناصر.
- وضع أيقونات العناصر: عند تفعيله وتحقق وجود عنصر بالخانة يصير الزر إطارًا أجوفًا
  تكشف أيقونة الهوت بار الحقيقية من وسطه.

## نقطتان متبقيتان على الجانب الناتيف (TODO داخل الكود)

1. `selectSlot` في `hotbar_slot.cpp` — كتابة `selectedSlot` للاعب المحلي / حقن المفتاح
   عند اكتمال الربط داخل اللعبة.
2. `hasItem` — قراءة عنصر الخانة من مخزون اللاعب (يغذّي وضع الأيقونات).

حتى ذلك الحين يعمل المودول كأزرار overlay كاملة، وكل استدعاءات JNI محمية فلا
يتعطل التطبيق عند غياب `libbedrock_client.so`.

## مرجع الملفات الأصلية في LeviLaunchroid

- `app/src/main/java/org/levimc/launcher/core/mods/inbuilt/overlay/HotbarSlotOverlay.java`
- `app/src/main/java/org/levimc/launcher/core/mods/inbuilt/overlay/InbuiltOverlayManager.java` (تخطيط `refreshHotbarSlots`)
- `app/src/main/java/org/levimc/launcher/core/mods/inbuilt/manager/InbuiltModManager.java` (المفاتيح والإعدادات)
- `app/src/main/java/org/levimc/launcher/core/mods/inbuilt/nativemod/HotbarSlotMod.java`

> إذا كنت تقصد مستودع **BedrockToolsPlus-** (المود الناتيف C++) بدل Client،
> فالميزة هنا Overlay/UI في اللانشر ولا تُنقل كما هي لمود داخل اللعبة — أخبرني
> وسأبني نسخة C++ مكافئة (HUD يعرض خانات الهوت بار داخل اللعبة) هناك.

# interfaces / interiors

هذا المجلد مخصص لملفات الدواخل المخصصة (DFF/TXD/COL) إذا أردت لاحقاً استبدال
أغلفة ساندرياس بأصول GTA IV/V حقيقية.

الوضع الحالي: كل عقار يُبنى داخلياً من **غلاف داخلي جاهز (shell)** مذكور في
`config.lua` (shell = رقم الموديل)، مع كتالوج أثاث من `LH.furniture`.

## لإضافة داخل مخصص

1. ضع `dff/txd/col` في `models/`, `textures/`, `collisions/`.
2. أضف ملف `.map` في `maps/` يحتوي عناصر `object` (بإحداثيات ثابتة).
3. أضف `<file src="models/**"/>` … في `meta.xml` وأضف `include` للماب في نفس الوسم.
4. في `config.lua` غيّر `shell` إلى 0 وحدد `customMap = true` (إن أضفت الدعم).

لا تحذف هذا الملف — `meta.xml` يعلنه.

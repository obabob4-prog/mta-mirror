# models — GTA V Eclipse Tower apartment

أصول حقيقية ومُتحقَّق منها من mod تحويل GTA V Online إلى GTA:SA، مستخدمة
حصرياً داخل دواخل `luxury_houses`. لا يتم استبدال أي موديل أصلي في اللعبة.

## الملفات المستخدمة

| الملف | الحجم | الاستخدام |
|---|---:|---|
| `apt_mp_shell.dff` | 2,606,060 | هيكل الغرفة |
| `apt_mp_mod.txd` | 5,346,016 | قوام الهيكل |
| `apt_mp_shell.col` | 33,600 | تصادم الهيكل |
| `apt_mp_int.dff` | 1,711,658 | الداخل/الجدران |
| `apt_mp_int.txd` | 5,598,264 | قوام الداخل |
| `apt_mp_int.col` | 91,108 | تصادم الداخل |
| `apt_mp_props.dff` | 2,951,168 | الأثاث والمفروشات |
| `apt_mp_props.txd` | 4,757,064 | قوام الأثاث |
| `apt_mp_props.col` | 28,508 | تصادم الأثاث |

ملفات إضافية من الأرشيف الأصلي موجودة للتوثيق فقط ولا تُحمّل حالياً:
`apt_mp_mod.col`, `cj_hi_fi.txd`, `gen_doorint04.dff`, `int_doors.txd`.

## التحميل

`client.lua` يستخدم `engineRequestModel("object")` لكل جزء، ثم
`engineLoadTXD/DFF/COL` + `engineImportTXD/engineReplaceCOL/engineReplaceModel`.
يتم إنشاء الأجسام في `interior 0` والبُعد `21000 + id` فقط، مع أرضية أمان
غير مرئية أسفل المستوى `-1.80` لمنع السقوط عبر الفجوات.

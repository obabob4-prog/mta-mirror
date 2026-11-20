# scripts

| الملف | الدور |
|---|---|
| `s_water.lua` | إنشاء بحر Liberty City على السيرفر من `water.dat` (62 رباعية)، مع أمر `/lhwater` لإعادة البناء |

سبب وجوده: `eagleLoader/client/water_loader.lua` كان يستدعي `createWater`
من جهة العميل (دالة سيرفر فقط) → الماء لم يُنشأ أبداً في LC.

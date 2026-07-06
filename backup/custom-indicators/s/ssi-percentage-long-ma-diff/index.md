# SSI Percentage Long MA Diff

> Source: https://fxcodebase.com/code/viewtopic.php?f=17&t=68467  
> Forum: 17 · Topic 68467 · 1 post(s)


---

## SSI Percentage Long MA Diff

**Apprentice** · Thu May 16, 2019 5:28 am

![EURUSD m5 (05-16-2019 1032).png](images/126358/EURUSD%20m5%20%2805-16-2019%201032%29.png)



Based on request.
[viewtopic.php?f=27&t=68450](https://fxcodebase.com/code/viewtopic.php?f=27&t=68450)

IF
SSI Percentage LONG > MA (SSI Percentage Long, X)
THEN
OUTPUT = -1 (Color = Red)

IF
SSI Percentage LONG < MA (SSI Percentage Long, X)
THEN
OUTPUT = 1 (Color = Green)

Else
OUTPUT = 0

SSI is FXCM app speculative sentiment index.
[https://www.fxcmapps.com/apps/speculati ... ent-index/](https://www.fxcmapps.com/apps/speculative-sentiment-index/)

Will only work for instruments for which SSI is available.

 [SSI Percentage Long MA Diff.lua](files/126358/SSI%20Percentage%20Long%20MA%20Diff.lua)

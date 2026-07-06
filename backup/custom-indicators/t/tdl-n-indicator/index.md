# TDL_N indicator

> Source: https://fxcodebase.com/code/viewtopic.php?f=17&t=69368  
> Forum: 17 · Topic 69368 · 3 post(s)


---

## TDL_N indicator

**richardtao** · Mon Feb 03, 2020 12:31 am

![GBPUSD H1 (02-03-2020 1016).png](images/131036/GBPUSD%20H1%20%2802-03-2020%201016%29.png)



The first parameter N defines look back of moving average.
The second parameter C defines the step of nature moving average.
The output stream A is active nature moving average.
The output stream B is base simple moving average.
The recommended parameters might be (100, 0.5)

 [TDL_N.lua](files/131036/TDL_N.lua)


---

## Re: TDL_N indicator

**Apprentice** · Mon Feb 03, 2020 6:03 am

[27348](files/131039/Capture.PNG)


---

## Re: TDL_N indicator

**richardtao** · Wed Feb 05, 2020 1:09 am

set default 50 when first parameter is 0.

 [TDL_N.lua](files/131088/TDL_N.lua)

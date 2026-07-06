# TDL_R indicator

> Source: https://fxcodebase.com/code/viewtopic.php?f=17&t=69369  
> Forum: 17 · Topic 69369 · 1 post(s)


---

## TDL_R indicator

**richardtao** · Mon Feb 03, 2020 12:32 am

![GBPUSD H1 (02-03-2020 1008).png](images/131037/GBPUSD%20H1%20%2802-03-2020%201008%29.png)



The first parameter N defines look back of liner regression.
The second parameter C defines the shift position of liner regression look back begin.
The output stream A is active smooth liner regression.
The output stream B is base liner regression look back begin.
The recommended parameters might be (100, 10)

 [TDL_R.lua](files/131037/TDL_R.lua)

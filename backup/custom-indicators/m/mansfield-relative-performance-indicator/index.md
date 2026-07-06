# Mansfield Relative Performance indicator

> Source: https://fxcodebase.com/code/viewtopic.php?f=17&t=65746  
> Forum: 17 · Topic 65746 · 1 post(s)


---

## Mansfield Relative Performance indicator

**Apprentice** · Sun Feb 18, 2018 6:29 am

![USDSEK D1 (02-18-2018 1040).png](images/117796/USDSEK%20D1%20%2802-18-2018%201040%29.png)



Based on the request.
[viewtopic.php?f=27&t=65744](https://fxcodebase.com/code/viewtopic.php?f=27&t=65744)
RP = ( stock_close / index_close ) * 100

 [Standard Relative Performance indicator.lua](files/117796/Standard%20Relative%20Performance%20indicator.lua)

MRP = (( RP(today) / sma(RP(today), n)) - 1 ) * 100

 [Mansfield Relative Performance indicator.lua](files/117796/Mansfield%20Relative%20Performance%20indicator.lua)

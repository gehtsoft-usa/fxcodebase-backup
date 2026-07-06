# MTF MCP MA Price Overview

> Source: https://fxcodebase.com/code/viewtopic.php?f=17&t=66675  
> Forum: 17 · Topic 66675 · 7 post(s)


---

## MTF MCP MA Price Overview

**Apprentice** · Fri Sep 28, 2018 6:03 am

![EURJPY M1 (09-28-2018 1115).png](images/121281/EURJPY%20M1%20%2809-28-2018%201115%29.png)



It is intended for multiple currency trend change detection.
1. Filter
Price /1. MA relation
2. Filter
Price /2. MA relation
3. Filter
Price /3. MA relation
4. Filter
1.MA /2. MA relation
5. Filter
1.MA /3. MA relation
6. Filter
2.MA /3. MA relation

 [MTF MCP MA Price Overview.lua](files/121281/MTF%20MCP%20MA%20Price%20Overview.lua)


---

## Re: MTF MCP MA Price Overview

**steveped** · Sat Nov 17, 2018 3:19 pm

Hi guys, any chance to have values as % other than pips and numeric?


---

## Re: MTF MCP MA Price Overview

**Apprentice** · Mon Nov 19, 2018 8:33 am

I do not understand, regardless of % , pips or numeric MTF MCP MA Price Overview
indication will always be the same.


---

## Re: MTF MCP MA Price Overview

**steveped** · Mon Nov 19, 2018 9:27 am

Sorry for not being clear. I would like to see the distance in % of the average from the current price.
So, if GER300 current price is 11300 and its M15 avg is 11000, I could display it as 300 or 2,65%.


---

## Re: MTF MCP MA Price Overview

**Apprentice** · Wed Nov 21, 2018 9:19 am

Something like Movers and Shakers?
[viewtopic.php?f=17&t=3234](https://fxcodebase.com/code/viewtopic.php?f=17&t=3234)


---

## Re: MTF MCP MA Price Overview

**steveped** · Thu Nov 22, 2018 11:11 am

Actually not... Movers & Shakers calculates pip/percentange from current close to a previous bar close located n bars back. I would need something like (closePrice-MVA)/closePrice.


---

## Re: MTF MCP MA Price Overview

**Apprentice** · Sat Nov 24, 2018 7:42 am

Try this version.
[viewtopic.php?f=17&t=66954&p=122281#p122281](https://fxcodebase.com/code/viewtopic.php?f=17&t=66954&p=122281#p122281)

# DNC V3 Strategy

> Source: https://fxcodebase.com/code/viewtopic.php?f=31&t=70633  
> Forum: 31 · Topic 70633 · 7 post(s)


---

## DNC V3 Strategy

**Apprentice** · Mon Nov 16, 2020 4:36 am

![EURUSD m1 (11-16-2020 1035).png](images/138907/EURUSD%20m1%20%2811-16-2020%201035%29.png)



Based on request.
[viewtopic.php?f=27&t=70612](https://fxcodebase.com/code/viewtopic.php?f=27&t=70612)

 [DNC V3 Strategy.lua](files/138907/DNC%20V3%20Strategy.lua)


---

## Re: DNC V3 Strategy

**chai88888** · Mon Nov 16, 2020 9:04 am

there a problem

1. taking multiple trades even the position limit set to 1
2. stop wont move
3. its not adding trades on the lines

thanks


---

## Re: DNC V3 Strategy

**Apprentice** · Tue Nov 17, 2020 6:58 am

Your request is added to the development list.
Development reference 2323.


---

## Re: DNC V3 Strategy

**Apprentice** · Wed Nov 18, 2020 9:21 am

Updated.
I don't understand #3


---

## Re: DNC V3 Strategy

**chai88888** · Wed Nov 18, 2020 8:22 pm

lets say the price is moving up

if the price break and closes above the center line it will add another buy trade and move the stop loss to the bottom subline

and if the price goes higher and break and closes above top sub line it will another buy and move the stop loss to the center line

and if the price break the top line add another buy move the stop loss to the top sub line

basically its like traling stop moving the stop within the DNV3 lines


---

## Re: DNC V3 Strategy

**Apprentice** · Tue Nov 24, 2020 6:04 am

Your request is added to the development list.
Development reference 2360.


---

## Re: DNC V3 Strategy

**Apprentice** · Sun Nov 29, 2020 3:56 am

[DNC V3 Strategy.lua](files/139180/DNC%20V3%20Strategy.lua)

Try this version.

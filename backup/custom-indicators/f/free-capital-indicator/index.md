# Free Capital Indicator

> Source: https://fxcodebase.com/code/viewtopic.php?f=17&t=65172  
> Forum: 17 · Topic 65172 · 13 post(s)


---

## Free Capital Indicator

**Apprentice** · Wed Oct 11, 2017 4:47 am

![EURAUD m1 (10-11-2017 0956).png](images/115380/EURAUD%20m1%20%2810-11-2017%200956%29.png)



Based on the request.
[viewtopic.php?f=27&t=65170](https://fxcodebase.com/code/viewtopic.php?f=27&t=65170)

Free Capital= Balance - UsedMargin + GrossPL - position Stop Out Reservations

Note.
If any of your position has no Stop set you are exposed to unlimited risk.
therefore the Free Capital Indicator is set to zero.

If you have FIFO account set Stop Level to NO.

 [Free Capital Indicator.lua](files/115380/Free%20Capital%20Indicator.lua)

 [Take Profit Indicator.lua](files/115380/Take%20Profit%20Indicator.lua)


---

## Re: Free Capital Indicator

**Reymondpolanco** · Wed Oct 11, 2017 2:55 pm

The amount change constantly and not suppose to be, because the margin used in open trades is fix and the stop loss in the open position is fix too


---

## Re: Free Capital Indicator

**Apprentice** · Wed Oct 11, 2017 4:27 pm

GrossPL is not.
U can turn it off.


---

## Re: Free Capital Indicator

**Apprentice** · Sun Feb 04, 2018 7:56 am

The Indicator was revised and updated.


---

## Re: Free Capital Indicator

**Reymondpolanco** · Tue Mar 20, 2018 1:20 pm

Can you check the indicator because the stop is in the positive side so the amount of free capital cant be -5.22


---

## Re: Free Capital Indicator

**Apprentice** · Tue Mar 20, 2018 1:50 pm

Your request is added to the development list under Id Number 4084


---

## Re: Free Capital Indicator

**Apprentice** · Mon Mar 26, 2018 5:31 am

The Indicator was revised and updated.


---

## Re: Free Capital Indicator

**Reymondpolanco** · Wed Apr 25, 2018 1:16 pm

Can you make the same thing but for the take profit.

Indicator = sum of all open trades take profits show in pips and money


---

## Re: Free Capital Indicator

**Apprentice** · Wed Apr 25, 2018 2:43 pm

Take Profit Indicator.lua added.


---

## Re: Free Capital Indicator

**Reymondpolanco** · Wed Apr 25, 2018 3:46 pm

> **Apprentice wrote:**
> Take Profit Indicator.lua added.

The amount currency change constantly it be a fixed amount because the take profit are fixed.

indicator = sum of all open trades take profit

all open trades take profit are a fixed amount so the result need to be a fixed amount


---

## Re: Free Capital Indicator

**Reymondpolanco** · Mon May 21, 2018 6:02 pm

> **Reymondpolanco wrote:**
>
>
> > **Apprentice wrote:**
> > Take Profit Indicator.lua added.
>
>
>
>
> The amount currency change constantly it be a fixed amount because the take profit are fixed.
>
> indicator = sum of all open trades take profit
>
> all open trades take profit are a fixed amount so the result need to be a fixed amount

Any new about this fix ?


---

## Re: Free Capital Indicator

**Reymondpolanco** · Tue Apr 16, 2019 10:27 pm

Check the Take Profit Indicator is showing wrong data


---

## Re: Free Capital Indicator

**Apprentice** · Thu Apr 18, 2019 5:18 am

Your request is added to the development list under Id Number 4600

# 3 in 1 Stochastic Strategy

> Source: https://fxcodebase.com/code/viewtopic.php?f=31&t=63323  
> Forum: 31 · Topic 63323 · 14 post(s)


---

## 3 in 1 Stochastic Strategy

**Apprentice** · Wed Mar 30, 2016 6:50 am

![EURUSD H1 (03-30-2016 1316).png](images/105568/EURUSD%20H1%20%2803-30-2016%201316%29.png)



Based on 3 and 1 Stochastic indicator.
[viewtopic.php?f=17&t=63215](https://fxcodebase.com/code/viewtopic.php?f=17&t=63215)

For Long
1. Time Frame
and K>D
2. Time
and K> D
3. Time
and K> D
and 1. K/D Line CrossOver

Vice versa for Short

 [3 in 1 Stochastic Strategy.lua](files/105568/3%20in%201%20Stochastic%20Strategy.lua)

The Strategy was revised and updated on January 19, 2019.


---

## Re: 3 in 1 Stochastic Strategy

**willcsk** · Sat Apr 02, 2016 9:09 pm

hi Apprentice,

thank you for this good streatagy.

wondering if you have time to modify the exit citeria.

to exit each side ; if average trade for each buy/sell side is > user specified profit target ?

ie:

buy trade -
1st open trade( -$10.0)
2nd open trade( + $1.0)
3rd open trade( + $20.0)

average trade ( +$11.0 )

user specified profit = 10.0

action - close all buy trade.

same goes to sell trade.

thx again

-willie-


---

## Re: 3 in 1 Stochastic Strategy

**Apprentice** · Wed Apr 06, 2016 11:37 am

Your request is added to the development list.


---

## Re: 3 in 1 Stochastic Strategy

**Kilgharrah** · Tue Oct 04, 2016 3:37 am

> **Apprentice wrote:**
> Strategy is available here.
> [viewtopic.php?f=31&t=63323&p=105568#p105568](https://fxcodebase.com/code/viewtopic.php?f=31&t=63323&p=105568#p105568)

Thank you very much for very quick response, but as I understand that strategy is for **3 Time Frame Stochastic.lua** and not for **3in1 Stochastic.lua** , am I right ?. Thanks again.


---

## Re: 3 in 1 Stochastic Strategy

**mulligan** · Sun Oct 16, 2016 8:26 pm

It would be great if you have the time to add the same "change only" parameter added to the indicator alert to the strategy as an option.
Thanks


---

## Re: 3 in 1 Stochastic Strategy

**Apprentice** · Tue Oct 18, 2016 9:24 am

"change only" parameter added.


---

## Re: 3 in 1 Stochastic Strategy

**mulligan** · Tue Oct 18, 2016 10:06 am

Thank you very much for your help adding change only. A small problem loading. I'm getting the error - unexpected symbol near 'or'.


---

## Re: 3 in 1 Stochastic Strategy

**Apprentice** · Tue Oct 18, 2016 4:30 pm

Fixed.


---

## Re: 3 in 1 Stochastic Strategy

**mulligan** · Tue Oct 18, 2016 7:12 pm

Loaded the strategy and tested on several pairs with change only set to yes. The strategy didn't recognize the new parameter and signaled on all arrows. Hope you can find a bug somewhere.


---

## Re: 3 in 1 Stochastic Strategy

**Apprentice** · Wed Oct 19, 2016 4:16 am

As it is will give alert on 1. TF change
Can you describe your idea.


---

## Re: 3 in 1 Stochastic Strategy

**Apprentice** · Wed Oct 19, 2016 4:23 am

[3 in 1 Stochastic Strategy.lua](files/108681/3%20in%201%20Stochastic%20Strategy.lua)

For Long
1. Time Frame
K>D
2. Time
and K> D
3. Time
and K> D
and
(
 1. K/D Line CrossOver
or 2. K/D Line CrossOver
or 3. K/D Line CrossOver
)
Vice versa for Short


---

## Re: 3 in 1 Stochastic Strategy

**mulligan** · Wed Oct 19, 2016 12:14 pm

An example would be when all 3 time frames agree on a buy position, there is a signal or action to buy. All following signals to buy are ignored. A new signal or action is generated only on the opposite indication of all 3 time frames agreeing on sell. This 'change only' parameter appears to be working on the 3 in 1 Stochastic indicator which has an alert function. When I tested the strategy it didn't seem to recognize the 'change only' (set to yes) and was giving multiple buy or sell signals in a row. Hope this clarifies.

Thanks


---

## Re: 3 in 1 Stochastic Strategy

**Apprentice** · Sun Dec 18, 2016 7:32 am

Strategy was revised and updated.


---

## Re: 3 in 1 Stochastic Strategy

**mulligan** · Wed Mar 29, 2017 10:49 am

If you have time to look at the change only part of this strategy, it is showing "buy" multiple times in a row and "sell" the same way (with "change only" set to yes). If it would show buy or sell only when it changes from one to the other it would make this strategy exceptional. Thanks for your consideration.

# MAE Signal

> Source: https://fxcodebase.com/code/viewtopic.php?f=29&t=2222  
> Forum: 29 · Topic 2222 · 7 post(s)


---

## MAE Signal

**Apprentice** · Mon Sep 20, 2010 4:13 am

![Test New.png](images/4636/Test%20New.png)



This signal gives you a choice between two types of signals.
Crossover of closing price above or below the MAE line
and touching of the MAE line by the closing price.

Signal uses the standard MAE indicator.

 [MAE Signal.lua](files/4636/MAE%20Signal.lua)


---

## Re: MAE Signal

**dervakon** · Mon Sep 20, 2010 9:07 am

Hi Apprentice,

Thank you so much, I really appreciated what you have done

Dervakon


---

## Re: MAE Signal

**Blackcat2** · Mon Sep 20, 2010 7:16 pm

Is MAE indicator built-in or customised? If customised, could you please provide the link? I tried to search but didn't come up with anything..

Cheers..
BC


---

## Re: MAE Signal

**Apprentice** · Tue Sep 21, 2010 2:24 am

I use the buildin MAE.
There is no need for additional indicators.
Ie this signal only works with standard indicator.


---

## Re: MAE Signal

**artemich555** · Wed Sep 22, 2010 3:43 am

Dear Apprentice. I keep looking for a particular signal, and this one is almost what i need. Can we add the following modifications to it, please:

in the option ---@touching of the MAE line by the CLOSING PRICE@ can we add or replace 'the closing price' for a 'PRICE TOUCHING the MAE at any given tick' >signal is activeted, without waiting for a closing candle.
It usually helps to confirm that the MA cross is legitimate.
Many thank's in advance.
with respect, artsiom


---

## Re: MAE Signal

**Apprentice** · Wed Sep 22, 2010 5:43 am

For this purpose you have CrossOver Type - High / Low.
I think I know what bothers you, the postponement signal.
It did not caused by this particular signal is the platform.

The signal is always given with a delay of one period, Upon completion of the current period
.

 Maybe in future we find a better solution.


---

## Re: MAE Signal

**Apprentice** · Thu Jun 23, 2011 5:48 am

MAE2 Signal

 [MAE2 Signal.lua](files/11981/MAE2%20Signal.lua)

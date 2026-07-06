# Price-to-MA shrinking-Gap Exit automation Strategy

> Source: https://fxcodebase.com/code/viewtopic.php?f=31&t=63006  
> Forum: 31 · Topic 63006 · 3 post(s)


---

## Price-to-MA shrinking-Gap Exit automation Strategy

**Apprentice** · Mon Jan 04, 2016 10:06 am

![EURUSD m15 (01-04-2016 1531).png](images/104115/EURUSD%20m15%20%2801-04-2016%201531%29.png)



Based on request.
[viewtopic.php?f=27&t=62995](https://fxcodebase.com/code/viewtopic.php?f=27&t=62995)

Trade order:
Enter Buy at market when: MA(-1) – Close(-1) >= № of Pip, and MA – Close < № of Pip;
Enter Sell at market when: Close(-1) – MA(-1) >= № of Pip, and Close – MA < № of Pip;
Once enter (either Buy or Sell as defined by the user), stop the EA.

 [Price-to-MA shrinking-Gap Exit automation Strategy.lua](files/104115/Price-to-MA%20shrinking-Gap%20Exit%20automation%20Strategy.lua)

The Strategy was revised and updated on December 18, 2018.


---

## Re: Price-to-MA shrinking-Gap Exit automation Strategy

**sztracyh** · Fri Jan 08, 2016 6:15 am

Hi Apprentice, thanks for the program.

I have put it on but I don't seem be able to get it works. Could you explain how to set below Trading Parameters as I am not sure if it's because my settings are not correct:

Say, I want to close a short position use the EA, and below is the setting:
Allow strategy to trade: Yes
End of Turn/Live: End of Turn
Close on Opposite: Yes
Allowed side: Buy
Type of Signal/Trade: Direct

Many thanks,
Tracy Huang


---

## Re: Price-to-MA shrinking-Gap Exit automation Strategy

**Apprentice** · Wed Dec 14, 2016 5:06 am

Strategy was revised and updated.

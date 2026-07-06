# ICH Index

> Source: https://fxcodebase.com/code/viewtopic.php?f=17&t=23054  
> Forum: 17 · Topic 23054 · 8 post(s)


---

## ICH Index

**Apprentice** · Wed Sep 05, 2012 3:46 pm

![ICH Index.png](images/39728/ICH%20Index.png)



For selected period, this indicator will gives the number of bars closing,
under or over selected components of the ICH.

 [ICH Index.lua](files/39728/ICH%20Index.lua)


---

## Re: ICH Index

**nazaar** · Wed Sep 05, 2012 4:37 pm

Hi Apprentice, this is excellent. I like how you made the input periods optional to the user.

May I suggest some edits so that the tool could display more information at the same time while not cluttering your graph.

For now, I don't have to have the results presented in a graph. As a line of text is fine, similar to the "Show Legend" text line. Another option is to display the results in a display box like the "cursor Data" box. This would allow you to display multiple calculation results at the same time. **That is, at the same time you can see:

- how many bars closed above the tenkan line
- how many bars closed below the tenkan line

- how many bars closed above the kijun line
- how many bars closed below the kijun line

- how many bars closed above span A
- how many bars closed below span B.**

Thanks.


---

## Re: ICH Index -- Graph Version

**nazaar** · Wed Sep 05, 2012 5:19 pm

Hi Apprentice,

Regarding the graphic version, perhaps we could place horizontal lines as boundaries. If you are measuring the number of closes above the tenkan line then the **maximum**# may only be 9 as these are the only bars which may effect the line. The same is true for measuring the closes below the tenkan line.

The horizontal boundary lines would be placed a 9 (nine above the tenkan line) and another line at 0 (zero above the tenkan line). The graphed line you currently have will either move towards or away from these boundary lines.

The same idea wold hold for the kijun line but the **maximum**# would be 26.

In addition, for a clean graph could you add a little bit of space above the 9 and below the 0? At present the 9 and 0 are right at the border of the charting area, thanks.


---

## Re: ICH Index

**Apprentice** · Thu Sep 06, 2012 2:07 am

Lines Added.


---

## Re: ICH Index

**Apprentice** · Thu Sep 06, 2012 3:40 am

![ICH Index List.png](images/39755/ICH%20Index%20List.png)

*Ichimoku Index List*



Ichimoku Index List provides overview of price position, in relation to for all ICH components.
Shows the position of price in relation to a specific ICH component,
for the last N periods.

 [ICH Index List.lua](files/39755/ICH%20Index%20List.lua)


---

## Re: ICH Index

**Blackcat2** · Wed Dec 05, 2012 3:53 pm

I"m testing this indicator at the moment and they don't refresh by itself, I have to click bid and then ask button to refresh the indicator.

Technically they should recalculate with every bar closed, can this be done?

Thanks

Regards,
BC


---

## Re: ICH Index

**Apprentice** · Thu Dec 06, 2012 3:03 am

For me, everything works as expected.
Sometimes, often, the value remains unchanged,
If price ICH component cross, did not happen.


---

## Re: ICH Index

**Apprentice** · Thu Apr 05, 2018 6:19 am

The indicator was revised and updated.

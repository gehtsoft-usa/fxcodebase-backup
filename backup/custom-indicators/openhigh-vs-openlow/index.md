# OpenHigh vs OpenLow

> Source: https://fxcodebase.com/code/viewtopic.php?f=17&t=63018  
> Forum: 17 · Topic 63018 · 18 post(s)


---

## OpenHigh vs OpenLow

**Apprentice** · Fri Jan 08, 2016 5:33 am

![EURUSD H1 (01-08-2016 1056).png](images/104169/EURUSD%20H1%20%2801-08-2016%201056%29.png)



Based on.
[viewtopic.php?f=27&t=63017](https://fxcodebase.com/code/viewtopic.php?f=27&t=63017)

SumUp Off / Accumulate Off
 HO= high-open;
OL = open-low

SumUp On / Accumulate Off
Output = (HO-OL)

SumUp On / Accumulate On
Output = Previous Output + (HO-OL)

 [OpenHigh vs OpenLow.lua](files/104169/OpenHigh%20vs%20OpenLow.lua)


---

## OpenHigh vs OpenLow Label

**Apprentice** · Sun Jan 10, 2016 7:29 am

![EURUSD H1 (01-10-2016 1255).png](images/104204/EURUSD%20H1%20%2801-10-2016%201255%29.png)



 [OpenHigh vs OpenLow Label.lua](files/104204/OpenHigh%20vs%20OpenLow%20Label.lua)


---

## Re: OpenHigh vs OpenLow

**Apprentice** · Sat Aug 26, 2017 5:14 am

The indicator was revised and updated.


---

## Re: OpenHigh vs OpenLow

**frankdrebin** · Wed Apr 18, 2018 10:08 pm

Hi all. I am looking for an indicator very similar to this one, but that only shows the LARGER of the UP vs DOWN move, that is, the larger of H-O vs O-L, and charts it as a positive bar. Basically showing the largest move of the day regardless of direction.

Seems that this indicator could easily be modified to do just that by someone who knows how. Unfortunately, I'm not that person.

Could someone modify this to do that, or even give me some tips as to how to do it myself?

As usual, any help would be greatly appreciated.

Thanks again.


---

## Re: OpenHigh vs OpenLow

**Apprentice** · Sat Apr 21, 2018 8:37 am

Is that for OpenHigh vs OpenLow.lua or OpenHigh vs OpenLow Label.lua


---

## Re: OpenHigh vs OpenLow

**frankdrebin** · Tue Apr 24, 2018 2:39 pm

Sorry. Is for OpenHigh vs OpenLow.lua.

Thanks


---

## Re: OpenHigh vs OpenLow

**Apprentice** · Wed Apr 25, 2018 2:25 pm

[OpenHigh vs OpenLow.lua](files/118816/OpenHigh%20vs%20OpenLow.lua)

Try this version.


---

## Re: OpenHigh vs OpenLow

**frankdrebin** · Fri Apr 27, 2018 3:19 am

Close. But the Down Prevailing are still showing as negative bars, below the 0 line. I'm looking for an absolute value that will always be a positive bar, even if the prevailing move was negative. Direction doesn't matter to me, just the size of the move.

Basically I'd just like to see the maximum the market moved during the period, regardless of direction.

Maybe a "Show All As Positive" or an "Absolute Values" option?

Thanks again for all your help.


---

## Re: OpenHigh vs OpenLow

**Apprentice** · Fri Apr 27, 2018 4:42 am

[OpenHigh vs OpenLow.lua](files/118850/OpenHigh%20vs%20OpenLow.lua)

Try it now.
Will apply if Accumulate is set to False and SumUp is set to True


---

## Re: OpenHigh vs OpenLow

**frankdrebin** · Tue May 01, 2018 3:10 pm

Thank you very much!

As always, your help is much appreciated.


---

## Re: OpenHigh vs OpenLow

**scalper007** · Fri May 08, 2020 10:33 am

Hello Apprentice,

Hope you guys are staying safe

Can i please request for a modification of this indicator so that it displays (High - Open) in pips for a GREEN candle and (Open - Low) in pips for a RED Candle?

Cheers,


---

## Re: OpenHigh vs OpenLow

**Apprentice** · Sun May 10, 2020 3:14 am

[OpenHigh vs OpenLow.lua](files/133764/OpenHigh%20vs%20OpenLow.lua)

Try this version.


---

## Re: OpenHigh vs OpenLow

**scalper007** · Sun May 10, 2020 8:36 am

Thanks a lot Apprentice, appreciate it


---

## Re: OpenHigh vs OpenLow

**scalper007** · Sun May 10, 2020 10:11 am

Hello Apprentice,

Thanks for the modification but my request was a slightly different. I don't want any of those functionalities (sum up/accumulate/direction) that are already present in the indicator.

I only want the indicator to display (Open-Low) in pips above a RED candle and (Open - High) in pips below a GREEN candle. As long as the close is above open then it is a green candle and if close is below open then it is a red candle. If close is equal to open (doji) then indicator can ignore that candle. If you wish, you can create this as a new indicator so the existing one is not disturbed.

I would appreciate if you can do this please,

Cheers


---

## Re: OpenHigh vs OpenLow

**Apprentice** · Mon May 11, 2020 4:14 am

[OpenHigh vs OpenLow.lua](files/133801/OpenHigh%20vs%20OpenLow.lua)

Try this version.


---

## Re: OpenHigh vs OpenLow

**scalper007** · Mon May 11, 2020 4:46 am

Hello Apprentice,

I'm really sorry if i was not clear on the request. I apologise please..
I'm looking for the indicator to print the pip value above or below the candles within the chart and not present as separate indicator in separate window. It should look something like the below picture please.

Thanks in advance again,

cheers,


---

## Re: OpenHigh vs OpenLow

**Apprentice** · Tue May 12, 2020 1:43 pm

![AUDCAD H1 (05-12-2020 1853).png](images/133856/AUDCAD%20H1%20%2805-12-2020%201853%29.png)



 [OpenHigh vs OpenLow.lua](files/133856/OpenHigh%20vs%20OpenLow.lua)


---

## Re: OpenHigh vs OpenLow

**scalper007** · Tue May 12, 2020 4:54 pm

Thanks a lot Apprentice, very much appreciated..

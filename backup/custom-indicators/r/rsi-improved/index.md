# RSI Improved

> Source: https://fxcodebase.com/code/viewtopic.php?f=17&t=13892  
> Forum: 17 · Topic 13892 · 10 post(s)


---

## RSI Improved

**Alexander.Gettinger** · Thu Feb 23, 2012 10:25 am

Formulas:
OriginalRSI is a RSI(Original period),
RotatedRSI=100-RSI(Rotated period),
Delta=OriginalRSI-RotatedRSI,
DeltaSpeed=Delta[i-1]-Delta[i].

 

![RSI_ Improved.PNG](images/26692/RSI_%20Improved.PNG)



Download:

 [RSI_Improved.lua](files/26692/RSI_Improved.lua)

The indicator was revised and updated


---

## Re: RSI Improved

**Panther** · Mon Feb 27, 2012 7:51 pm

Alexander, can you program the following?: 1. Add 3 horizontal lines like the Standard RSI with
value, color, style, and width options. Show in the background. Default can be 70,50 and 30.
2. Make the the 2 RSI lines paint in the foreground, like the Delta Speed.
3. Add color, style, and width options to the other lines.
Thanks, Nice Indie.


---

## Re: RSI Improved

**Apprentice** · Tue Feb 28, 2012 5:38 am

Your request is added to the development list.


---

## Re: RSI Improved

**Alexander.Gettinger** · Fri Mar 02, 2012 4:02 pm

> **Panther wrote:**
> Alexander, can you program the following?: 1. Add 3 horizontal lines like the Standard RSI with
> value, color, style, and width options. Show in the background. Default can be 70,50 and 30.
> 2. Make the the 2 RSI lines paint in the foreground, like the Delta Speed.
> 3. Add color, style, and width options to the other lines.
> Thanks, Nice Indie.

See this version of oscillator:

 [RSI_Improved2.lua](files/27469/RSI_Improved2.lua)


---

## Re: RSI Improved

**Panther** · Mon Mar 05, 2012 10:16 am

"2.Could you make the 2 RSI lines paint in the foreground?" needs to be done.
I assume that means the histogram will have to paint in the background.
Sometimes when the lines are far apart. The histogram obscures the bottom line.


---

## Re: RSI Improved

**Alexander.Gettinger** · Thu Mar 08, 2012 11:45 am

> **Panther wrote:**
> "2.Could you make the 2 RSI lines paint in the foreground?" needs to be done.
> I assume that means the histogram will have to paint in the background.
> Sometimes when the lines are far apart. The histogram obscures the bottom line.

The indicator has been updated, please download it again.


---

## Re: RSI Improved

**Panther** · Wed Apr 04, 2012 7:35 am

Could you add "-30" line to the default 70,50,30 lines of V2 ? Thanks


---

## Re: RSI Improved

**Apprentice** · Thu Apr 05, 2012 7:11 am

Your request is added to the development list.


---

## Re: RSI Improved

**Alexander.Gettinger** · Tue Apr 10, 2012 10:21 am

> **Panther wrote:**
> Could you add "-30" line to the default 70,50,30 lines of V2 ? Thanks

Added 3 more levels.

Download:

 [RSI_Improved2.lua](files/29692/RSI_Improved2.lua)


---

## Re: RSI Improved

**Apprentice** · Mon Apr 03, 2017 5:56 am

Indicator was revised and updated.

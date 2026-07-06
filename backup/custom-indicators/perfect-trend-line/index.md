# Perfect Trend Line

> Source: https://fxcodebase.com/code/viewtopic.php?f=17&t=66641  
> Forum: 17 · Topic 66641 · 35 post(s)


---

## Perfect Trend Line

**Apprentice** · Sat Sep 15, 2018 8:48 am

![EURUSD m1 (02-27-2017 0952).png](images/121122/EURUSD%20m1%20%2802-27-2017%200952%29.png)



Based on post
[https://www.prorealcode.com/prorealtime ... trend-line](https://www.prorealcode.com/prorealtime-indicators/perfect-trend-line)

 [Perfect Trend Line.lua](files/121122/Perfect%20Trend%20Line.lua)

 [Perfect Trend Line with Alert.lua](files/121122/Perfect%20Trend%20Line%20with%20Alert.lua)

MT4 version.
[https://fxcodebase.com/code/viewtopic.php?f=38&t=72477](https://fxcodebase.com/code/viewtopic.php?f=38&t=72477)


---

## Re: Perfect Trend Line

**mulligan** · Mon Jul 26, 2021 7:40 pm

Could you please add the normal sound, show alert, dialogue box, live and end of turn to the existing alert function on this indicator.

Many thanks


---

## Re: Perfect Trend Line

**Apprentice** · Tue Jul 27, 2021 2:40 am

Your request is added to the development list.
Development reference 679.


---

## Re: Perfect Trend Line

**Apprentice** · Tue Jul 27, 2021 4:11 am

Perfect Trend Line with Alert.lua added.


---

## Re: Perfect Trend Line

**fx1954** · Tue Jul 27, 2021 10:17 pm

> **Apprentice wrote:**
> Perfect Trend Line with Alert.lua added.

I' m not sure, whether the indicator works as it should. Per definition, in uptrend the support red trendline should switch to resistance when the new low of a candle is lower than the previous three lows and the green trendline should switch to resistance when the new low is lower than the previous 7 lows.
I saw examples on my charts where the indicator did not work in this way.


---

## Re: Perfect Trend Line

**Apprentice** · Thu Jul 29, 2021 3:41 am

Your request is added to the development list.
Development reference 697.


---

## Re: Perfect Trend Line

**fx1954** · Fri Jul 30, 2021 6:52 am

> **Apprentice wrote:**
> Your request is added to the development list.
> Development reference 697.

Is it also possible to add exit signals?

e.g.
when the faster (red) line is switching from resistence to support, a green star as exit signal for longs is displayed

and vice versa,

when the faster (red) line is switching from support to resistence a red star as exit signal for longs is displayed.


---

## Re: Perfect Trend Line

**Apprentice** · Fri Jul 30, 2021 1:06 pm

The code is identical to the ProRealTime code.
It doesn't have anything as you have described.


---

## Re: Perfect Trend Line

**chai88888** · Tue Aug 03, 2021 4:18 am

hi there can you please make a strategy with this

buy when green dot appears

sell when red dot appears

please add a MA filter buy only when above MA sell only below MA

thanks


---

## Re: Perfect Trend Line

**Apprentice** · Wed Aug 04, 2021 4:39 am

fx1954
It looks like it's the opposite to entry. Entry long = exit short?


---

## Re: Perfect Trend Line

**Apprentice** · Wed Aug 04, 2021 4:58 am

chai88888
Your request is added to the development list.
Development reference 716.


---

## Re: Perfect Trend Line

**Apprentice** · Wed Aug 04, 2021 1:30 pm

[Perfect_Trend_Line_Strategy.lua](files/143096/Perfect_Trend_Line_Strategy.lua)

Try this version.


---

## Re: Perfect Trend Line

**TLBshifted** · Wed Aug 04, 2021 11:21 pm

This indicator looks so cool. May I know what is the logic or theme behind its calculations?

Thanks


---

## Re: Perfect Trend Line

**Apprentice** · Thu Aug 05, 2021 5:29 am

Will this be sufficient?
[https://www.prorealcode.com/prorealtime ... rend-line/](https://www.prorealcode.com/prorealtime-indicators/perfect-trend-line/)


---

## Re: Perfect Trend Line

**TLBshifted** · Fri Aug 06, 2021 1:16 am

Yes, thank you. Just want to know whether this indicator repaints or not.


---

## Re: Perfect Trend Line

**Apprentice** · Fri Aug 06, 2021 12:13 pm

Do NOT repaint.


---

## Re: Perfect Trend Line

**fx1954** · Fri Aug 06, 2021 2:42 pm

> **Apprentice wrote:**
> fx1954
> It looks like it's the opposite to entry. Entry long = exit short?

the dots only show up if the slower line flips,
there is no signal, if only the faster line flips, this is most of the tine earlier before the slower line flips.
an exit signal would be, if the faster line flips, but the slower line does not yes print a new dot in the opposite direction. please kiik at chart example.


---

## Re: Perfect Trend Line

**TLBshifted** · Fri Aug 06, 2021 11:31 pm

Thanks


---

## Re: Perfect Trend Line

**Apprentice** · Sat Aug 07, 2021 9:06 am

Your request is added to the development list.
Development reference 727.


---

## Re: Perfect Trend Line

**fx1954** · Sat Aug 07, 2021 11:05 pm

> **Apprentice wrote:**
> Your request is added to the development list.
> Development reference 727.

Thank you.
I added another chart example to point out that some time it is more complex.


---

## Re: Perfect Trend Line

**chai88888** · Wed Aug 11, 2021 8:44 am

hi there can you please add a MA filter for the strategy

buy only if above MA and vice versa

thanks


---

## Re: Perfect Trend Line

**Apprentice** · Wed Aug 18, 2021 1:36 pm

[Perfect_Trend_Line_Strategy.lua](files/143262/Perfect_Trend_Line_Strategy.lua)

Try this version.


---

## Re: Perfect Trend Line

**chai88888** · Fri Aug 20, 2021 1:00 am

hello can you make this stategy twek a little bit

so here the condition

buy only if the newest green dot is higher than the previous green dot

sell only if the newest red dot is lower than the previous red dot

thanks


---

## Re: Perfect Trend Line

**Apprentice** · Fri Aug 20, 2021 1:12 pm

Your request is added to the development list.
Development reference 761.


---

## Re: Perfect Trend Line

**Apprentice** · Tue Aug 24, 2021 3:01 am

Try this version.
[https://fxcodebase.com/code/viewtopic.php?f=31&t=71443](https://fxcodebase.com/code/viewtopic.php?f=31&t=71443)


---

## Re: Perfect Trend Line

**chai88888** · Mon Jan 17, 2022 2:42 am

hello there

can you please make a strategy based on this indicator

buy when green dots appears

sell when red dots appears

the difference here is that the lot is increasing

example
1st position is buy in 1lot
2nd position is sell in 2lot don't close on opposite signal
3rd position is buy in 3lot
4th position is in sell in 4lot
and so on
 and please add stop the strategy if it reach a certain amount in dollars in profit or loss

thanks


---

## Re: Perfect Trend Line

**Apprentice** · Mon Jan 17, 2022 3:25 am

Your request is added to the development list.
Development reference 39.


---

## Re: Perfect Trend Line

**chai88888** · Mon Jan 31, 2022 2:29 am

hi there any news on ref no. 39?

thanks


---

## Re: Perfect Trend Line

**SKIN84** · Thu Feb 24, 2022 9:32 am

hello,
 is it possible to have the MT4 version of the Perfect Trend Line indicator?
thank you in advance


---

## Re: Perfect Trend Line

**Apprentice** · Fri Feb 25, 2022 4:08 am

Your request is added to the development list.
Development reference 123.


---

## Re: Perfect Trend Line

**SKIN84** · Tue Mar 29, 2022 3:41 am

Hello,
I want to know if you were able to advance on the MT4 indicator?
Thank you for the work provided
Cordially


---

## Re: Perfect Trend Line

**SKIN84** · Wed Apr 13, 2022 11:14 am

Hello,
I was just wondering if there was any progress on my recemt request?
Thank you again and have a good day!


---

## Re: Perfect Trend Line

**trader33** · Sun Apr 17, 2022 9:44 am

> **Apprentice wrote:**
> Your request is added to the development list.
> Development reference 679.

Bonjour,
Juste un petit bonjour et un gros merci pour tout ce que vous faites.
Je suis vraiment non seulement impressionné par vos connaissances mais aussi reconnaissant que vous les partagiez avec la communauté.
Encore merci
Alain


---

## Re: Perfect Trend Line

**SKIN84** · Wed May 18, 2022 5:08 am

Hi,
Can you tell me where you are on the indicator?
cordially


---

## Re: Perfect Trend Line

**Apprentice** · Mon Jul 11, 2022 3:15 am

MT4 version.
[https://fxcodebase.com/code/viewtopic.php?f=38&t=72477](https://fxcodebase.com/code/viewtopic.php?f=38&t=72477)

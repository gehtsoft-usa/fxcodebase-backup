# MACD Cross with MA Filter Helper with Alert

> Source: https://fxcodebase.com/code/viewtopic.php?f=17&t=59718  
> Forum: 17 · Topic 59718 · 26 post(s)


---

## MACD Cross with MA Filter Helper with Alert

**Apprentice** · Tue Oct 22, 2013 8:58 am

![MACD Cross with MA Filter Helper with Alert.png](images/90235/MACD%20Cross%20with%20MA%20Filter%20Helper%20with%20Alert.png)



This Helper will give Up / Down arrows on the basis of indications.

It have three filters.
1) MACD / Signal Cross
2) Price / MA Cross
3) MACD / Signal Cross with Price / MA confirmation

 [MACD Cross with MA Filter Helper with Alert.lua](files/90235/MACD%20Cross%20with%20MA%20Filter%20Helper%20with%20Alert.lua)

Dec 26, 2015: Compatibility issue Fix. _Alert helper is not longer needed.

Also U have to install Averages Indicator for this one.
[viewtopic.php?f=17&t=2430](https://fxcodebase.com/code/viewtopic.php?f=17&t=2430)

MACD is based on MACD with crossing
[viewtopic.php?f=17&t=41284](https://fxcodebase.com/code/viewtopic.php?f=17&t=41284)


---

## Re: MACD Cross with MA Filter Helper with Alert

**udaysharma** · Wed Oct 23, 2013 8:36 am

Hi Apprentice
I really Appreciate and Thanks for your invaluable help .

Reagrds
Uday


---

## Re: MACD Cross with MA Filter Helper with Alert

**udaysharma** · Wed Oct 23, 2013 8:43 am

Hi Apprentice
Please let me know how to use **_Alert**with this signal.
I mean what to write in parameters in **_Alert**.

Regards
Uday


---

## Re: MACD Cross with MA Filter Helper with Alert

**Apprentice** · Thu Oct 24, 2013 1:22 am

![Capture.PNG](images/90287/Capture.PNG)



Please activate _Alert.
_Alert Is Indicator helper.
U can activate it in the same way as a strategy.


---

## Re: MACD Cross with MA Filter Helper with Alert

**udaysharma** · Thu Nov 14, 2013 2:20 am

Hello Apprentice

1). I am getting the alerts on CURRENT candle,which is not yet formed completly,which is causing
 some false signal.
 I need that,the ARROW (alert) should be formed(shown),only after the current candle has been
 formed COMPLETLY.
 Please look into the matter and please make the required updation.
2). One more thing,Please merge **MACD Overlay2.lua** with this indicator.

Thanks and Regards
Uday Sharma


---

## Re: MACD Cross with MA Filter Helper with Alert

**Apprentice** · Thu Nov 14, 2013 5:56 am

End of Turn / Live selector added.


---

## Re: MACD Cross with MA Filter Helper with Alert

**udaysharma** · Thu Nov 14, 2013 7:32 am

Hello Apprentice
I really appreciate your quick update.
**1)** As I am selecting END OF TURN option,its coming with an error (pic
 enclosed),with no ARROWS.

 Please let me know if I am doing something wrong.
**2)** And ,Please make an indicator having **MACD Cross with MA Filter
 Helperwith Alert** and **MACD OVERLAY2.LUA** both in one .
 Or please include **MACD OVERLAY2.LUA**with **MACD Cross with MA
 Filter Helper with Alert**

Thanks and Regards
Uday Sharma


---

## Re: MACD Cross with MA Filter Helper with Alert

**Apprentice** · Thu Nov 14, 2013 9:29 am

I was unable to replicate this issue.
However i have add an additional check, to handle a potential problem


---

## Re: MACD Cross with MA Filter Helper with Alert

**udaysharma** · Thu Nov 14, 2013 11:10 am

Thanks
Now it is working fine .
Thanks again

Please make an indicator having MACD Cross with MA Filter
Helperwith Alert and MACD OVERLAY2.LUA both in one .
Or please include **MACD OVERLAY2.LUA** with **MACD Cross with MA
Filter Helper with Alert**

regards


---

## please add a 4th filter (zero-line cross over/under)

**SuperTrader** · Sun Dec 08, 2013 12:00 pm

Hi Apprentice, this is a **very helpful indicator** indeed, was such a great idea to write it! Can we please have a **4th filter** (in the exact **same** fashion as the other 3 filters):
The zero-line **cross** over/under (as this type of cross is such a **crucial** part of the MACD theory/interpretation). Thank you in advance for that!


---

## Re: MACD Cross with MA Filter Helper with Alert

**Apprentice** · Wed Dec 11, 2013 9:32 am

Histogram & MACD Zero Line Cross Alert Added.


---

## Re: MACD Cross with MA Filter Helper with Alert

**SuperTrader** · Sat Dec 14, 2013 4:11 am

Awesome! Thank you very much!


---

## Re: MACD Cross with MA Filter Helper with Alert

**Apprentice** · Sun Dec 27, 2015 10:18 am

Dec 26, 2015: Compatibility issue Fix. _Alert helper is not longer needed.


---

## Re: MACD Cross with MA Filter Helper with Alert

**allerner** · Wed Sep 14, 2016 3:11 pm

Hi Apprentice thanks for the indicator.
I'm getting the following error with this indicator:
An error occurred during the calculation of the indicator
'MACD CROSS WITH MA FILTER HELPER WITH ALERT(AUD/USD, MVA, 12, 26, MVA, 9, MVA, 9)'.
The error details: C:/Program Files (x86)/Candleworks/FXTS2/Indicators/Custom/MACD Cross with MA Filter Helper with Alert.lua:439:
The fourth parameter must be a number.
Thank you an advance


---

## Re: MACD Cross with MA Filter Helper with Alert

**Apprentice** · Wed Sep 14, 2016 4:09 pm

Fixed.


---

## Re: MACD Cross with MA Filter Helper with Alert

**Apprentice** · Sat Sep 02, 2017 5:57 am

The indicator was revised and updated.


---

## Re: MACD Cross with MA Filter Helper with Alert

**papynou34** · Fri Sep 15, 2017 1:00 pm

Hello,
I did a search with no success. I am trying to find a strategy associated with this indicator. Do you know one?


---

## Re: MACD Cross with MA Filter Helper with Alert

**Apprentice** · Fri Sep 15, 2017 3:17 pm

Can you define rules for such strategy?


---

## Re: MACD Cross with MA Filter Helper with Alert

**papynou34** · Tue Sep 19, 2017 8:16 am

![GER30 m2 (09-19-2017 1319).png](images/114979/GER30%20m2%20%2809-19-2017%201319%29.png)



Hello,
Open a long when a blue Arrow appears with x lots
Open a short when a red arrow appears with x lots

Thanks a lot


---

## Re: MACD Cross with MA Filter Helper with Alert

**papynou34** · Tue Sep 19, 2017 9:10 am

Sorry I forgot the close.
Close position when opposite signal(arrow) appears.


---

## Re: MACD Cross with MA Filter Helper with Alert

**Apprentice** · Wed Sep 20, 2017 4:20 am

Are signals based on MACD Cross with MA Filter Helper with Alert.lua ?

1, "MACD/Signal "
2, "Price/MA "
3, "MACD/Signal - Price/MA Consensus"
4, "MACD/Zero "
5, "Histogram/Zero "

Are all 5 signals needed or only one?


---

## Re: MACD Cross with MA Filter Helper with Alert

**papynou34** · Fri Sep 22, 2017 4:12 am

Hello Apprendice,
Thanks for your answer.
In fact I would like to have the same rules for orders than for the drawing of the arrow on chart. That means for me draw arrow + open order.
Is it possible to have this in the indicator instead of a stratégy?


---

## Re: MACD Cross with MA Filter Helper with Alert

**papynou34** · Fri Sep 22, 2017 5:14 am

I guess I need just 1) MACD/SIGNAL.
Thanks for the great job you perform.


---

## Re: MACD Cross with MA Filter Helper with Alert

**Apprentice** · Sat Sep 23, 2017 5:13 am

Try this version.
[viewtopic.php?f=31&t=65112&p=115063#p115063](https://fxcodebase.com/code/viewtopic.php?f=31&t=65112&p=115063#p115063)


---

## Post 25

**papynou34** · Sat Sep 23, 2017 6:30 pm

Many Thanks Apprendice


---

## Re: MACD Cross with MA Filter Helper with Alert

**Apprentice** · Thu May 10, 2018 5:45 am

The Indicator was revised and updated.

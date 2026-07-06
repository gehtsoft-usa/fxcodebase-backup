# TRIPLE BOLLINGER

> Source: https://fxcodebase.com/code/viewtopic.php?f=31&t=70725  
> Forum: 31 · Topic 70725 · 10 post(s)


---

## TRIPLE BOLLINGER

**Apprentice** · Wed Dec 16, 2020 10:00 am

![EURUSD m5 (12-16-2020 1559).png](images/139620/EURUSD%20m5%20%2812-16-2020%201559%29.png)



Based on request.
[viewtopic.php?f=27&t=70720](https://fxcodebase.com/code/viewtopic.php?f=27&t=70720)

 [TRIPLE BOLLINGER.lua](files/139620/TRIPLE%20BOLLINGER.lua)


---

## Re: TRIPLE BOLLINGER

**fortesan9** · Wed Dec 30, 2020 2:19 pm

Dear Apprentice,

The strategie works Beautifully . You are my new Saint.

Can you create one with a multitimeframe exit/entry?

Yours Respectfully,

fortesan9


---

## Re: TRIPLE BOLLINGER

**Apprentice** · Sat Jan 02, 2021 3:01 pm

Can you give me an example?


---

## Re: TRIPLE BOLLINGER

**fortesan9** · Sat Jan 02, 2021 10:39 pm

Open Long:
Price CROSSESOVER Bollinger Band 3 BL
Price CROSSESOVER Bollinger Band 2 BL
Price CROSSESOVER Bollinger Band 1 BL
Price CROSSESOVER Bollinger Band AL
Price CROSSESOVER Bollinger Band 1 TL
Price CROSSESOVER Bollinger Band 2 TL

Close Long:
Price CROSSESOVER Bollinger Band 3 TL @ Target Timeframe
Price CROSSESUNDER Bollinger Band 2 TL @ Target Timeframe

Open Short:
Price CROSSESUNDER Bollinger Band 3 TL
Price CROSSESUNDER Bollinger Band 2 TL
Price CROSSESUNDER Bollinger Band 1 TL
Price CROSSESUNDER Bollinger Band AL
Price CROSSESUNDER Bollinger Band 1 BL
Price CROSSESUNDER Bollinger Band 2 BL

Close Short:
Price CROSSESUNDER Bollinger Band 3 BL @ Target Timeframe
Price CROSSESOVER Bollinger Band 2 BL @ Target Timeframe

+ Bollinger Band Calculation Source Function


---

## Re: TRIPLE BOLLINGER

**Apprentice** · Sun Jan 03, 2021 5:07 am

Your request is added to the development list.
Development reference 20.


---

## Re: TRIPLE BOLLINGER

**Apprentice** · Sun Jan 03, 2021 9:50 am

don't understand the requirements
...
Price CROSSESOVER Bollinger Band 2 BL
...
Price CROSSESOVER Bollinger Band 2 TL
I don't think there is point in these two conditions. It looks like a typo

Or adequate entry/exit will be selected from a list o available options?


---

## Re: TRIPLE BOLLINGER

**fortesan9** · Sun Jan 03, 2021 12:28 pm

The requirements:

Price CROSSESOVER Bollinger Band 2 BL
&
Price CROSSESOVER Bollinger Band 2 TL

are two extra long/short signals for catching another bit of the trend of the bollinger's.
...

''Adequate entry/exit will be selected from a list o available options'' sounds like great idea and would be also awesome because the current exit signals don't seem to offer handsome results.

The multitimeframe entry/exit function on the ''Multitimeframe Parabolic S.A.R Strategy" is the one I'm referring for being added to this strategie.


---

## Re: TRIPLE BOLLINGER

**Apprentice** · Mon Jan 04, 2021 4:29 am

Your request is added to the development list.
Development reference 28.


---

## Re: TRIPLE BOLLINGER

**Apprentice** · Sun Feb 14, 2021 9:55 am

It's already in the condition


---

## Re: TRIPLE BOLLINGER

**fortesan9** · Sun Feb 14, 2021 4:13 pm

My bad, sorry

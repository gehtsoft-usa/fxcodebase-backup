# Dashboard of Indicators

> Source: https://fxcodebase.com/code/viewtopic.php?f=17&t=61967  
> Forum: 17 · Topic 61967 · 26 post(s)


---

## Dashboard of Indicators

**Apprentice** · Thu Mar 05, 2015 1:21 pm

![Dashboard of Indicators.png](images/99055/Dashboard%20of%20Indicators.png)



Based on request.
[viewtopic.php?f=27&t=61960](https://fxcodebase.com/code/viewtopic.php?f=27&t=61960)

 [Dashboard of Indicators.lua](files/99055/Dashboard%20of%20Indicators.lua)

 [Customizable Dashboard of Indicators.lua](files/99055/Customizable%20Dashboard%20of%20Indicators.lua)

 

![Single Instrument Dashboard of Indicators.png](images/99055/Single%20Instrument%20Dashboard%20of%20Indicators.png)



 [MTF Dashboard of Indicators.lua](files/99055/MTF%20Dashboard%20of%20Indicators.lua)

 [Customizable MTF Dashboard of Indicators.lua](files/99055/Customizable%20MTF%20Dashboard%20of%20Indicators.lua)

Customizable Dashboard of Indicators.lua & Customizable MTF Dashboard of Indicators.lua
Will allow u to choose the most of available custom indicator.


---

## Re: Dashboard of Indicators

**daniel.kovacik** · Tue Mar 10, 2015 11:45 am

Hello,

thank you very much... Could you also add possibility for multi timeframe?

Timeframes horizontaly and indicators vertically. Indicators on multi timeframe of one currency pair in rectangle with background (transparency)

Thanks
Regards
DK


---

## Re: Dashboard of Indicators

**Apprentice** · Wed Mar 11, 2015 6:01 am

MTF Instrument Dashboard of Indicators Added.


---

## Re: Dashboard of Indicators

**daniel.kovacik** · Sat Mar 14, 2015 8:53 am

Hello,
thanks for hard work.

Is there a way how to turn off labels in the first tool? It takes too much place when we have open multiple charts.
I am talking about name of the currency pair and name of indicators. Just numbers please.

Thanks
Regards
DK


---

## Re: Dashboard of Indicators

**pasban** · Mon Mar 16, 2015 1:43 am

May I ask what is K for ? May I understand that Up bar is a bar which got the close higher than that of a previous bar. It was appreciated if you could explain why using Middle Price in this formula
Thank you


---

## Re: Dashboard of Indicators

**Apprentice** · Mon Mar 16, 2015 3:11 am

If you add SFK Fast Stochastic, or SSD Slow Stochastic, this is your chart.
You will see that both have K and D component.


---

## Re: Dashboard of Indicators

**Apprentice** · Mon Mar 16, 2015 3:13 am

I do not understand Middle Price bit.


---

## Re: Dashboard of Indicators

**Apprentice** · Mon Mar 23, 2015 4:36 am

Customizable Dashboard of Indicators.lua & Customizable MTF Dashboard of Indicators.lua Added.
Will allow u to choose the most of available custom indicator.


---

## Re: Dashboard of Indicators

**baccicin** · Mon Mar 23, 2015 5:09 am

Hi Apprentice! Great stuff as usual!
Is it possible to have pair on a horizontal line and indicators on a vertical line?
many thanks, have a nice day
Fabio


---

## Re: Dashboard of Indicators

**Apprentice** · Mon Mar 23, 2015 6:50 am

Of course such an orientation is possible.

As it is optimized for the maximum number of slots.
Will try to find the time to make such a version.


---

## Re: Dashboard of Indicators

**baccicin** · Thu Mar 26, 2015 3:30 am

Hi Apprentice, when you have the possibility, can you please add the possibility to change the font-size, the best size is the one used as defauld in TSII in "news" window.
Also please, Apprentice, if I use the indicator 4MA (3 lineas are drawed), the "Dasboard of Indicators" shows just 2 value, is it possible showing all the values (in this case 3 values for 3 lines)?
many thanks, have a nice day
Fabio


---

## Re: Dashboard of Indicators

**baccicin** · Thu Mar 26, 2015 3:56 am

Hi again Apprentice, the file attached is what i mean. Also price should be shown.
I hope it's possible.
many thanks, ciao
Fabio


---

## Re: Dashboard of Indicators

**baccicin** · Tue Apr 07, 2015 3:31 am

Hi Guys, may I ask you an answer to my previous question?
thanks you
brgds
Fabio


---

## Re: Dashboard of Indicators

**Apprentice** · Wed Apr 08, 2015 6:52 am

Your request is added to the development list.


---

## Re: Dashboard of Indicators

**baccicin** · Mon Apr 27, 2015 9:53 am

Hi Apprentice, is it possible to have an answer?
Many thanks, ciao
Fabio


---

## Re: Dashboard of Indicators

**Apprentice** · Tue Apr 28, 2015 2:42 am

Possible, unfortunately I did not have time for a task concerned.


---

## Re: Dashboard of Indicators

**baccicin** · Thu May 07, 2015 10:22 am

Hi Apprentice! I can understand that i am boring you... please apologies but may i ask you to amend the code?
"customizable dashboard of indicators"; if you check, you can see that all the pairs choosen show the same value of the chart's pair where the pairs are, i mean (for example):
the chart i am whatching is Eur/Usd,
i choose (multiple currency pair) these pairs: Eur/Usd, Gbp/Usd and Usd/Cad (for example)
and the system shows the values of pairs in a separete window as suggested
the problem is that these values (for example VMA and EMA but it's just an example) are the same for all the currency pairs i can choose.
Could you please amend it?
many thanks.
Fabio


---

## Re: Dashboard of Indicators

**Apprentice** · Mon May 11, 2015 3:11 am

Fixed.
Please Re-Download Customizable Dashboard of Indicators.lua


---

## Re: Dashboard of Indicators

**baccicin** · Mon May 11, 2015 5:08 am

Hi Apprentice! Great stuff! it's perfect. Many thanks for your job and for your patience!
You're the best!
ciao
Fabio


---

## Re: Dashboard of Indicators

**baccicin** · Wed May 13, 2015 7:38 am

Hi Apprentice, i would ask a question...again...
is it doable this further implementation below:
- suppose to use 2 MVA (10 and 20 or other, it's just an example)
- an arrow (green for long position and black for short position) is shown when a Mva crossover (or down) the other with at least X pips of difference (i should have the possibility to choose how many pips)
and leave the arrow shown on the chart until the end of the day?
Many thanks, have a nice day.
Fab


---

## Re: Dashboard of Indicators

**baccicin** · Wed Aug 05, 2015 8:41 am

Hello Apprentice, can I change please my former request?
if you have the time, please add these functions to this code:
- possibility to choose a time frame (for example m30 or H1 or H4 etc etc)
- a green arrow is shown when, at the end of the candle, the price closes above the indicator i have choosen (for example a MVA or other indicator) and Momentum is up than a specific and personal value that i can decide everytime
- a black arrow is shown when, at the end of the candle, the price closes below the indicator i have choosen and Momentum is below than a specific and personal value that i can decide everytime
- in this moment, Dashboard of Indicators, shows the value of indicators; the arrows should be draw not on the chart rather on the dashboard, close to the value/price.
Could it be possible?
Many thanks, have a nice day.
fabio


---

## Re: Dashboard of Indicators

**Apprentice** · Thu Aug 06, 2015 5:39 am

Your request is added to the development list.


---

## Re: Dashboard of Indicators

**jupiter ange** · Fri Oct 14, 2016 12:09 pm

> **Apprentice wrote:**
>
>
> Dashboard of Indicators.png
>
>
> Based on request.
> [http://fxcodebase.com/code/viewtopic.php?f=27&t=61960](https://fxcodebase.com/code/viewtopic.php?f=27&t=61960)
>
>
> Dashboard of Indicators.lua
>
>
>
>
> Customizable Dashboard of Indicators.lua
>
>
>
>
>
> Single Instrument Dashboard of Indicators.png
>
>
>
>
> MTF Dashboard of Indicators.lua
>
>
>
>
> Customizable MTF Dashboard of Indicators.lua
>
>
>
> Customizable Dashboard of Indicators.lua & Customizable MTF Dashboard of Indicators.lua
> Will allow u to choose the most of available custom indicator.

hello Programmer
ppouvez you do me a small change to the customizable dashboard of indicators ...
can you added a button to enable one or more time showing off our choice eg 15mins, 1H and 4H.
and when I select an EMA I would like to choose the data source eg higher, closing or lower.
a Audible alert will be welcome.
thank you.


---

## Re: Dashboard of Indicators

**Apprentice** · Tue Oct 18, 2016 7:14 am

Your request is added to the development list, Under Id Number 3652
 If someone is interested to do this task, please contact me.


---

## Re: Dashboard of Indicators

**Alexander.Gettinger** · Wed Dec 13, 2017 1:46 pm

Please, try this version of dashboard with a choice of the price type:

 [Customizable Dashboard of Indicators2.lua](files/116460/Customizable%20Dashboard%20of%20Indicators2.lua)


---

## Re: Dashboard of Indicators

**Apprentice** · Wed Mar 28, 2018 4:19 pm

The Indicator was revised and updated.

# Strong Vs Weak

> Source: https://fxcodebase.com/code/viewtopic.php?f=17&t=59804  
> Forum: 17 · Topic 59804 · 23 post(s)


---

## Strong Vs Weak

**Apprentice** · Tue Nov 05, 2013 1:04 pm

![Strength Index.png](images/90585/Strength%20Index.png)



Similar to template used for Krivo Index
[viewtopic.php?f=17&t=59670](https://fxcodebase.com/code/viewtopic.php?f=17&t=59670)

Strength Index is a calculator as sum of Pip changes for all currency pairs.
Derived from chosen currency pairs.

 [Strength Index.lua](files/90585/Strength%20Index.lua)

 [MTF MCP Strength Index.lua](files/90585/MTF%20MCP%20Strength%20Index.lua)

 [MTF MCP Strength Index with Sorting.lua](files/90585/MTF%20MCP%20Strength%20Index%20with%20Sorting.lua)


---

## Re: Strong Vs Weak

**Apprentice** · Sat Nov 09, 2013 4:48 pm

![Strong Vs Weak.png](images/90692/Strong%20Vs%20Weak.png)



This version incorporates all three versions in a single indicator.
Additionally, i have add two additional algorithm for data filtering.
 "Price Change", "Price/ Fast MA Position", "Fast MA/ Slow MA Position"

 [Strong Vs Weak.lua](files/90692/Strong%20Vs%20Weak.lua)


---

## Re: Strong Vs Weak

**RoyPrins** · Mon Nov 11, 2013 8:42 pm

Hi Apprentice, Is it possible to create an indicator like this but then with the pips differential calculated per pair? Like that you can see immediately which pair has the best potential. Given the fact that trends usually last a while you can then buy on dips or sell the rallys. Let me know. Regards,
Roy


---

## Re: Strong Vs Weak

**Apprentice** · Tue Nov 12, 2013 4:25 am

Something like this.
[viewtopic.php?f=17&t=3234&hilit=movers](https://fxcodebase.com/code/viewtopic.php?f=17&t=3234&hilit=movers)
[viewtopic.php?f=17&t=8257&p=18259#p18259](https://fxcodebase.com/code/viewtopic.php?f=17&t=8257&p=18259#p18259)


---

## Re: Strong Vs Weak

**andrea.2k** · Sun Dec 29, 2013 7:25 pm

> **Apprentice wrote:**
>
>
> Strong Vs Weak.png
>
>
> This version incorporates all three versions in a single indicator.
> Additionally, i have add two additional algorithm for data filtering.
> "Price Change", "Price/ Fast MA Position", "Fast MA/ Slow MA Position"
>
>
> Strong Vs Weak.lua

Hello Apprentice,
firstly i'd like to thank you for the great professionality .

My first post on this forum is to ask you a clarification about the "Price Change" filter.

Is it a sort of ROC (rate of change) indicator or what ?

Best regards
Andrea


---

## Re: Strong Vs Weak

**Apprentice** · Mon Dec 30, 2013 3:43 am

"Price Change"
It is the difference between Close and Open Price for the relevant currency pair.

"Price/ Fast MA Position"
It is the difference between Close and Fast MA for the relevant currency pair.

 "Fast MA/ Slow MA Position"
It is the difference between Two moving averages for the relevant currency pair.


---

## Re: Strong Vs Weak

**andrea.2k** · Mon Dec 30, 2013 5:15 am

> **Apprentice wrote:**
> "Price Change"
> It is the difference between Close and Open Price for the relevant currency pair.
>
> "Price/ Fast MA Position"
> It is the difference between Close and Fast MA for the relevant currency pair.
>
> "Fast MA/ Slow MA Position"
> It is the difference between Two moving averages for the relevant currency pair.

Many thanks for prompt and clear reply.


---

## Re: Strong Vs Weak

**nchatzoglou** · Mon Jan 27, 2014 2:36 am

Hi,
FIrst of all, I want to thank for the great indicator, which is perfect for the strong weak analysis. I want to report a problem that I ve encountered with the Strong vs Weak indicator. When I import the indicator to the diagram the indicator is shifted to the right and 4 columns cannot be seeing(the're hiding left of the screen). How can I overcome this problem??


---

## Re: Strong Vs Weak

**Apprentice** · Mon Jan 27, 2014 3:52 am

I have tested Strong Vs Weak, I have found no problems.
Can you specify which version was used.


---

## Re: Strong Vs Weak

**nchatzoglou** · Mon Jan 27, 2014 4:16 am

I used the last version(Strong vs Weak. lua ). I m using 3 different computers. In two of them I found no problem. But in the 3rd, I encountered this situation I discribed earlier. Does the screen analysis plays any role on this?? I didn t try to change because it cannot support such high analysis (the screen is square). I m giving you a screenshot.


---

## Re: Strong Vs Weak

**Apprentice** · Tue Jan 28, 2014 3:14 am

Possible reason.
The screen is too small to display all the elements.
Indicator does not use scaling to adjust to the screen size.


---

## Re: Strong Vs Weak

**nchatzoglou** · Thu Jan 30, 2014 12:33 am

I thought so myself but the screen I m talking about is 17 in. In a netbook where I also use the indicator the screen is 10,1 in and the indicator is shown just fine. So I don't think the screen is the problem.
Thank you anyway


---

## Re: Strong Vs Weak

**Stance** · Mon May 02, 2016 4:52 pm

> **Apprentice wrote:**
>
>
> Strong Vs Weak.png
>
>
> This version incorporates all three versions in a single indicator.
> Additionally, i have add two additional algorithm for data filtering.
> "Price Change", "Price/ Fast MA Position", "Fast MA/ Slow MA Position"
>
>
> Strong Vs Weak.lua

Thanks Apprentice, for this great indicator.

I've notice for the price change calculation you have this:

Code: [Select all](https://fxcodebase.com/code/)
`Flag = (SourceData[j][i].close[SourceData[j][i].close:size()-1] > SourceData[j][i].open[SourceData[j][i].close:size()-1]);`

Is SourceData[j][i].open[SourceData[j][i].**close**:size()-1]); correct or should it be:

Flag = (SourceData[j][i].close[SourceData[j][i].close:size()-1] > SourceData[j][i].open[SourceData[j][i].**open**:size()-1]);


---

## Re: Strong Vs Weak

**Apprentice** · Wed May 04, 2016 2:53 am

Will have same outcome.
Number of open is equal to the number of close.


---

## Re: Strong Vs Weak

**Apprentice** · Sun Feb 04, 2018 7:50 am

The Indicator was revised and updated.


---

## Re: Strong Vs Weak

**jrichardson83** · Wed Jul 17, 2019 10:44 am

Would it be possible to display this as an "on-chart" indicator, specifically showing only the pair for the current chart. For example, display AUD vs NZD for the AUD/NZD pair? With the option of showing the indicator in top/bottom and left/right.


---

## Re: Strong Vs Weak

**Apprentice** · Thu Jul 18, 2019 4:45 am

We have a few indicator versions.
Can you provide an exact indicator name?


---

## Re: Strong Vs Weak

**jrichardson83** · Mon Jul 22, 2019 12:20 pm

> **Apprentice wrote:**
> We have a few indicator versions.
> Can you provide an exact indicator name?

Probably just the Strength Index


---

## Re: Strong Vs Weak

**Apprentice** · Tue Jul 23, 2019 10:29 am

Your request is added to the development list under Id Number 4802


---

## Re: Strong Vs Weak

**Apprentice** · Wed Jul 24, 2019 4:33 am

Try Strength Index.lua now.


---

## Re: Strong Vs Weak

**Avignon** · Wed Feb 05, 2020 9:58 am

Hello,

Is possible make something like this?

[https://www.myfxbook.com/forex-market/heat-map](https://www.myfxbook.com/forex-market/heat-map)

Thanks.


---

## Re: Strong Vs Weak

**Apprentice** · Thu Feb 06, 2020 8:35 am

For Strength Index.lua
or something like Movers and Shakers (Price)
[viewtopic.php?f=17&t=3234&hilit=Movers](https://fxcodebase.com/code/viewtopic.php?f=17&t=3234&hilit=Movers)


---

## Re: Strong Vs Weak

**Avignon** · Thu Feb 06, 2020 9:16 am

I saw that. But my level of English made me doubt that's what it was.

Thank you.

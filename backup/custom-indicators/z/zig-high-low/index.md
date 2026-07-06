# Zig high-low

> Source: https://fxcodebase.com/code/viewtopic.php?f=17&t=70583  
> Forum: 17 · Topic 70583 · 13 post(s)


---

## Zig high-low

**Apprentice** · Thu Oct 29, 2020 12:38 pm

![EURUSD D1 (10-29-2020 1837).png](images/138562/EURUSD%20D1%20%2810-29-2020%201837%29.png)



Based on request.
[viewtopic.php?f=27&t=70569](https://fxcodebase.com/code/viewtopic.php?f=27&t=70569)

 [Zig high-low.lua](files/138562/Zig%20high-low.lua)


---

## Re: Zig high-low

**SANTOSH** · Sat Oct 31, 2020 3:41 am

Dear Apprentice ,
Thanks for working on my request .

I checked the code , seems something is not correct here .
Last zig high /low which contains inside all the next zig high low was =
Last zig high - 1.12538
Last zig low - 1.11677

But as per the image its printing -
1.11933 (zig high) and 1.11713( zig low )

The print should be this as the request was :
Condition -
The zig highlow values should only update when
1. The new zig high is above the old zig high .
2. The new zig low is below the old zig low .
Otherwise it should not update .

Kindly check if anything is bugged .

Regards ,
Santosh .


---

## Re: Zig high-low

**Apprentice** · Tue Nov 03, 2020 6:15 am

[Zig high-low.lua](files/138636/Zig%20high-low.lua)

Try this version.


---

## Re: Zig high-low

**SANTOSH** · Wed Nov 04, 2020 4:53 am

Dear Team ,
Good work as always , working as expected .

Request for two updates :

Update # 1 :
Remove the lookback setting which is used in the menu as PERIOD , instead do the following :
a. Whenever there is a new zig low , the high print should be previous zig high .
b. Whenever there is a new zig high, the low print should be previous zig low .
Attached image .

Update# 2:
a. Count the number of bars after the new zig high or new zig low .
b. Reset the count at new zig high/low .
Attached image .


---

## Re: Zig high-low

**Apprentice** · Thu Nov 05, 2020 3:38 am

Your request is added to the development list.
Development reference 2253.


---

## Re: Zig high-low

**SANTOSH** · Fri Nov 06, 2020 1:36 pm

> **Apprentice wrote:**
> Your request is added to the development list.
> Development reference 2253.

.
Updates?


---

## Re: Zig high-low

**Apprentice** · Thu Nov 12, 2020 5:46 am

![BABA.us H1 (11-12-2020 1143).png](images/138841/BABA.us%20H1%20%2811-12-2020%201143%29.png)



You have changed the definition a few times, will need clear specifications to continue.
Or this is an alternative version?
What will be high/low in a situation when the current zig-zag is lower than the previous zig-zag low.
The first zig zag lower than current?


---

## Re: Zig high-low

**SANTOSH** · Thu Nov 12, 2020 8:08 am

> **Apprentice wrote:**
>
>
> The attachment **BABA.us H1 (11-12-2020 1143).png** is no longer available
>
>
> You have changed the definition a few times, will need clear specifications to continue.
> Or this is an alternative version?
> What will be high/low in a situation when the current zig-zag is lower than the previous zig-zag low.
> The first zig zag lower than current?

1. When the current zig low is lower than the previous zig low do below ; otherwise dont do anything. Attached pic from your example .

**High** - Current Zig high
**Low** -Current Zig low
**Count** = No of bars after the confirmed Zig low .Reset the count whenever there is a change in the above High/ Low value .
**Width** = High - low
**Ratio** = Width/Count

Hope its clear now .


---

## Re: Zig high-low

**Apprentice** · Fri Nov 13, 2020 3:29 am

[Zig high-low.lua](files/138851/Zig%20high-low.lua)

Try this version.


---

## Re: Zig high-low

**SANTOSH** · Fri Nov 13, 2020 4:09 am

> **Apprentice wrote:**
>
>
> The attachment **Zig high-low.lua** is no longer available
>
>
> Try this version.

BUG


---

## Re: Zig high-low

**Apprentice** · Sun Nov 15, 2020 3:50 am

Your request is added to the development list.
Development reference 2311.


---

## Re: Zig high-low

**Apprentice** · Mon Nov 16, 2020 5:55 am

[Zig high-low.lua](files/138911/Zig%20high-low.lua)

Try this version.


---

## Re: Zig high-low

**SANTOSH** · Thu Nov 19, 2020 1:52 pm

> **Apprentice wrote:**
>
>
> Zig high-low.lua
>
>
> Try this version.

Working great .

# Candlesticks Condensed

> Source: https://fxcodebase.com/code/viewtopic.php?f=17&t=61996  
> Forum: 17 · Topic 61996 · 6 post(s)


---

## Candlesticks Condensed

**Apprentice** · Sun Mar 15, 2015 4:47 am

![Candlesticks Condensed.png](images/99249/Candlesticks%20Condensed.png)



In February 2015 issue of S&C magazine David Cline author of “Candlesticks Condensed” describes a process for condensing every candle on a chart into three numbers: HO (high-open), HC (high-close) and OL (open-low). Each number is a fraction of the average daily range. The three numbers together (HO:HC:OL) make up the bar’s signature.

 [Candlesticks Condensed.lua](files/99249/Candlesticks%20Condensed.lua)


---

## Re: Candlesticks Condensed

**paololuigi** · Thu Apr 02, 2015 1:55 am

Hi Apprentice, but why the figure show only two of the three symbol (HO, HL) you've described?


---

## Re: Candlesticks Condensed

**Apprentice** · Fri Apr 03, 2015 6:03 am

In my testing all three values are shown.


---

## Re: Candlesticks Condensed

**paololuigi** · Wed Apr 08, 2015 4:31 pm

in the last raw of code you've repeat HC label two times:

... local Label= string.format("HO:%i\n HC:%i\n HC:%i\n" , HO, HC, OL); ...

in your picture attached you can see it


---

## Re: Candlesticks Condensed

**Apprentice** · Sun Apr 12, 2015 6:40 am

Fixed.


---

## Re: Candlesticks Condensed

**Apprentice** · Mon Oct 29, 2018 7:26 am

The indicator was revised and updated.

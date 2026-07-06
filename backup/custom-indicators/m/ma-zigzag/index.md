# MA ZigZag

> Source: https://fxcodebase.com/code/viewtopic.php?f=17&t=69545  
> Forum: 17 · Topic 69545 · 7 post(s)


---

## MA ZigZag

**Apprentice** · Wed Mar 18, 2020 4:53 am

![USOil m1 (03-18-2020 0902).png](images/132046/USOil%20m1%20%2803-18-2020%200902%29.png)



You can download Tick ZigZag here.
[viewtopic.php?f=17&t=34791](https://fxcodebase.com/code/viewtopic.php?f=17&t=34791)

 [MA ZigZag.lua](files/132046/MA%20ZigZag.lua)


---

## Re: MA ZigZag

**Gilles** · Wed Mar 18, 2020 5:57 am

Hi Apprentice,

Where is MA ZigZag ?

:)


---

## Re: MA ZigZag

**Apprentice** · Thu Mar 19, 2020 4:19 am

Fixed.


---

## Re: MA ZigZag

**Gilles** · Thu Mar 19, 2020 7:48 pm

Hi Apprentice,

I tried to choose the source of MA ZigZag with MA:getCandleOutPut(0) and it doesn't work. I have a mistake.
then MA:getStream(0) and even with MA:getStreamCount()-1.
In short, I can't create an error-free strategy.

can you make an example of a strategy to understand my mistake.

Example of rule:
if ZigZag[period] > MVA(12) (external indicator) = SELL
elseif ZigZag[period] < MVA (12)
(external indicator) = BUY
End

thenk you


---

## Re: MA ZigZag

**Apprentice** · Fri Mar 20, 2020 5:36 am

Can you please post your code?
If this is not a problem, can you post your request here?
[viewforum.php?f=27](https://fxcodebase.com/code/viewforum.php?f=27)


---

## Re: MA ZigZag

**Gilles** · Fri Mar 20, 2020 7:24 am

Hi Apprentice,

My code is not finished, so it's under construction. I can't post it right now.

To come back to my question?

I have proposed the realization of a ZigZag indicator whose source is MVA 20 periods. Personally, I get better results with MVA 7 periods.

when I include this indicator in my strategy I get an error message. I wrote this:

MAZZ = core.indicators:create("MA ZigZag", MA.getCandleOutPut(0), Depth, Deviation, Backstep);

How do I write to make it work?
Could you help me?

Thank you in advance for your support.


---

## Re: MA ZigZag

**Apprentice** · Sat Mar 21, 2020 5:59 am

MA.getCandleOutPut(0) will nat work.
MA does NOT provide candle output, MA will only provide a single line.
getCandleOutPut(0) will work on source signals that have all close, high, low, open data points.

# Advance Decline Line

> Source: https://fxcodebase.com/code/viewtopic.php?f=17&t=60479  
> Forum: 17 · Topic 60479 · 3 post(s)


---

## Advance Decline Line

**Apprentice** · Mon Mar 31, 2014 6:08 am

![Advance Decline Line.png](images/93307/Advance%20Decline%20Line.png)



Advance Decline Line Indicator can be used as a measure of trend strength as well as an indication of possible change.

ADL indicator in Forex provides a comparison between the number of market advancing and declining moments for a given period of time.

If used Cumulative algorithm will add current period Advance Decline Line to previous period Advance Decline Line value​​.

Code: [Select all](https://fxcodebase.com/code/)
`for i=0,Period-1, 1 do
       if source.close[period-i]> source.open[period-i] then
       rs=rs+1;
       end
       if source.close[period-i]< source.open[period-i] then
       fs=fs+1;
       end
    end
 
        if Cumulative then
        ADL[period] =  rs - fs + ADL[period-1];
        else
       ADL[period] =  rs - fs ;
      end`

 [Advance Decline Line.lua](files/93307/Advance%20Decline%20Line.lua)

The indicator was revised and updated


---

## Re: Advance Decline Line

**Alexander.Gettinger** · Mon Jun 02, 2014 4:52 pm

MQL 4 version of Advance Decline Line: [viewtopic.php?f=38&t=60759](https://fxcodebase.com/code/viewtopic.php?f=38&t=60759).


---

## Re: Advance Decline Line

**Apprentice** · Thu Jun 22, 2017 7:04 am

The indicator was revised and updated.

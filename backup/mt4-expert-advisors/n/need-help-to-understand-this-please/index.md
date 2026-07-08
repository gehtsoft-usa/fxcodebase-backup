# Need help to understand this please

> Source: https://fxcodebase.com/code/viewtopic.php?f=38&t=71127  
> Forum: 38 · Topic 71127 · 3 post(s)

---

## Need help to understand this please

**MichaelMano** · Fri Apr 23, 2021 10:01 am

I need some advice for the below code if you please,

Period_MA is an external variable and I set it to 20, but when I am testing my code by changing

Code: [Select all](https://fxcodebase.com/code/)
`for(x=i; x<i+Period_MA; x++)`
to

Code: [Select all](https://fxcodebase.com/code/)
`for(x=i; x<=i+Period_MA; x++)`
the moving average disappear from the chart

```mql4
int Counted_Bars = IndicatorCounted();
   int Uncounted_Bars = Bars - Counted_Bars;
   Uncounted_Bars++;

   for(int i=0; i<=Uncounted_Bars; i++)
     {
      double Total = 0;
         for(x=i; x<i+Period_MA; x++)
           {
            Total = Total + iClose(NULL,0,x);
           }
       
       Closing_Price_Array[i] = Total / Period_MA;
     }
```

Noting that when I add the equal sign to the previously stated line of code , I get the moving average to widen like below, so I just need to know how it was calculated just by adding an equal sign so that will be the outcome

Thank you

---

## Re: Need help to understand this please

**Apprentice** · Fri Apr 23, 2021 11:48 am

Your request is added to the development list.
Development reference 403.

---

## Re: Need help to understand this please

**Apprentice** · Wed Apr 28, 2021 10:07 am

Can you provide the complete code?
Take a look at the expert's tab. There should be an error printed.

# BSTrend

> Source: https://fxcodebase.com/code/viewtopic.php?f=17&t=67034  
> Forum: 17 · Topic 67034 · 4 post(s)


---

## BSTrend

**Apprentice** · Sat Dec 01, 2018 9:09 am

![EURUSD D1 (04-02-2018 0355).png](images/122447/EURUSD%20D1%20%2804-02-2018%200355%29.png)



Based on post.
[https://www.prorealcode.com/prorealtime ... s/bstrend/](https://www.prorealcode.com/prorealtime-indicators/bstrend/)

 [BSTrend.lua](files/122447/BSTrend.lua)

BSTrend.lua based strategy.
[viewtopic.php?f=31&t=67041](https://fxcodebase.com/code/viewtopic.php?f=31&t=67041)


---

## Re: BSTrend

**Daveatt** · Mon Dec 03, 2018 5:34 am

Hi Apprentice

This is a great indicator
Could you please develop a strategy for it ?

Thanks in advance
David


---

## Re: BSTrend

**Apprentice** · Mon Dec 03, 2018 6:09 am

BSTrend.lua based strategy.
[viewtopic.php?f=31&t=67041](https://fxcodebase.com/code/viewtopic.php?f=31&t=67041)


---

## Re: BSTrend

**Daveatt** · Mon Dec 03, 2018 6:50 am

Confirming it's working fine

Thanks so much

PS: I asked your help because my solution wasn't working
I creating an external stream in the BStrend indicator and tried to access it via the strategy

In the indicator

Code: [Select all](https://fxcodebase.com/code/)
`function Prepare(name)
...
 BST_Stream = instance:addStream("BST_Stream" , core.Bar, " BST_Stream"," BST_Stream",Neutral, first);

...

function Update(period)
..
 if ((ld8 < 0.0 and ld0 > 0.0) or ld8 < 0.0) then
    Oscillator:setColor(period,Down);
    BST_Stream = -1;
    elseif ((ld8 > 0.0 and ld0 < 0.0) or ld8 > 0.0) then 
    Oscillator:setColor(period, Up);
    BST_Stream = 1;
    else
    Oscillator:setColor(period,Neutral);
    BST_Stream = 0;
    end
..
end`

In the strategy

Code: [Select all](https://fxcodebase.com/code/)
`function Update(period)
  if   BST.BST_Stream[period] == 1
   then
      BUY();
   elseif   BST.BST_Stream[period] == -1
   then 
      SELL();
   else
      T1_BST_Trend = "";
   end
end`

Anyway your solution is working so I'm happy with it. I'll remember that if I can't access a data stream from a strategy for some reason, that I can always access the colors

Best
Daveatt

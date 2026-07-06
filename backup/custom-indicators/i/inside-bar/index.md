# Inside Bar

> Source: https://fxcodebase.com/code/viewtopic.php?f=17&t=43376  
> Forum: 17 · Topic 43376 · 19 post(s)


---

## Inside Bar

**Apprentice** · Wed Jul 03, 2013 5:12 am

![Inside Bar.png](images/70076/Inside%20Bar.png)



Inside Bar Rules
high < high of previous candle
low > low of previous candle

 [Inside Bar.lua](files/70076/Inside%20Bar.lua)

 

![InsideBar With Smallest Range Filter.png](images/70076/InsideBar%20With%20Smallest%20Range%20Filter.png)



 [InsideBar With Smallest Range Filter.lua](files/70076/InsideBar%20With%20Smallest%20Range%20Filter.lua)

 

![MTF MCP Inside Bar List.png](images/70076/MTF%20MCP%20Inside%20Bar%20List.png)



 [MTF MCP Inside Bar List.lua](files/70076/MTF%20MCP%20Inside%20Bar%20List.lua)

 

![InsideBar Support Resistance.png](images/70076/InsideBar%20Support%20Resistance.png)



 [InsideBar Support Resistance.lua](files/70076/InsideBar%20Support%20Resistance.lua)

The indicator was revised and updated


---

## Re: Inside Bar

**Apprentice** · Tue Jul 08, 2014 3:24 am

MTF MCP Inside Bar List Added


---

## Re: Inside Bar

**newton** · Wed Dec 10, 2014 2:43 am

hi apprendice,

this indicator not loading indices, gas, .....
can you please make it to load the indices


---

## Re: Inside Bar

**Apprentice** · Fri Dec 12, 2014 4:40 am

Support for Indexes added.
Be sure to set Majors Only to Yes.


---

## Re: Inside Bar

**Apprentice** · Thu Apr 30, 2015 6:21 am

Bump Up.


---

## Re: Inside Bar

**mchurch2006** · Fri Sep 11, 2015 7:33 am

Hi Apprentice/Developers,

Is it possible to adapt this inside bar concept somewhat?

What I would like to achieve, is to have support and resistance lines drawn from the top and bottom of the Mother bar, identical to the way lines are drawn in adv_fractal_support_resistance lua (though I appreciate this is based on Fractals) with the same options of colour and line length etc.

Ideally I would also like only the inside bar to be coloured and that the other original colours themes of my trading station aren't changed on the chart like it is with the overlay, I'm guessing clearly the colouration of the inside bar is achieved by the code in the overlay, but the thing is my candles are simple black and white and one is filled the other empty/hollow and I'm trying to preserve this colour theme in the overlay, so I guess if the overlay could allow for me to choose colours and filled or empty this would be fabulous.

Ultimately I would wish to apply the concept on a H4/H1 or any smaller timeframe chart with levels taken from a D1 motherbar/inside bar setup.

I hope this makes sense?

Thanks in advance,

Mike


---

## Re: Inside Bar

**Apprentice** · Mon Sep 14, 2015 4:23 am

InsideBar Support Resistance Added.


---

## Re: Inside Bar

**mchurch2006** · Thu Sep 17, 2015 2:55 pm

Hi Apprentice,

Thanks for taking the time to create the support resistance inside bar lua which is great, though would it be possible to adapt this further so both a support and resistance line are drawn (so two lines) from the high/low of the mother bar (bar prior to the inside bar) rather than drawing the line from the bias of the inside bar itself?

As a conservative approach to inside bar trading would possibly be to wait to see which side the mother bar is broken and two lines, one on the high and the other off the low of the mother bar would help to visually indicate this.

It would be great if the lua could retain it's current code/operation but also have an additional option to enable the mother bar support/resistance lines, would this be possible please?

Thanks in advance, again I appreciate your time and effort.

Mike


---

## Re: Inside Bar

**mchurch2006** · Thu Oct 08, 2015 4:09 am

Hi Guys,

Sorry to sound like I'm chasing but do you think you could adapt this indicator as per my outline above?

Thanks in advance,

Mike


---

## Re: Inside Bar

**Apprentice** · Thu Oct 08, 2015 4:19 am

Your request is added to the development list.


---

## Re: Inside Bar

**mchurch2006** · Wed Nov 25, 2015 5:01 am

Hi Guys,

Sorry to follow up again but is there any chance you may get an opportunity to adapt this inside bar lua?

Thanks in advance,

Mike


---

## Re: Inside Bar

**Coondawg71** · Tue Feb 16, 2016 1:00 pm

Can we please request:

1.) MTF MCP Wide Body Range list, like the MTF MCP Inside Bar list indicator...

and

2.) Wide Body Range Support and Resistance, like the Inside Bar Support and Resistance indicator.

Thanks!!!

[viewtopic.php?f=17&t=43376&hilit=Inside+Bar](https://fxcodebase.com/code/viewtopic.php?f=17&t=43376&hilit=Inside+Bar)


---

## Re: Inside Bar

**Apprentice** · Wed Feb 17, 2016 7:23 am

Try MTF MCP Wide Body Range list.lua
[viewtopic.php?f=17&t=63162&p=104850#p104850](https://fxcodebase.com/code/viewtopic.php?f=17&t=63162&p=104850#p104850)


---

## Re: Inside Bar

**Apprentice** · Thu Mar 03, 2016 6:59 am

Wide Body Range Support and Resistance Added.
[viewtopic.php?f=17&t=63162&p=104850#p104850](https://fxcodebase.com/code/viewtopic.php?f=17&t=63162&p=104850#p104850)


---

## Re: Inside Bar

**Coondawg71** · Mon Jun 13, 2016 1:45 pm

Great work on the Wide Range Bar and Inside Bar tools !

Can we please request another tool:

Just like you've managed to do with Wide Range Bars and Inside Bars, can we please request Support and Resistance levels plotted with Doji bars.

Ideally, the tool would have the high wick and the low wick of each Doji serve as the Support and Resistance Level.

Most importantly, If possible, the Doji Close value would have a level plotted as well. If we can achieve that task. Can we please add Alert Functions to the Doji closing value level. Alert would be triggered upon closing of price bars that follow the Doji bar. If price closes above Doji closing value, trigger is for a Buy. If prices closes below Doji closing value, trigger is for a Sell. The Alerts would be directional arrow on chart, Dialog box and Sound functions please.

Thanks!!!

sjc


---

## Re: Inside Bar

**Apprentice** · Tue Jun 14, 2016 2:37 am

Your request is added to the development list,
Under Bugzilla Id Number 3545


---

## Re: Inside Bar

**Apprentice** · Wed Jun 15, 2016 5:50 am

Try this version.
[viewtopic.php?f=17&t=63599](https://fxcodebase.com/code/viewtopic.php?f=17&t=63599)


---

## Re: Inside Bar

**Coondawg71** · Thu Jun 16, 2016 5:42 am

Outstanding work on the Doji Support and Resistance!

Thanks!

sjc


---

## Re: Inside Bar

**mchurch2006** · Fri Dec 09, 2016 1:13 pm

Hi Devs,

I have previously posted and requested an adaption on this inside bar lua, do you think it would be possible to adapt to draw support/resistance lines on the mother bar as well as the inside bar (maybe enabling or disabling the features could be included)

I appreciate people are busy it would just be a great addition to this lua. See previous posts if further details are required.

Thanks in advance,

Mike

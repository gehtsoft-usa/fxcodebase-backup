# Support Rresistance Profile

> Source: https://fxcodebase.com/code/viewtopic.php?f=17&t=63679  
> Forum: 17 · Topic 63679 · 13 post(s)


---

## Support Rresistance Profile

**Apprentice** · Sun Jul 17, 2016 5:38 am

![EURUSD m1 (07-17-2016 1205).png](images/107164/EURUSD%20m1%20%2807-17-2016%201205%29.png)



Based on request.
[viewtopic.php?f=27&t=63677](https://fxcodebase.com/code/viewtopic.php?f=27&t=63677)

 [Support Rresistance Profile.lua](files/107164/Support%20Rresistance%20Profile.lua)

The indicator was revised and updated


---

## Re: Support Rresistance Profile

**Hailkayy** · Mon Jul 18, 2016 12:11 am

Perfect.
You got the idea.

Can you explain a few things ?

a)Sometimes there are red zone and no green zone, sometimes there are both, sometime just one of them. If only red box appears what does it mean ?

b)If the box is long or small what does it mean ?

c)Sometime there are some white spaces, whereas price crosse the area at least once, what does it mean ?

d) What's the difference if I set box size to 5 pips or 20 ?
e) What do you suggest ? Making it thinner or wider for better results ? if I want the zones where if I put a horizontal line, price will cross over and go further without retracing back ?

Very good indicator, taking it further.

Thanks


---

## Re: Support Rresistance Profile

**Apprentice** · Mon Jul 18, 2016 5:51 am

Line length will depend on the number of support / resistance in zone.
Support is determined by candle low.
Resistance is determined by candle high.


---

## Re: Support Rresistance Profile

**Cactus** · Mon Jul 18, 2016 1:11 pm

This is great! Can you turn it into an oscillator somehow please? Or something that gives values every period? For example it might look similar to your "vektor" indicator. And if green line is longer than red at particular line it will cover it up and vice versa? But still 2 values available to be checked for each period? That would be amazing


---

## Re: Support Rresistance Profile

**Hailkayy** · Mon Jul 18, 2016 1:40 pm

Ok thanks.

Could you add an option so we can select "Wick/Body" as A base for the algorithm to do its calculation ? Sometimes I find trading breakout of body of candles (close/open) also useful.

That's it. Thanks.


---

## Re: Support Rresistance Profile

**Apprentice** · Tue Jul 19, 2016 6:10 am

"Wick/Body" option added.


---

## Re: Support Rresistance Profile

**Apprentice** · Tue Jul 19, 2016 7:42 am

Cactus, profiles have multiple levels, as described, oscillator does not make sense.
We can make profiles for each trading day.
Where profiles will be calculated for each trading day.
Will this be ok.


---

## Re: Support Rresistance Profile

**Hailkayy** · Tue Jul 19, 2016 8:46 am

Thanks apprentice,

Very efficient individual keep up, rare.


---

## Re: Support Rresistance Profile

**Cactus** · Tue Jul 19, 2016 1:03 pm

> **Apprentice wrote:**
> Cactus, profiles have multiple levels, as described, oscillator does not make sense.
> We can make profiles for each trading day.
> Where profiles will be calculated for each trading day.
> Will this be ok.

I understand there are multiple levels, but price can only be in one place at a time right? I am looking at smaller timeframes than the daily. I like this indicator you made very much but I don't like it is only a visual aid and doesn't output any values. What I had in mind is an indicator below the chart.

I added an image for explanation

Basically reflect the indicator horizontally instead, and show the levels according to where the price is at given period in time.
Perhaps to achieve what I want it would be necessary to utilise tick charts? Since a candlestick can span multiple lines? Though I don't mind if it repaints as long as real time data is accurate. I hope this is possible


---

## Re: Support Rresistance Profile

**Apprentice** · Mon Jul 25, 2016 1:48 pm

Your request is added to the development list,
Under Bugzilla Id Number 3578

Bugzilla is developer internal requests database.
If someone is interested to do any task from this list please contact me.


---

## Re: Support Rresistance Profile

**Cactus** · Tue May 30, 2017 11:32 am

Ok I understand my previous request was not compatible with this indictor.
However, I find it useful, could you make the following edits?:

Have an option to display only the highest number of points (support vs resistance)
For example:
If resistance bar is longer than support, only show resistance
If support bar is longer than resistance, only show support

Have an option to display both wick and close combined as one bar?


---

## Re: Support Rresistance Profile

**Apprentice** · Wed May 31, 2017 9:33 am

Your request is added to the development list, Under Id Number 3806
 If someone is interested to do this task, please contact me.


---

## Re: Support Rresistance Profile

**Apprentice** · Sat Jun 24, 2017 3:39 am

Try it now.

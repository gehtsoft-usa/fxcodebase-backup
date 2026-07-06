# Time Series Forecasting

> Source: https://fxcodebase.com/code/viewtopic.php?f=17&t=66659  
> Forum: 17 · Topic 66659 · 5 post(s)


---

## Time Series Forecasting

**Apprentice** · Fri Sep 21, 2018 8:34 am

![EURCAD D1 (09-21-2018 1334).png](images/121185/EURCAD%20D1%20%2809-21-2018%201334%29.png)



 [Time Series Forecasting.lua](files/121185/Time%20Series%20Forecasting.lua)


---

## Re: Time Series Forecasting

**Gilles** · Thu Jul 20, 2023 3:26 am

Hi Apprentice,

Is this indicator based on the work of Tushar Chande?
I might be confusing it with the "Time Frame Forecast indicator"?

I saw that you had developed the "Chande Forecast Oscillator" oscillator, so I was wondering if you also took on the challenge of developing the "Time Frame Forecast indicator".

Thank you for your response.


---

## Re: Time Series Forecasting

**Apprentice** · Thu Jul 20, 2023 1:51 pm

Can you provide bit more information on "Time Frame Forecast indicator"?


---

## Re: Time Series Forecasting

**Gilles** · Mon Aug 07, 2023 9:25 am

Hi Apprentice,

As we know, the Chande Forecast Oscillator (CFO) compares expected (forecasted) prices with actual prices. Expected prices are calculated using "linear regression," which aims to find a straight line that best fits historical prices.

If expected prices are higher than current actual prices, the oscillator is positive (above zero). This suggests that the indicator believes prices will increase in the future = [Green line].

Conversely, if expected prices are lower than current actual prices, the oscillator is negative (below zero). This suggests that the indicator believes prices will decrease in the future = [Red line].

In short, the Chande Forecast Oscillator (CFO) aims to inform us whether prices are likely to rise or fall based on a comparison between expected and actual prices. The CFO helps us form an idea about future price movements.

That's why I was wondering if the indicator you're proposing, "Time series forecasting," might be a variant of the Chande Forecast Oscillator (CFO).

Here's my request and proposal:

Would it be possible to provide a variant that allows users to choose a profile:
Choice 1. Scalping = M1, M5, M15;
Choice 2. Day trading = M15, H1, H4;
Choice 3. Swing trading = H4, D1, W1.

Once the profile is selected, the indicator would draw the line and attempt to indicate a price.

It would be really interesting to see the outcome with the line color-coded as follows:
If line > Price = GREEN line.
If line < Price = RED line.

I hope you find the idea intriguing. Thank you very much for reading.


---

## Re: Time Series Forecasting

**Apprentice** · Tue Aug 08, 2023 3:25 am

We have added your request to the development list.
Development reference 679.

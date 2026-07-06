# TSV X-RSIOMA Strategy

> Source: https://fxcodebase.com/code/viewtopic.php?f=31&t=71577  
> Forum: 31 · Topic 71577 · 4 post(s)


---

## TSV X-RSIOMA Strategy

**Apprentice** · Sat Oct 16, 2021 6:10 am

![EURUSD m1 (10-16-2021 1309).png](images/143961/EURUSD%20m1%20%2810-16-2021%201309%29.png)



Based on the request.
[https://fxcodebase.com/code/viewtopic.php?f=31&p=143936](https://fxcodebase.com/code/viewtopic.php?f=31&p=143936)

 [TSV X-RSIOMA Strategy.lua](files/143961/TSV%20X-RSIOMA%20Strategy.lua)

 [TSV.lua](files/143961/TSV.lua)

 [X-RSIOMA.lua](files/143961/X-RSIOMA.lua)


---

## Re: TSV X-RSIOMA Strategy

**minifire18** · Mon Oct 18, 2021 3:21 am

Hey Apprentice & team

Thanks this is great stuff, can you add higher time frame for conformation of direction and reduce the noise and add 2 filters, the filters would be only on the higher time frame

If conditions are met on higher time frame the lower time frame will only take the higher time frame biased direction

Filter 1
Also have a minimum continuous histogram bars required biased to the zero line on the X-RSIOMA for the higher time frame to define the direction in the parameter settings (to avoid the pullbacks)
eg: IF higher time frame flips zero line for 6 bars and requirements is 10 then no signal would be given for the 6 bars

Filter 2
Also have a minimum continuous histogram bars required biased to the zero line on the X-RSIOMA before the zero line was flipped
eg; IF higher time frame flips zero line below for 6 bars but was 25 bars above prior the 6 bars below then to ignore filter 1, to have in parameter settings (to be able to get into the long term trend)

Thanks in advance
Minifire


---

## Re: TSV X-RSIOMA Strategy

**Apprentice** · Wed Oct 20, 2021 6:14 am

Your request is added to the development list.
Development reference 925.


---

## Re: TSV X-RSIOMA Strategy

**Apprentice** · Tue Nov 02, 2021 11:36 am

[TSV X-RSIOMA Strategy.lua](files/144146/TSV%20X-RSIOMA%20Strategy.lua)

Something like this?

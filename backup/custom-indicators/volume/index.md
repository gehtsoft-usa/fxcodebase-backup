# Volume

> Source: https://fxcodebase.com/code/viewtopic.php?f=17&t=69949  
> Forum: 17 · Topic 69949 · 14 post(s)


---

## Volume

**Apprentice** · Mon Jun 01, 2020 8:26 am

![AUDUSD H1 (06-01-2020 1335).png](images/134490/AUDUSD%20H1%20%2806-01-2020%201335%29.png)



Will color volume bar based on candle direction.
Based on request.
[viewtopic.php?f=27&t=69933](https://fxcodebase.com/code/viewtopic.php?f=27&t=69933)

 [Volume.lua](files/134490/Volume.lua)


---

## Re: Volume

**TastyTreats** · Fri Jun 12, 2020 10:38 am

Hi Apprentice

Is it possible to have this for MT4 as well please.

Thanks


---

## Re: Volume

**Apprentice** · Sun Jun 14, 2020 7:20 pm

Your request is added to the development list.
Development reference 1477.


---

## Re: Volume

**Apprentice** · Tue Jun 16, 2020 7:16 am

It's not possible. MT4 doesn't have "DIRECTIONAL_REAL_VOLUME"


---

## Re: Volume

**TastyTreats** · Fri Jun 19, 2020 5:02 pm

Hi Apprentice

Thanks for the reply. Can it be implemented using the following code snippet?

void Vcolor(int p)
 {
 if(Close[p] lt Open[p])
 {
 VolBuffer1[p]=Volume[p];
 VolBuffer2[p]=0;
 lastcolor=Red;
 }
 if(Close[p] gt =Open[p])
 {
 VolBuffer1[p]=0;
 VolBuffer2[p]=Volume[p];
 lastcolor=Green;
 }

 }

Thanks


---

## Re: Volume

**Apprentice** · Sun Jun 21, 2020 3:56 am

Exactly this logic is implemented.
Can you clarify, deviations if any?


---

## Re: Volume

**TastyTreats** · Tue Jun 30, 2020 5:28 am

Is it possible to make it an MT4 version without Direct Real volume and using the code above to colour the volume bars to the same colour as the price bars e.g. bullish price bar (green) creates a green volume bar and vise versa for bearish bars.


---

## Re: Volume

**Apprentice** · Tue Jun 30, 2020 8:48 am

It's not possible. MT4 doesn't have "DIRECTIONAL_REAL_VOLUME"


---

## Re: Volume

**TastyTreats** · Thu Jul 02, 2020 6:42 pm

OK Thanks for taking the time to look anyway.


---

## Re: Volume

**taipan** · Fri Jul 10, 2020 8:24 am

Here you go, mt4 TicksSeparateVolume.

 [TicksSeparateVolume.ex4](files/135841/TicksSeparateVolume.ex4)


---

## Re: Volume

**adloule** · Fri Dec 11, 2020 5:30 pm

hi Apprentice,

can you please an average on the "real" volume bar please


---

## Re: Volume

**Apprentice** · Sat Dec 12, 2020 7:15 am

Your request is added to the development list.
Development reference 2449.


---

## Re: Volume

**Apprentice** · Sun Dec 13, 2020 2:17 pm

I don't understand what needs to be done.
You can get an average by putting an average indicator on that Volume indicator


---

## Re: Volume

**adloule** · Mon Dec 14, 2020 7:43 am

ok thank you
that's what i wanted
i added a MA on it

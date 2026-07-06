# MTF MCP SAR with Alert

> Source: https://fxcodebase.com/code/viewtopic.php?f=17&t=65667  
> Forum: 17 · Topic 65667 · 8 post(s)


---

## MTF MCP SAR with Alert

**Apprentice** · Tue Jan 23, 2018 9:14 am

![USDSEK m5 (01-23-2018 1320).png](images/117213/USDSEK%20m5%20%2801-23-2018%201320%29.png)



 [MTF MCP SAR with Alert.lua](files/117213/MTF%20MCP%20SAR%20with%20Alert.lua)

The indicator was revised and updated


---

## Re: MTF MCP SAR with Alert

**jrichardson83** · Tue Jan 23, 2018 10:13 am

Hey thanks Apprentice.

I was really wanting more of a standard "heatmap" to in the bottom window.


---

## Re: MTF MCP SAR with Alert

**Apprentice** · Tue Jan 23, 2018 11:02 am

Try SAR_Heat_Map.lua from this topic.
[viewtopic.php?f=17&t=15356&hilit=mcp+sar](https://fxcodebase.com/code/viewtopic.php?f=17&t=15356&hilit=mcp+sar)


---

## Re: MTF MCP SAR with Alert

**jrichardson83** · Tue Jan 23, 2018 2:21 pm

> **Apprentice wrote:**
> Try SAR_Heat_Map.lua from this topic.
> [viewtopic.php?f=17&t=15356&hilit=mcp+sar](https://fxcodebase.com/code/viewtopic.php?f=17&t=15356&hilit=mcp+sar)

I'm getting this message

 

![Error Message.PNG](images/117219/Error%20Message.PNG)


---

## Re: MTF MCP SAR with Alert

**Apprentice** · Wed Jan 24, 2018 5:24 am

Looks like a bug in FXTS2.
It is a sporadic error that I notice from time to time. Try to add it again.
Have reported this to TS development Team.


---

## Re: MTF MCP SAR with Alert

**Apprentice** · Wed Jan 24, 2018 8:21 am

Try it now.


---

## Re: MTF MCP SAR with Alert

**jrichardson83** · Thu Jan 25, 2018 1:42 pm

> **Apprentice wrote:**
> Try it now.

No longer getting the error, but there is something fishy about the calculation. The Weekly PSAR for the EURUSD right now is most definitely below the price, but the indie is showing that it is above the price.

 

![PSAR Error.PNG](images/117262/PSAR%20Error.PNG)


---

## Re: MTF MCP SAR with Alert

**Apprentice** · Fri Jan 26, 2018 12:00 pm

![USDSEK W1 (01-26-2018 1611).png](images/117284/USDSEK%20W1%20%2801-26-2018%201611%29.png)



All three seem synchronized.

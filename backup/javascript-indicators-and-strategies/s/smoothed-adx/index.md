# Smoothed ADX

> Source: https://fxcodebase.com/code/viewtopic.php?f=48&t=66023  
> Forum: 48 · Topic 66023 · 1 post(s)


---

## Smoothed ADX

**Alexander.Gettinger** · Tue May 01, 2018 1:53 pm

Formulas:
DIP[i]=Alpha2*DIP_Temp[i]+(1-Alpha2)*DIP[i-1],
DIM[i]=Alpha2*DIM_Temp[i]+(1-Alpha2)*DIM[i-1],
ADX[i]=Alpha2*ADX_Temp[i]+(1-Alpha2)*ADX[i-1], where
DIP_Temp[i]=2*DMI_P[i]+(Alpha1-2)*DMI_P[i-1]+(1-Alpha1)*DIP_Temp[i-1],
DIM_Temp[i]=2*DMI_M[i]+(Alpha1-2)*DMI_M[i-1]+(1-Alpha1)*DIM_Temp[i-1],
ADX_Temp[i]=2*ADX_I[i]+(Alpha1-2)*ADX_I[i-1]+(1-Alpha1)*ADX_Temp[i-1],
DMI_P, DMI_M - DMI+ and DMI-,
ADX_I - standard ADX indicator.

 

![Smoothed_ADX.PNG](images/118951/Smoothed_ADX.PNG)



Download:

 [Smoothed_ADX_JS.jsl](files/118951/Smoothed_ADX_JS.jsl)

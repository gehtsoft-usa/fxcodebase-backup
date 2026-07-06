# MA position Overlay Position Strategy

> Source: https://fxcodebase.com/code/viewtopic.php?f=31&t=61739  
> Forum: 31 · Topic 61739 · 5 post(s)


---

## MA position Overlay Position Strategy

**Apprentice** · Tue Jan 20, 2015 3:35 am

![MA position Overlay Position Strategy.png](images/98237/MA%20position%20Overlay%20Position%20Strategy.png)



Based on MA position Overlay Position.lua

If A MA > C MA Buy
If A MA < C MA Sell

if Buy and A < B Neutral
if Sell and A > B Neutral

Download links can be found here.
[download/file.php?id=13461](https://fxcodebase.com/code/download/file.php?id=13461)

Open Long on Up Trend Color
Open Short on Down Trend Color
Close (Optinal) on Neutral Trend Color

 [MA position Overlay Position Strategy.lua](files/98237/MA%20position%20Overlay%20Position%20Strategy.lua)

The Strategy was revised and updated on December 11, 2018.


---

## Re: MA position Overlay Position Strategy

**poriyavt** · Tue Jan 20, 2015 4:04 am

Dear Sir

 Thanks for This Strategy But There is a no option for neutral Close So Kindly add option

 for neutral Close

 Regards


---

## Re: MA position Overlay Position Strategy

**Apprentice** · Tue Jan 20, 2015 6:57 am

![CCC.png](images/98242/CCC.png)


---

## Can you make indicater as per below (Doda-EMA Indicator)

**poriyavt** · Tue Apr 14, 2015 3:54 am

//+------------------------------------------------------------------+
//| Doda-EMA.mq4 |
//| Copyright © 2010, Gopal Krishan Doda |
//| [http://www.DodaCharts.com](http://www.DodaCharts.com) |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2010, Gopal Krishan Doda"
#property link "http://www.DodaCharts.com"

#property indicator_chart_window
//+------------------------------------------------------------------+
//| Custom indicator initialization function |
//+------------------------------------------------------------------+

//extern int 0 = 0;

double myadxvalue;
double ema7, ema14, ema21;
string emaresult, emaresultexit;
bool EMABuyAlert=false, EMASellAlert=false, EMAExitLong=false, EMAExitShort=false, EMABuy = false, EMASell = false, EMABuyExit=False, EMASellExit=False;
double myatr, mystd,EMAtempvar,EMAtempvarexit;
string atrresult;
int counted_bars;
int ii;
int EMALastSignal;

double mainvar;
datetime adxtime;

int init()

 {
//---- indicators
//----
ObjectCreate("myema",OBJ_LABEL,0,0,0);
ObjectCreate("myemaexit",OBJ_LABEL,0,0,0);
ObjectCreate("mywebsite",OBJ_LABEL,0,0,0);
//ObjectCreate("myatr",OBJ_LABEL,0,0,0);

 return(0);
 }
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function |
//+------------------------------------------------------------------+
int deinit()
 {
//----
ObjectDelete("myema");
ObjectDelete("myemaexit");
ObjectDelete("mywebsite");
//ObjectDelete("myatr");
//----
 return(0);
 }
//+------------------------------------------------------------------+
//| Custom indicator iteration function |
//+------------------------------------------------------------------+
int start()
 {
 string MyMessage1 = Symbol()+" M"+Period();
 int counted_bars=IndicatorCounted();
//----

 counted_bars=IndicatorCounted();

 ii = Bars - 1;
 counted_bars = IndicatorCounted();
 if ( counted_bars > 1 )
 ii = Bars - counted_bars - 1;

 while ( ii >= 1 )
 {

 ema7 = iMA(NULL,0,7,0,MODE_EMA,PRICE_CLOSE,ii);
 ema14 = iMA(NULL,0,14,0,MODE_EMA,PRICE_CLOSE,ii);
 ema21 = iMA(NULL,0,21,0,MODE_EMA,PRICE_CLOSE,ii);

 //mainvar = iStochastic(NULL,PERIOD_M30,20,10,20,MODE_SMMA,1,MODE_SIGNAL,ii);

 if ( ema7 > ema14 && ema7 > ema21 && ema14 > ema21 && EMABuy==False )

 {

 emaresult = "Go Long @";
 EMAtempvar = iClose(NULL,0,ii);
 adxtime = iTime(NULL,0,ii);
 EMALastSignal = 1;

 EMABuy = True;
 EMASell = False;

 }

 ////

 /// when to exit long
 if ( ema14 > ema7 && ema14 > ema21 && ema21 > ema7 && EMABuyExit==False )
 {

 emaresultexit = "Exit long @";

 EMAtempvarexit = iClose(NULL,0,ii);

 EMALastSignal = 11;

 EMABuyExit = True;
 EMASellExit = False;

 }

 ///

// when to go short
 if ( ema21 > ema7 && ema21 > ema14 && ema14 > ema7 && EMASell==False )
 {

 emaresult = "Go Short @";

 EMAtempvar = iClose(NULL,0,ii);
 adxtime = iTime(NULL,0,ii);
 EMALastSignal = 2;

 EMASell = True;
 EMABuy = False;

 }

//

//when to exit short
 if ( ema7 > ema14 && ema7 < ema21 && EMASellExit==False )
 {

 emaresultexit = "Exit short @";

 EMAtempvarexit = iClose(NULL,0,ii);

 EMALastSignal = 22;

 EMASellExit = true;
 EMABuyExit = False;

 }

 ii--;
 } //end of while loop

 /// when to go long

if (EMALastSignal==1 && EMABuyAlert==false)
{
Alert(MyMessage1+" oda-EMA Says Buy"+" at "+DoubleToStr(EMAtempvar ,Digits));

 EMABuyAlert=true;
 EMASellAlert=false;
 EMAExitLong=false;
 EMAExitShort=false;

 }

if (EMALastSignal==11 && EMAExitLong==false)
{
Alert(MyMessage1+" oda-EMA Says Exit Buy"+" at "+DoubleToStr(EMAtempvarexit,Digits));

 EMABuyAlert=false;
 EMASellAlert=false;
 EMAExitLong=true;
 EMAExitShort=false;

 }

if (EMALastSignal==2 && EMASellAlert==false )
{
Alert(MyMessage1+" oda-EMA Says Sell"+" at "+DoubleToStr(EMAtempvar,Digits));

 EMABuyAlert=false;
 EMASellAlert=true;
 EMAExitLong=false;
 EMAExitShort=false;

 }

if (EMALastSignal==22 && EMAExitShort==false )
{
Alert(MyMessage1+" oda-EMA Says Exit Sell"+" at "+DoubleToStr(EMAtempvarexit,Digits));

 EMABuyAlert=false;
 EMASellAlert=false;
 EMAExitLong=false;
 EMAExitShort=true;

 }

if (EMALastSignal ==1)
{
ObjectSetText("myema",StringConcatenate("EMA: ", emaresult, " ", DoubleToStr(EMAtempvar ,Digits)," (", ((Close[0]-EMAtempvar)/Point)/10, ")" ), 10, "Arial", Green);

ObjectDelete("myHline3");
ObjectDelete("myVline3");
ObjectCreate("myHline3", OBJ_HLINE, 0, adxtime, EMAtempvar, 0, 0);
ObjectCreate("myVline3", OBJ_VLINE, 0, adxtime, EMAtempvar, 0, 0);
ObjectSet("myHline3", OBJPROP_COLOR, Lime);
ObjectSet("myVline3", OBJPROP_COLOR, Lime);
ObjectSet("myVline3", OBJPROP_STYLE, STYLE_DOT);
ObjectSet("myHline3", OBJPROP_STYLE, STYLE_DOT);

}

if (EMALastSignal ==2)
{
ObjectSetText("myema",StringConcatenate("EMA: ", emaresult, " ", DoubleToStr(EMAtempvar ,Digits)," (", ((EMAtempvar-Close[0])/Point)/10, ")" ), 10, "Arial", Red);

ObjectDelete("myHline3");
ObjectDelete("myVline3");
ObjectCreate("myHline3", OBJ_HLINE, 0, adxtime, EMAtempvar, 0, 0);
ObjectCreate("myVline3", OBJ_VLINE, 0, adxtime, EMAtempvar, 0, 0);
ObjectSet("myHline3", OBJPROP_COLOR, Red);
ObjectSet("myVline3", OBJPROP_COLOR, Red);
ObjectSet("myHline3", OBJPROP_STYLE, STYLE_DOT);
ObjectSet("myVline3", OBJPROP_STYLE, STYLE_DOT);

}

ObjectSet("myema",OBJPROP_XDISTANCE,2);
ObjectSet("myema",OBJPROP_YDISTANCE,68);
ObjectSet("myema", OBJPROP_CORNER, 3);

ObjectSetText("myemaexit",StringConcatenate("EMA: ", emaresultexit, " ", DoubleToStr(EMAtempvarexit ,Digits)), 10, "Arial", Indigo);
ObjectSet("myemaexit",OBJPROP_XDISTANCE,2);
ObjectSet("myemaexit",OBJPROP_YDISTANCE,86);
ObjectSet("myemaexit", OBJPROP_CORNER, 3);

ObjectSetText("mywebsite","Doda-EMA by [www.DodaCharts.com](http://www.DodaCharts.com)", 10, "Arial", Navy);
ObjectSet("mywebsite",OBJPROP_XDISTANCE,2);
ObjectSet("mywebsite",OBJPROP_YDISTANCE,104);
ObjectSet("mywebsite", OBJPROP_CORNER, 3);

//----
 return(0);
 }
//+------------------------------------------------------------------+


---

## Re: MA position Overlay Position Strategy

**Apprentice** · Sun Dec 11, 2016 3:09 pm

Strategy was revised and updated.

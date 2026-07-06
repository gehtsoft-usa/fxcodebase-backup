//+------------------------------------------------------------------+
//|                                              Set_Of_Averages.mq4 |
//|                               Copyright © 2012, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2012, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

#property indicator_chart_window

#property indicator_buffers 8
#property indicator_color1 Blue
#property indicator_color2 Red
#property indicator_color3 Green
#property indicator_color4 Navy
#property indicator_color5 Cyan
#property indicator_color6 Magenta
#property indicator_color7 Gold
#property indicator_color8 Tomato

extern int Method=0;  // Method of averages
extern int Price=0;   // Price type for averages
extern string Periods="10,20,30,40,50,60,70,80";

double MA1[], MA2[], MA3[], MA4[], MA5[], MA6[], MA7[], MA8[];

int MA_Periods[9];

void DecodePeriods()
{
 ArrayInitialize(MA_Periods,0);
 string Str=StringTrimLeft(StringTrimRight(Periods))+".";
 int Count=0;
 int Length=StringLen(Str);
 string Char;
 string TempStr="";
 int Num;
 for (int i=0;i<Length;i++)
 {
  Char=StringSubstr(Str,i,1);
  if (Char=="1" || Char=="2" || Char=="3" || Char=="4" || Char=="5" || Char=="6" || Char=="7" || Char=="8" || Char=="9" || Char=="0")
  {
   TempStr=TempStr+Char;
  }
  else
  {
   Num=StrToDouble(TempStr);
   if (Num>0)
   {
    Count++;
    MA_Periods[Count]=Num;
    if (Count>=8) break;
   }
   TempStr="";
  }
 }
 return;
}

int init()
  {
   IndicatorShortName("Set of averages");
   IndicatorDigits(Digits);
   SetIndexStyle(0,DRAW_LINE);
   SetIndexBuffer(0,MA1);
   SetIndexStyle(1,DRAW_LINE);
   SetIndexBuffer(1,MA2);
   SetIndexStyle(2,DRAW_LINE);
   SetIndexBuffer(2,MA3);
   SetIndexStyle(3,DRAW_LINE);
   SetIndexBuffer(3,MA4);
   SetIndexStyle(4,DRAW_LINE);
   SetIndexBuffer(4,MA5);
   SetIndexStyle(5,DRAW_LINE);
   SetIndexBuffer(5,MA6);
   SetIndexStyle(6,DRAW_LINE);
   SetIndexBuffer(6,MA7);
   SetIndexStyle(7,DRAW_LINE);
   SetIndexBuffer(7,MA8);
   DecodePeriods();
   return(0);
  }

int deinit()
  {

   return(0);
  }
  
void CalcMA(double &MA[], int Num, int pos)
{
 if (MA_Periods[Num]>0)
 {
  MA[pos]=iMA(NULL, 0, MA_Periods[Num], 0, Method, Price, pos);
 }
 else
 {
  MA[pos]=EMPTY_VALUE;
 }
 return;
}  

int start()
  {
   if(Bars<=3) return(0);
   int ExtCountedBars=IndicatorCounted();
   if (ExtCountedBars<0) return(-1);
   int    pos=Bars-2;
   if(ExtCountedBars>2) pos=Bars-ExtCountedBars-1;
   while(pos>=0)
   {
    CalcMA(MA1,1,pos);
    CalcMA(MA2,2,pos);
    CalcMA(MA3,3,pos);
    CalcMA(MA4,4,pos);
    CalcMA(MA5,5,pos);
    CalcMA(MA6,6,pos);
    CalcMA(MA7,7,pos);
    CalcMA(MA8,8,pos);
    pos--;
   } 

   return(0);
  }



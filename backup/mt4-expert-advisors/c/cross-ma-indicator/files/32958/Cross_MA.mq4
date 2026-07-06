//+------------------------------------------------------------------+
//|                                                     Cross_MA.mq4 |
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

extern int Method=0;
extern int Price=0;
extern string Periods="10,20,30,40,50,60,70";

double MA1[], MA2[], MA3[], MA4[], MA5[], MA6[], MA7[], Cross[];

int MA_Periods[8];

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
    if (Count>=7) break;
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
   SetIndexStyle(7,DRAW_ARROW);
   SetIndexBuffer(7,Cross);
   SetIndexArrow(7,108);
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

double GetPrice(int pos)
{
 if (Price==PRICE_CLOSE) return (Close[pos]);
 if (Price==PRICE_OPEN) return (Open[pos]);
 if (Price==PRICE_HIGH) return (High[pos]);
 if (Price==PRICE_LOW) return (Low[pos]);
 if (Price==PRICE_MEDIAN) return ((High[pos]+Low[pos])/2);
 if (Price==PRICE_TYPICAL) return ((High[pos]+Low[pos]+Close[pos])/3);
 return ((High[pos]+Low[pos]+2*Close[pos])/4);
}

int CheckMA(double MA[], int pos, double Pr, int Num)
{
 if (MA_Periods[Num]<=0) return (0);
 if (MA[pos]>Pr) return (1);
 if (MA[pos]<Pr) return (-1);
 return (-2);
}

int CheckBar(int bar)
{
 double Pr=GetPrice(bar);
 int Check1=CheckMA(MA1,bar,Pr,1);
 int Check2=CheckMA(MA2,bar,Pr,2);
 int Check3=CheckMA(MA3,bar,Pr,3);
 int Check4=CheckMA(MA4,bar,Pr,4);
 int Check5=CheckMA(MA5,bar,Pr,5);
 int Check6=CheckMA(MA6,bar,Pr,6);
 int Check7=CheckMA(MA7,bar,Pr,7);
 if (Check1>-1 && Check2>-1 && Check3>-1 && Check4>-1 && Check5>-1 && Check6>-1 && Check7>-1) return (1);
 if ((Check1==0 || Check1==-1) && (Check2==0 || Check2==-1) && (Check3==0 || Check3==-1) && (Check4==0 || Check4==-1) && (Check5==0 || Check5==-1) && (Check6==0 || Check6==-1) && (Check7==0 || Check7==-1)) return (-1);
 return (0);
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
    
    int Cross0=CheckBar(pos);
    int Cross1=CheckBar(pos+1);
    
    if (Cross0!=0 && Cross0!=Cross1) Cross[pos]=GetPrice(pos); else Cross[pos]=EMPTY_VALUE;

    pos--;
   } 

   return(0);
  }



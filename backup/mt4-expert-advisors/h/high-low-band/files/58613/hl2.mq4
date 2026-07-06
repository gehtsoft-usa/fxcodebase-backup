//+------------------------------------------------------------------+
//|                                                          hl2.mq4 |
//|                               Copyright © 2013, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2013, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

#property indicator_chart_window
#property indicator_buffers 2
#property indicator_color1 Yellow
#property indicator_color2 Yellow

extern string BarSize="D1";
extern bool Yesterday_Band=false;
extern bool Open_Close_Band=false;

double H[], L[];
int TF;

int getPeriod(string StrTF)
{
 string _StrTF=StringTrimLeft(StringTrimRight(StrTF));
 if (_StrTF=="m1" || _StrTF=="M1") return (1);
 if (_StrTF=="m5" || _StrTF=="M5") return (5);
 if (_StrTF=="m15" || _StrTF=="M15") return (15);
 if (_StrTF=="m30" || _StrTF=="M30") return (30);
 if (_StrTF=="h1" || _StrTF=="H1") return (60);
 if (_StrTF=="h4" || _StrTF=="H4") return (240);
 if (_StrTF=="d1" || _StrTF=="D1") return (1440);
 if (_StrTF=="w1" || _StrTF=="W1") return (10080);
 return (43200);
}  

int init()
  {
   IndicatorShortName("High/Low Bands");
   IndicatorDigits(Digits);
   SetIndexStyle(0,DRAW_LINE);
   SetIndexBuffer(0,H);
   SetIndexStyle(1,DRAW_LINE);
   SetIndexBuffer(1,L);
   TF=getPeriod(BarSize);
   return(0);
  }

int deinit()
  {

   return(0);
  }
  
int start()
{
 if(Bars<=2) return(0);
 int ExtCountedBars=IndicatorCounted();
 if (ExtCountedBars<0) return(-1);
 int pos;
 int limit=Bars-2;
 if(ExtCountedBars>2) limit=Bars-ExtCountedBars-1;
 pos=limit;
 double O, C;
 int bar;
 int i;
 while(pos>=0)
 {
  if (Yesterday_Band)
  {
   bar=iBarShift(NULL, TF, Time[pos], false);
   if (TimeDay(iTime(NULL, TF, bar))==TimeDay(Time[pos])) bar++;
   if (Open_Close_Band)
   {
    O=iOpen(NULL, TF, bar);
    C=iClose(NULL, TF, bar);
    H[pos]=MathMax(O, C);
    L[pos]=MathMin(O, C);
   }
   else
   {
    H[pos]=iHigh(NULL, TF, bar);
    L[pos]=iLow(NULL, TF, bar);
   }
  }
  else
  {
   bar=iBarShift(NULL, TF, Time[pos], true);
   if (bar!=-1)
   {
    if (Open_Close_Band)
    {
     O=iOpen(NULL, TF, bar);
     C=iClose(NULL, TF, bar);
     H[pos]=MathMax(O, C);
     L[pos]=MathMin(O, C);
    }
    else
    {
     H[pos]=iHigh(NULL, TF, bar);
     L[pos]=iLow(NULL, TF, bar);
    }
    if (H[pos]!=H[pos+1] || L[pos]!=L[pos+1])
    {
     i=pos+1;
     while (TimeDay(Time[i])==TimeDay(Time[pos]) && i<Bars)
     {
      H[i]=H[pos];
      L[i]=L[pos];
      i++;
     }
    }
   } 
  }
  
  pos--;
 }

 return(0);
}


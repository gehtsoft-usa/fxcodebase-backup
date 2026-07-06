// Id: 9690
//+------------------------------------------------------------------+
//|                                                   HL_MA_Band.mq4 |
//|                               Copyright � 2013, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
#property copyright "Copyright � 2013, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

#property indicator_chart_window
#property indicator_buffers 6
#property indicator_color1 Blue
#property indicator_color2 Red
#property indicator_color3 Yellow
#property indicator_color4 Magenta
#property indicator_color5 Green
#property indicator_color6 Salmon


extern int Length=15;
extern int Method=1;  // 0 - SMA
                      // 1 - EMA
                      // 2 - SMMA
                      // 3 - LWMA
double H[], L[], HistUp[], HistDn[], HistConstr[], HistExp[];

int init()
  {
       double temp = iCustom(NULL, 0, "LRL", 0, 0);
   if (GetLastError() == ERR_INDICATOR_CANNOT_LOAD)
   {
       Alert("Please, install the 'LRL' indicator");
       return INIT_FAILED;
   }
   IndicatorShortName("High/Low Linear regression band");
   IndicatorDigits(Digits);
   SetIndexStyle(0,DRAW_LINE);
   SetIndexBuffer(0,L);
   SetIndexStyle(1,DRAW_LINE);
   SetIndexBuffer(1,H);
   SetIndexStyle(2,DRAW_HISTOGRAM, STYLE_DOT);
   SetIndexBuffer(2,HistUp);
   SetIndexStyle(3,DRAW_HISTOGRAM, STYLE_DOT);
   SetIndexBuffer(3,HistDn);
   SetIndexStyle(4,DRAW_HISTOGRAM, STYLE_DOT);
   SetIndexBuffer(4,HistConstr);
   SetIndexStyle(5,DRAW_HISTOGRAM, STYLE_DOT);
   SetIndexBuffer(5,HistExp);

   return(0);
  }

int deinit()
  {

   return(0);
  }

int start()
{
 if(Bars<=Length) return(0);
 int ExtCountedBars=IndicatorCounted();
 if (ExtCountedBars<0) return(-1);
 int pos;
 int limit=Bars-2;
 if(ExtCountedBars>2) limit=Bars-ExtCountedBars-1;
 pos=limit;
 while(pos>=0)
 {
  H[pos]=iCustom(NULL, 0, "LRL", Length, PRICE_HIGH, 0, pos);
  L[pos]=iCustom(NULL, 0, "LRL", Length, PRICE_LOW, 0, pos);
  HistUp[pos]=L[pos];
  HistDn[pos]=L[pos];
  HistConstr[pos]=L[pos];
  HistExp[pos]=L[pos];
  if (H[pos]>H[pos+1])
  {
   if (L[pos]>L[pos+1])
   {
    HistUp[pos]=H[pos];
   }
   else
   {
    HistExp[pos]=H[pos];
   }
  }
  else
  {
   if (L[pos]>L[pos+1])
   {
    HistConstr[pos]=H[pos];
   }
   else
   {
    HistDn[pos]=H[pos];
   }
  }
  pos--;
 } 
 return(0);
}


//+------------------------------------------------------------------+
//|                               Copyright © 2017, Gehtsoft USA LLC | 
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
//|                         Donate / Support:  https://goo.gl/9Rj74e |
//|                     BitCoin: 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  | 
//+------------------------------------------------------------------+
//|                                      Developed by : Mario Jemic  |                    
//|                                          mario.jemic@gmail.com   |
//+------------------------------------------------------------------+

#property copyright "Copyright © 2017, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"


#property indicator_chart_window

#property indicator_buffers 6
#property indicator_color2 Red
#property indicator_color3 Green
#property indicator_color4 Yellow
#property indicator_color5 Cyan
#property indicator_color6 Magenta

extern int Length=20;
extern double Deviation=2;

double UpperCloudBuff[], MiddleCloudBuff[], LowerCloudBuff[], UpperBuff[], MiddleBuff[], LowerBuff[];

int init()
  {
   IndicatorShortName("BB with color zones");
   IndicatorDigits(Digits);
   SetIndexStyle(0,DRAW_HISTOGRAM);
   SetIndexBuffer(0,LowerCloudBuff);
   SetIndexStyle(1,DRAW_HISTOGRAM);
   SetIndexBuffer(1,UpperCloudBuff);
   SetIndexStyle(2,DRAW_HISTOGRAM);
   SetIndexBuffer(2,MiddleCloudBuff);
   SetIndexStyle(3,DRAW_LINE);
   SetIndexBuffer(3,LowerBuff);
   SetIndexStyle(4,DRAW_LINE);
   SetIndexBuffer(4,MiddleBuff);
   SetIndexStyle(5,DRAW_LINE);
   SetIndexBuffer(5,UpperBuff);
   return(0);
  }

int deinit()
  {

   return(0);
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
    UpperBuff[pos]=iBands(NULL, 0, Length, Deviation, 0, PRICE_CLOSE, MODE_UPPER, pos); 
    LowerBuff[pos]=iBands(NULL, 0, Length, Deviation, 0, PRICE_CLOSE, MODE_LOWER, pos); 
    MiddleBuff[pos]=(UpperBuff[pos]+LowerBuff[pos])/2;
    UpperCloudBuff[pos]=UpperBuff[pos]; 
    MiddleCloudBuff[pos]=MiddleBuff[pos]; 
    LowerCloudBuff[pos]=LowerBuff[pos];
    pos--;
   } 
   return(0);
  }


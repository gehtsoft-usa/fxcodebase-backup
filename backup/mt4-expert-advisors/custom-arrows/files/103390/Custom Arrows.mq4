//+------------------------------------------------------------------+
//|                                                Custom Arrows.mq4 |
//|                               Copyright © 2015, Gehtsoft USA LLC | 
//|                                            http://fxcodebase.com |
//|                         Donate / Support:  http://goo.gl/cEP5h5  | 
//+------------------------------------------------------------------+
//|                                      Developed by : Mario Jemic  |                    
//|                                          mario.jemic@gmail.com   |
//|                     BitCoin: 1MfUHS3h86MBTeonJzWdszdzF2iuKESCKU  |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2012, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

#property indicator_chart_window

#property indicator_buffers 2
#property indicator_color1 Red
#property indicator_color2 Blue
#property indicator_color2 Blue 
extern int Arrow_Size=10; 

double   UP[], DN[];

int init()
  {
   IndicatorShortName("Custom Arrows");
   IndicatorDigits(Digits);
   SetIndexStyle(0,DRAW_ARROW,0,Arrow_Size);
   SetIndexBuffer(0,UP);
   SetIndexArrow(0,233);
  
   SetIndexStyle(1,DRAW_ARROW,0,Arrow_Size);
   SetIndexStyle(1,DRAW_ARROW);
   SetIndexBuffer(1,DN);
   SetIndexArrow(1,234);
 
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
   
    if((High[pos+7] < High[pos+9])
    && (Low[pos+3] < Low[pos+4])
    && (Close[pos+6] < Close[pos+1])
    && (Close[pos+1] < Open[pos+0])) 
    {
     UP[pos]=Low[pos];
    }
    else
    {
     UP[pos]=EMPTY_VALUE;
    }
	
    if((High[pos+7] > High[pos+9])
    && (Low[pos+3] > Low[pos+4])
    && (Close[pos+6] > Close[pos+1])
    && (Close[pos+1]  > Open[pos+0]))
    {
     DN[pos]=High[pos];
    }
    else
    {
     DN[pos]=EMPTY_VALUE;
    }
    pos--;
   }

   return(0);
  }



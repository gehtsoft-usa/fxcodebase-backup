//+------------------------------------------------------------------+
//|                                                     BB_Cloud.mq4 |
//|                               Copyright © 2012, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2012, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

#property indicator_chart_window

#property indicator_buffers 9

#property indicator_color1 Red
#property indicator_color2 Red
#property indicator_color3 Green
#property indicator_color4 Green
#property indicator_color5 Yellow
#property indicator_color6 Blue
#property indicator_color7 Blue
#property indicator_color8 Blue
#property indicator_color9 Blue
  

extern int Length=20;
extern double Deviation1=2;
extern double Deviation2=3;
double  MiddleBuff[];
double UpperCloudBuff1[], LowerCloudBuff1[];
double UpperCloudBuff2[], LowerCloudBuff2[] ;
double UpperBuff1[], LowerBuff1[];
double UpperBuff2[], LowerBuff2[] ;
 

int init()
  {
   IndicatorShortName("Double Bollinger Band");
   IndicatorDigits(Digits);
   
   
   SetIndexStyle(0,DRAW_HISTOGRAM);
   SetIndexBuffer(0,UpperBuff1);
   SetIndexLabel(0,"Up Cloud");
   
   SetIndexStyle(1,DRAW_HISTOGRAM);
   SetIndexBuffer(1,UpperBuff2);
   SetIndexLabel(1,"Up Cloud");
   
   
    SetIndexStyle(2,DRAW_HISTOGRAM);
   SetIndexBuffer(2,LowerBuff1);
   SetIndexLabel(2,"Down Cloud");
   
   SetIndexStyle(3,DRAW_HISTOGRAM);
   SetIndexBuffer(3,LowerBuff2);
   SetIndexLabel(3,"Down Cloud");
   
 
   SetIndexBuffer(4,MiddleBuff);
   SetIndexStyle(4,DRAW_LINE);
   
   SetIndexBuffer(5,UpperCloudBuff1);
   SetIndexStyle(5,DRAW_LINE);
   SetIndexBuffer(6,LowerCloudBuff1);
   SetIndexStyle(6,DRAW_LINE);
   
    SetIndexBuffer(7,UpperCloudBuff2);
   SetIndexStyle(7,DRAW_LINE);
   SetIndexBuffer(8,LowerCloudBuff2);
   SetIndexStyle(8,DRAW_LINE);
   
   

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
    UpperCloudBuff1[pos]=iBands(NULL, 0, Length, Deviation1, 0, PRICE_CLOSE, MODE_UPPER, pos); 
    LowerCloudBuff1[pos]=iBands(NULL, 0, Length, Deviation1, 0, PRICE_CLOSE, MODE_LOWER, pos);
    UpperCloudBuff2[pos]=iBands(NULL, 0, Length, Deviation2, 0, PRICE_CLOSE, MODE_UPPER, pos); 
    LowerCloudBuff2[pos]=iBands(NULL, 0, Length, Deviation2, 0, PRICE_CLOSE, MODE_LOWER, pos);
	
    MiddleBuff[pos]=(UpperCloudBuff1[pos]+LowerCloudBuff1[pos])/2;
	
    UpperBuff1[pos]= MathMin( UpperCloudBuff1[pos], UpperCloudBuff2[pos]); 	
	UpperBuff2[pos]= MathMax( UpperCloudBuff1[pos], UpperCloudBuff2[pos]); 	
	
	LowerBuff2[pos]=MathMin( LowerCloudBuff1[pos], LowerCloudBuff2[pos]); 	
	LowerBuff1[pos]=MathMax( LowerCloudBuff1[pos], LowerCloudBuff2[pos]); 	
    
    pos--;
   } 
   return(0);
  }


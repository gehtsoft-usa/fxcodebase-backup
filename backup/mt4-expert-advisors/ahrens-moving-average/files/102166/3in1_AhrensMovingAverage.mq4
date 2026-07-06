//+------------------------------------------------------------------+
//|                                        AhrensMovingAverage_3.mq4 |
//|                             Copyright (c) 2016, Gehtsoft USA LLC | 
//|                                            http://fxcodebase.com |
//|                         Donate / Support:  http://goo.gl/cEP5h5  | 
//+------------------------------------------------------------------+
//|                                      Developed by : Mario Jemic  |                    
//|                                          mario.jemic@gmail.com   |
//|                     BitCoin: 1MfUHS3h86MBTeonJzWdszdzF2iuKESCKU  |
//+------------------------------------------------------------------+

#property copyright "Copyright (c) 2016, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"
#property version "1.0"


#property indicator_buffers 3
#property indicator_chart_window
#property indicator_color1 clrRed
#property indicator_color2 clrBlue
#property indicator_color3 clrGreen

//--- input parameters
extern int   Period1 = 8;
extern color Color1  = clrRed;
extern int   Style1  = STYLE_SOLID;
extern int   Width1  = 0;
extern int   Period2 = 20;
extern color Color2  = clrBlue;
extern int   Style2  = STYLE_SOLID;
extern int   Width2  = 0;
extern int   Period3 = 34;
extern color Color3  = clrGreen;
extern int   Style3  = STYLE_SOLID;
extern int   Width3  = 0;

double AMA1[];
double AMA2[];
double AMA3[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
//---- indicators

  IndicatorShortName("AhrensMovingAverage_3");
  IndicatorDigits(Digits);
  
  IndicatorBuffers(0);
  SetIndexBuffer(0,AMA1);
  SetIndexStyle(0,DRAW_LINE,Style1,Width1,Color1); 
  SetIndexBuffer(1,AMA2);
  SetIndexStyle(1,DRAW_LINE,Style2,Width2,Color2); 
  SetIndexBuffer(2,AMA3);
  SetIndexStyle(2,DRAW_LINE,Style3,Width3,Color3); 
  
  
  
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
int deinit()
  {
//----
    ObjectsDeleteAll();
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int start(){
  
   int ExtCountedBars=IndicatorCounted();
   if (ExtCountedBars<0) return(0);
	 
   int    limit=Bars;
   
//----
   if (limit<Period1) return(0);	
   
   int i;
   double MedianPrice;
   double MedianMA1, MedianMA2, MedianMA3;
   
   for( i=limit; i>=0; i--){
   
      MedianPrice = (High[i] + Low[i]) / 2;
      MedianMA1=(AMA1[i+1]+AMA1[i+Period1])/2; 
      MedianMA2=(AMA2[i+1]+AMA2[i+Period2])/2; 
      MedianMA3=(AMA3[i+1]+AMA3[i+Period3])/2; 
      
      AMA1[i]=  AMA1[i+1]+((MedianPrice-MedianMA1)/Period1);
      AMA2[i]=  AMA2[i+1]+((MedianPrice-MedianMA2)/Period2);
      AMA3[i]=  AMA3[i+1]+((MedianPrice-MedianMA3)/Period3);
   
   }
   
   return(0);
}
//+------------------------------------------------------------------+
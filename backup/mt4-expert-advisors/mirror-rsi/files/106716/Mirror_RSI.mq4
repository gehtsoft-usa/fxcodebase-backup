//+------------------------------------------------------------------+
//|                               Copyright © 2016, Gehtsoft USA LLC | 
//|                                            http://fxcodebase.com |
//|                         Donate / Support:  http://goo.gl/cEP5h5  | 
//+------------------------------------------------------------------+
//|                                      Developed by : Mario Jemic  |                    
//|                                          mario.jemic@gmail.com   |
//|                     BitCoin: 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |
//+------------------------------------------------------------------+

#property copyright "Copyright © 2016, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

#property indicator_separate_window
#property indicator_buffers 3
#property indicator_color1 Red
#property indicator_color2 Blue
#property indicator_color3 Yellow

extern string  Comment1 = "- Applied price 0 - Close   / 1 - Open / 2 - High / 3 - Low / 4 - Median / 5 - Typical / 6 - Weighted -";
extern int Price1=0; 
extern int Length1=20; 

extern string  Comment2 = "- Applied price 0 - Close   / 1 - Open / 2 - High / 3 - Low / 4 - Median / 5 - Typical / 6 - Weighted -";
extern int Price2=1;   
extern int Length2=20;                      


//extern string  Comment3         = "- Methods: 0=SMA 1=EMA 2=SMMA 3=LWMA 4=DEMA 5=TEMA -";
extern int     Signal_Method    = 0;
extern int     Signal_Period    = 20;



double Buff1[];
double Buff2[];
double Buff3[];
 

int init()
{
 IndicatorBuffers(3);
 IndicatorShortName("Mirror_RSI");
 IndicatorDigits(Digits);
 SetIndexStyle(0,DRAW_LINE);
 SetIndexBuffer(0,Buff1);
 SetIndexStyle(1,DRAW_LINE);
 SetIndexBuffer(1,Buff2);
 SetIndexStyle(2,DRAW_LINE);
 SetIndexBuffer(2,Buff3);
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
 int limit=Bars-2;
 if(ExtCountedBars>2) limit=Bars-ExtCountedBars-1;
 int pos;
 pos=limit;
 
 double RSI1;
 double RSI2;
 while(pos>=0)
 {
   RSI1= iRSI(NULL,0,Length1,Price1,pos);
   RSI2= iRSI(NULL,0,Length2,Price2,pos);
   Buff1[pos]=RSI1-RSI2;  
   Buff2[pos]=RSI2-RSI1;
  pos--;
 } 
 
 
 pos=limit;

 while(pos>=0)
 {
 
   Buff3[pos]=iMAOnArray(Buff1,0,Signal_Period,0,Signal_Method,pos);
  pos--;
 } 
 
   
 return(0);
}


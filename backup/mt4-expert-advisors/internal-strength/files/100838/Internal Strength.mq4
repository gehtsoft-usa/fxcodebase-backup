//+------------------------------------------------------------------+
//|                                            Internal Strength.mq4 |
//|                               Copyright © 2015, Gehtsoft USA LLC | 
//|                                            http://fxcodebase.com |
//|                         Donate / Support:  http://goo.gl/cEP5h5  | 
//+------------------------------------------------------------------+
//|                                      Developed by : Mario Jemic  |                    
//|                                          mario.jemic@gmail.com   |
//|------------------------------------------------------------------|
//|                                     Paypal: http://goo.gl/cEP5h5 |
//|                     BitCoin: 1MfUHS3h86MBTeonJzWdszdzF2iuKESCKU  |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2015, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

#property indicator_separate_window
#property indicator_buffers 1
#property indicator_color1 Green


extern int Period=14;
extern int Method=1;

extern double Overbought=55;
extern double Oversold=45;
 
double Data[];
double Raw[];

int init()
{
 IndicatorShortName("Internal Strength");
 IndicatorDigits(Digits);
 
 
   if(! ((Method >= 1 && Method <= 2  )  )) 
   {
   Alert("Permitted Methods are 1 and 2");

   return(-1);
   }
  
   if (Method== 2)
   { 
   IndicatorBuffers(2);
   }
   else
   {
   IndicatorBuffers(1);
   }
   
   
   SetIndexStyle(0,DRAW_LINE);
   SetIndexBuffer(0,Data); 
   
   if (Method== 2)
   {
    SetIndexBuffer(1, Raw);
    SetIndexStyle(1,DRAW_NONE); 
   
    SetLevelValue(1, Overbought);
    SetLevelValue(2, 50);
    SetLevelValue(3, Oversold);   
   }
   else
   {
    SetLevelValue(1, Overbought/100);
    SetLevelValue(2, 50/100);
    SetLevelValue(3, Oversold/100); 
   }
  
   
  
   
 
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
		 while(pos>=0)
		 {
		 

		   
				 if (Method== 2)
				 {
				 Raw[pos]=(Close[pos]-Low[pos]) / (High[pos] -Low[pos]);
				 Data[pos]=iRSIOnArray(Raw,0,Period,pos);
				 }
				 else
				 {
				 Data[pos]=(Close[pos]-Low[pos]) / (High[pos] -Low[pos]);
				 }
 
          pos--;
         } 
 return(0);
}


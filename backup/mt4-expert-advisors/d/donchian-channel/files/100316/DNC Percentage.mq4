//+------------------------------------------------------------------+
//|                                               DNC Percentage.mq4 |
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
#property indicator_buffers 1
#property indicator_separate_window
#property indicator_color1 Green
 

extern int Look_Back_Length=20;
extern bool Analyze_Current_Period=true;


double Up[], Dn[] , Percentage[];

int init()
{
 IndicatorShortName("DNC Percentage");
 IndicatorDigits(Digits);
 IndicatorBuffers(3);
 
 SetIndexStyle(0,DRAW_LINE);
 SetIndexBuffer(0,Percentage);
 SetIndexStyle(1,DRAW_NONE);
 SetIndexBuffer(1,Up);
 SetIndexStyle(2,DRAW_NONE);
 SetIndexBuffer(2,Dn);
 SetLevelValue(1, 100);
 SetLevelValue(2, 50);
 SetLevelValue(3, 0);

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
 
	  if (Analyze_Current_Period) 
	  {
	  Up[pos]=High[iHighest(NULL, 0, MODE_HIGH, Look_Back_Length, pos)];
	  Dn[pos]=Low[iLowest(NULL, 0, MODE_LOW, Look_Back_Length, pos)]; 
	  }
	  else
	  {
	   Up[pos]=High[iHighest(NULL, 0, MODE_HIGH, Look_Back_Length, pos+1)];
	  Dn[pos]=Low[iLowest(NULL, 0, MODE_LOW, Look_Back_Length, pos+1)]; 
	  }
      
	  Percentage [pos] = ((Close[pos] -  Dn[pos])/(Up[pos]-Dn[pos]))*100;
  pos--;
 } 
 return(0);
}


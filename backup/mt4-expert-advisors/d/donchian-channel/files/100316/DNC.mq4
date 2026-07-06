//+------------------------------------------------------------------+
//|                                                          DNC.mq4 |
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

#property indicator_chart_window
#property indicator_buffers 3
#property indicator_color1 Green
#property indicator_color2 Red
#property indicator_color3 Blue

extern int Look_Back_Length=20;
extern bool Analyze_Current_Period=true;
extern bool Show_Middle_Line=true;


double Up[], Dn[], Mid[];

int init()
{
 IndicatorShortName("DNC");
 IndicatorDigits(Digits);
 SetIndexStyle(0,DRAW_LINE);
 SetIndexBuffer(0,Up);
 SetIndexStyle(1,DRAW_LINE);
 SetIndexBuffer(1,Dn);
  SetIndexStyle(2,DRAW_LINE);
 SetIndexBuffer(2,Mid);

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
  if (Show_Middle_Line)
  {
  Mid[pos]= (Up[pos]+Dn[pos])/2;
  }
  pos--;
 } 
 return(0);
}


//+------------------------------------------------------------------+
//|                                               Speed of trade.mq4 |
//|                               Copyright © 2012, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2012, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

#property indicator_chart_window

#property indicator_buffers 2
#property indicator_color1 Red
#property indicator_color2 Blue

extern int Period=14; 
extern double Multiplier=2; 
 

double Up[];
double Down[];
double SOD[];
double AVG[];
 

 
int init()
  {
   IndicatorShortName("Speed of trade");
   
     IndicatorBuffers(4); 
    SetIndexBuffer(0,Up);
    SetIndexBuffer(1,Down);   
    SetIndexStyle(0,DRAW_ARROW,0,4);
    SetIndexArrow(0,119);
    SetIndexStyle(1,DRAW_ARROW,0,4);
    SetIndexArrow(1,119);
    SetIndexEmptyValue(0,0.0);
    SetIndexEmptyValue(1,0.0);
    SetIndexLabel(0,"Up");
    SetIndexLabel(1,"Down");
	 
  
   SetIndexBuffer(2,SOD);
   SetIndexBuffer(3,AVG);
   return(0);
  }

int deinit()
  {

   return(0);
  }

int start()
{

 int ExtCountedBars=IndicatorCounted();
 if (ExtCountedBars<0) return(-1);
 int pos; 
 int limit=Bars-2;
 if(ExtCountedBars>2) limit=Bars-ExtCountedBars-1;
 limit=MathMax(limit,Period);
 
 pos=limit;
 
 while(pos>=0)
 {
 
 SOD[pos]=((Close[pos]-Open[pos])/Volume[pos])*1000000000;
 pos--;
 }
 
 
 pos=limit;
 
 while(pos-Period>=0)
 {
 
 AVG[pos]=iMAOnArray(SOD,0,Period,0,0,pos)*Multiplier;
 pos--;
 }
 
 
 pos=limit;
 
 while(pos-Period>=0)
 {
 
 
 
 
   if (SOD[pos]  <	AVG[pos])
   {
    Up [pos]=EMPTY;
    Down [pos]=EMPTY;
   }
   else
   {
         if (Close[pos]  > Open[pos])
		 {
         Up [pos]=EMPTY;
         Down [pos]=High[pos];
		 }
		 if (Close[pos]  < Open[pos])
		 {
		 Up [pos]=Low[pos];
         Down [pos]=EMPTY;
		 }
   }	
   
  
   
    
  
  pos--;
 } 

 return(0);
}


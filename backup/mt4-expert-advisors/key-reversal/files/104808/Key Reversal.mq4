//+------------------------------------------------------------------+
//|                               Copyright © 2016, Gehtsoft USA LLC | 
//|                                            http://fxcodebase.com |
//|                         Donate / Support:  http://goo.gl/cEP5h5  | 
//+------------------------------------------------------------------+
//|                                      Developed by : Mario Jemic  |                    
//|                                          mario.jemic@gmail.com   |
//|                     BitCoin: 1MfUHS3h86MBTeonJzWdszdzF2iuKESCKU  |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2016, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

#property indicator_chart_window

#property indicator_buffers 2
#property indicator_color1 Red
#property indicator_color2 Blue
 
extern int LabelSize=10; 
extern bool Use_Trend_Filter=1; 
extern int Trend_Period=2; 
double   UP[], DN[];

 
int init()
  {
   IndicatorShortName("Key Reversal");
   IndicatorDigits(Digits);  
   SetIndexStyle(0,DRAW_ARROW, 0, LabelSize);
   SetIndexBuffer(0,UP);
   SetIndexArrow(0,233);
 
   SetIndexStyle(1,DRAW_ARROW, 0, LabelSize);
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
	
            double Range= (High[pos]-Low[pos])/2;
			
         	if (Verification(pos) == 1) 
			{
			 UP[pos]=Low[pos]-Range;
			}
			else
			{
			 UP[pos]=EMPTY_VALUE;
			}
			
			if (Verification(pos) == -1)
			{
			 DN[pos]=High[pos]+Range;
			}
			else
			{
			 DN[pos]=EMPTY_VALUE;
			}
    pos--;
   }

   return(0);
  }
  
  
   
int Verification(int pos)

{
  
  int Signal=0;
  
  if  (Close[pos]> High[pos+1])
  {
  Signal=1;
  }
  
  if ( Close[pos]< Low[pos+1])
  {
  Signal=-1;
  }   
  
  if (  Use_Trend_Filter== 0 )
  {
  return (Signal);
  }
  
  int Test=0;

 
  for (int i= 1; i<=Trend_Period; i++ )
  {
  
      Test=0;
	  
	  if (Close[pos+i] > Open[pos+i]) 
	  {
	  Test=1;  
	  }
	  
	  if (Close[pos+i] < Open[pos+i]) 
	  {
	  Test=-1;  
	  }
  
  
	  if (Signal == 1 && Test == 1 )
	  {
      Signal=0;
	  break;
	  }
	  
	  if (Signal == -1 && Test == -1)
	  {
	  Signal=0;
	  break;
	  }
  }
  
  
  
  return (Signal);
  
}



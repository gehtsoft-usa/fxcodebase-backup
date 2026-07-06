// More information about this indicator can be found at:
// http://fxcodebase.com/code/viewtopic.php?f=38&t=69961


//+------------------------------------------------------------------+
//|                               Copyright © 2020, Gehtsoft USA LLC | 
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
//|                                 Support our efforts by donating  | 
//|                                    Paypal: https://goo.gl/9Rj74e |
//+------------------------------------------------------------------+
//|                                      Developed by : Mario Jemic  |                    
//|                                          mario.jemic@gmail.com   |
//|                           https://AppliedMachineLearning.systems |
//|                                Patreon :  https://goo.gl/GdXWeN  |  
//+------------------------------------------------------------------+




#property copyright "Copyright © 2020, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"


#property version "1.0"
#property indicator_separate_window

#property indicator_minimum -100
#property indicator_maximum 0

#property indicator_buffers 2

#property indicator_color1 Red
#property indicator_color2 Green
#property indicator_levelcolor clrYellow

#property indicator_level1 -20
#property indicator_level2 -80
extern int WRP_Period=14;

enum e_method{ SMA = 1, EMA = 2, SMMA = 3, LWMA = 4 };          
extern e_method MA_Method_Selected  = SMA;
extern int MA_Period=14;


double WPR[];
double MA[];  
  
  
int init()
  {
 
   SetIndexBuffer(0,WPR);
   SetIndexStyle(0,DRAW_LINE);
   
   SetIndexBuffer(1,MA);
   SetIndexStyle(1,DRAW_LINE);   

   IndicatorShortName("%R("+WRP_Period+","+MA_Period+")");
   
   SetIndexLabel(0,"WPR");
   SetIndexDrawBegin(0,WRP_Period);
   
   SetIndexLabel(1,"MA");
   SetIndexDrawBegin(1,WRP_Period+MA_Period);
   
   SetLevelValue(0,indicator_level1);
   SetLevelValue(1,indicator_level2);

   return(0);
  }



int start()
  {
   int i,CountedBar;  


   if(Bars<=WRP_Period) return(0);


   CountedBar=IndicatorCounted();


   i=Bars-WRP_Period-1;
   if(CountedBar>WRP_Period) 
      i=Bars-CountedBar-1;  
   while(i>=0)
     {
      double dMaxHigh=High[Highest(NULL,0,MODE_HIGH,WRP_Period,i)];
      double dMinLow=Low[Lowest(NULL,0,MODE_LOW,WRP_Period,i)];      
      WPR[i]=-100*(dMaxHigh-Close[i])/(dMaxHigh-dMinLow);
	  
	  MA[i] = iMAOnArray(WPR,0,MA_Period,0, MA_Method_Selected-1,i);

      i--;
     }


   return(0);
  }

 
 
 
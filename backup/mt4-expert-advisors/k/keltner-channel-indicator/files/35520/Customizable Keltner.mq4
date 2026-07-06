//+------------------------------------------------------------------+
//|                                        Customizable Keltner.mq4  |
//|                               Copyright © 2015, Gehtsoft USA LLC | 
//|                                            http://fxcodebase.com |
//|                         Donate / Support:  http://goo.gl/cEP5h5  | 
//+------------------------------------------------------------------+
//|                                      Developed by : Mario Jemic  |                    
//|                                          mario.jemic@gmail.com   |
//|                     BitCoin: 1MfUHS3h86MBTeonJzWdszdzF2iuKESCKU  |
//+------------------------------------------------------------------+

#property copyright "Copyright © 2015, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

#property indicator_chart_window

#property indicator_buffers 3
#property indicator_color1 Red
#property indicator_color2 Blue
#property indicator_color3 Green
 

extern int NM=50;               // Number of the periods to smooth the center line
extern int NB=50;               // Number of periods to smooth deviation
extern double F=1;              // Factor which is used to apply the deviation
extern int SRC=0;               // The center line source
                                // 0 - Close
                                // 1 - Open
                                // 2 - High
                                // 3 - Low
                                // 4 - Median, (High+Low)/2
                                // 5 - Typical, (High+Low+Close)/3
                                // 6 - Weighted, (High+Low+Close+Close)/4
                                
extern int Method=0;            // The center line smoothing method
                                // 0 - Simple
                                // 1 - Exponential
                                // 2 - Smoothed
                                // 3 - Linear weighted
								
extern int VariationMethod=0;
                           	    // Variation Method                          
                                // 0 - Smoothed H-L
                                // 1 - ATR of source           					

double UpperBuff[], MiddleBuff[], LowerBuff[];
double VMI[];
int init()
  {
   IndicatorShortName("Keltner with color zones");
   IndicatorDigits(Digits);
   
   if(! (SRC >= 0 && SRC <= 6  )  ) 
   {
   Alert("Permitted Price_Modes are between 0 and 6");

   return(-1);
   }
   
   if(! (Method >= 0 && Method <= 3  )  ) 
   {
   Alert("Permitted Line smoothing method are between 0 and 3");

   return(-1);
   }
   
    if(! (VariationMethod >= 0 && VariationMethod <= 1  )  ) 
   {
   Alert("Permitted Variation Method are 0 and 1");

   return(-1);
   }
 
   IndicatorBuffers(4);
   SetIndexStyle(0,DRAW_LINE);
   SetIndexBuffer(0,LowerBuff);
   SetIndexStyle(1,DRAW_LINE);
   SetIndexBuffer(1,MiddleBuff);
   SetIndexStyle(2,DRAW_LINE);
   SetIndexBuffer(2,UpperBuff);
   SetIndexStyle(3,DRAW_NONE);
   SetIndexBuffer(3,VMI);
   
   return(0);
  }

int deinit()
  {

   return(0);
  }

int start()
  {
   double v;
   if(Bars<=3) return(0);
   int ExtCountedBars=IndicatorCounted();
   if (ExtCountedBars<0) return(-1);
   int    pos=Bars-2;
   if(ExtCountedBars>2) pos=Bars-ExtCountedBars-1;
   while(pos>=0)
   {
    MiddleBuff[pos]=iMA(NULL, 0, NM, 0, Method, SRC, pos);
    
	if (VariationMethod== 0)
    {
	VMI[pos]= High[pos]-Low[pos];
    }    
    
    pos--;
   } 
   
   
   pos=Bars-2-NB;
   if(ExtCountedBars>2) pos=Bars-ExtCountedBars-1;
    while(pos>=0)
	       {
			  if (VariationMethod== 0)
			{			
			v=iMAOnArray(VMI,0,NB,0,Method,pos);
			}
			else 	
			{
			v=iATR(NULL, 0, NB, pos);
			}
			
			UpperBuff[pos]=MiddleBuff[pos]+v*F;
			
			LowerBuff[pos]=MiddleBuff[pos]-v*F;
			pos--;
		   } 
   return(0);
  }


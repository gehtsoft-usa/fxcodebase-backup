//+------------------------------------------------------------------+
//|                                                          BBW.mq4 |
//|                               Copyright © 2012, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2012, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

#property indicator_separate_window
#property indicator_buffers 4
#property indicator_color1 Green
#property indicator_color2 Red
#property indicator_color3 Blue
#property indicator_color4 Lime

double TL[];
double BL[];
double CL[];
double BBW[];
 
extern int Period=20;
extern int Mode=0;
extern double Multiplier=2; 
 

int init()
  {
   IndicatorBuffers(4);
   IndicatorShortName("BBW");
   IndicatorDigits(Digits);
   SetIndexStyle(0,DRAW_LINE);
   SetIndexBuffer(0,TL);
    SetIndexStyle(1,DRAW_LINE);
   SetIndexBuffer(1,BL);     
    SetIndexStyle(2,DRAW_LINE);
   SetIndexBuffer(2,CL);  
    SetIndexStyle(3,DRAW_LINE);
   SetIndexBuffer(3,BBW);  
 
  
 
   
   if(! (Mode >= 0 && Mode <= 3  )  ) 
   {
   Alert("Permitted Modes are between 0 and 3");

   return(-1);
   }
   
   
   return(0);
  }

int deinit()
  {
   return(0);
  }

int start()
 {
  double BarsToCount = 0;
   int bars_counted = IndicatorCounted();
   if(bars_counted < 0)
   {
      return(1);
   }
   else if(bars_counted > 0) 
   {
      bars_counted--;
   }
   int limit = Bars - bars_counted;
   if(BarsToCount>0 && limit>BarsToCount) 
   {
      limit = BarsToCount;
   }
    
	double iTL;
	double iBL;
	double iCL;
	double id;
   for(int i=limit; i>=0; i--)
   {
 
		  iTL =iBands(NULL,0,Period,Multiplier,0,0,1,i);
		  iBL =iBands(NULL,0,Period,Multiplier,0,0,2,i);
		  iCL =iBands(NULL,0,Period,Multiplier,0,0,0,i);
		  id = iTL-iCL;
		  
		  if ((iTL - iBL) !=0)   BBW[i] = ((Close[i] - iBL) / (iTL - iBL)) * 100; 
			
  } 
  
  double sDev;
  
  for(int j=limit; j>=0; j--)
   {
   CL[j]= iMAOnArray(BBW,0,Period,0,Mode,j);   
   sDev   = iStdDevOnArray(BBW, 0, Period, Mode, 0, j);  
   
       TL[j] = CL[j] + (Multiplier * sDev);
       BL[j] = CL[j] - (Multiplier * sDev);
   }
   
  
 return(0);
}


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
#property indicator_color1 Blue
#property indicator_color2 Green
#property indicator_color3 Red

 
extern int CalculationPeriod=14;
extern bool Smoothing = true;
extern int PriceType=0;

double ADX[];
double UP[];
double DOWN[];

int init()
  {
   IndicatorBuffers(3);
   IndicatorShortName("DMI ADX Filter");
   IndicatorDigits(Digits);
   SetIndexStyle(0,DRAW_LINE);
   SetIndexBuffer(0,ADX);
   
   
   SetIndexStyle(1,DRAW_HISTOGRAM);
   SetIndexBuffer(1,UP);
   
   SetIndexStyle(2,DRAW_HISTOGRAM);
   SetIndexBuffer(2,DOWN);
   
 
   
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
 
	   double DMI = iADX(NULL, 0, CalculationPeriod, PriceType, MODE_PLUSDI, pos)- iADX(NULL, 0, CalculationPeriod, PriceType, MODE_MINUSDI, pos);
      
       ADX[pos] = iADX(NULL, 0, CalculationPeriod, PriceType, MODE_MAIN, pos);
	   
	   if (DMI>0) 
			   {
			   UP[pos]= DMI;
			   DOWN[pos]=  EMPTY_VALUE;
			   }
			   else
			   {
			   DOWN[pos]= DMI;
			   UP[pos]=  EMPTY_VALUE;
			   }
	  pos--;
  } 
  
  
  
  
   
 return(0);
}


//+------------------------------------------------------------------+
//|                               Copyright © 2017, Gehtsoft USA LLC | 
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
//|                         Donate / Support:  https://goo.gl/9Rj74e |
//|                     BitCoin: 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  | 
//+------------------------------------------------------------------+
//|                                      Developed by : Mario Jemic  |                    
//|                                          mario.jemic@gmail.com   |
//+------------------------------------------------------------------+

#property copyright "Copyright © 2017, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"

#property indicator_separate_window

#property indicator_buffers 3
#property indicator_color1 Blue
#property indicator_color2 Green
#property indicator_color3 Red
 
enum Method { SMA=1, EMA=2,SMMA=3, LWMA=4  };
//enum Method2 { SMA=0, EMA=1,SMMA=2, LWMA=3  };
//enum Method3 { SMA=0, EMA=1,SMMA=2, LWMA=3  };

extern int Fast_MA_Period=13;  
extern int Medium_MA_Period=21; 
extern int Slow_MA_Period=34;  
input Method  MA_Method = SMA;
double PP[];
double PP_Up[];
double PP_Down[];

int init()
  {
   IndicatorShortName("Pivot Oscillator");
   IndicatorDigits(MarketInfo(Symbol(),MODE_DIGITS));
   IndicatorBuffers(3);
   
   SetIndexStyle(0,DRAW_LINE);
   SetIndexBuffer(0,PP);
   
    SetIndexStyle(1,DRAW_HISTOGRAM);
   SetIndexBuffer(1,PP_Up);
   
    SetIndexStyle(2,DRAW_HISTOGRAM);
   SetIndexBuffer(2,PP_Down);
   
    int Max= MathMax(Fast_MA_Period,Medium_MA_Period );
    Max= MathMax(Max,Slow_MA_Period ); 
   
    SetIndexDrawBegin(0,Max);
	 SetIndexDrawBegin(1,Max);
	  SetIndexDrawBegin(2,Max);
  
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
   int limit=Bars-2;
   if(ExtCountedBars>2) limit=Bars-ExtCountedBars-1;
   
   
 
  
  

  
  int pos=limit;
  
  while(pos>=0)
   {
    
	 
 
			double Fast   = iMA(NULL,0,Fast_MA_Period  ,0,(MA_Method-1),PRICE_TYPICAL,pos);
			double Medium = iMA(NULL,0,Medium_MA_Period,0,(MA_Method-1),PRICE_TYPICAL,pos);
			double Slow   = iMA(NULL,0,Slow_MA_Period  ,0,(MA_Method-1),PRICE_TYPICAL,pos);
			
			double Differential1= Fast-Slow;
			double Differential2= Medium-Slow;
			double Differential3= Fast-Medium;
			
			PP[pos]=(Differential1+Differential2+Differential3)/((Close[pos]+High[pos]+Low[pos])/3);
			
			PP_Up[pos]= EMPTY_VALUE;
			PP_Down[pos]= EMPTY_VALUE;
			
					if (PP[pos]> PP[pos+1])
					{
					PP_Up[pos]= PP[pos];
					PP_Down[pos]= EMPTY_VALUE;
					}
					else
					{
					PP_Down[pos]= PP[pos]  ;
					PP_Up[pos]= EMPTY_VALUE;
					}
					
			
	 
    pos--;
   } 
   return(0);
  }



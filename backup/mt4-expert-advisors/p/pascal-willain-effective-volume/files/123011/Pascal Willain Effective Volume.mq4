
// More information about this indicator can be found at:
// http://fxcodebase.com/code/viewtopic.php?f=38&t=67194

//+------------------------------------------------------------------+
//|                               Copyright © 2018, Gehtsoft USA LLC | 
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
//|                                      Developed by : Mario Jemic  |
//|                                          mario.jemic@gmail.com   |
//+------------------------------------------------------------------+
//|                                 Support our efforts by donating  |
//|                                  Paypal : https://goo.gl/9Rj74e  |
//+------------------------------------------------------------------+
//|                                Patreon :  https://goo.gl/GdXWeN  |
//|                    BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |
//|               BitCoin Cash : 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg  |
//|           Ethereum : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D  |
//|                   LiteCoin : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD  |
//+------------------------------------------------------------------+

#property copyright "Copyright � 2018, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"
#property strict



//+------------------------------------------------------------------+
#property indicator_separate_window
#property indicator_buffers 2
#property indicator_color1 Red
#property indicator_width1 2

#property indicator_color2 Blue
#property indicator_width2 2

extern int Smooth       = 10;
extern int SmoothMethod = MODE_LWMA;

extern  bool AbsoluteValue = true;


double Buffer1[];
double Buffer2[];

//------------------------------------------------------------------
//
//------------------------------------------------------------------
int init()
{
    
	IndicatorShortName("Pascal Willain Effective Volume");
    IndicatorDigits(Digits+1);
    IndicatorBuffers(2);
    SetIndexBuffer(0, Buffer1);	
	SetIndexStyle(0, DRAW_LINE); 
    SetIndexLabel(0,"EV");
    SetIndexBuffer(1, Buffer2);
	SetIndexStyle(1, DRAW_LINE); 
    SetIndexLabel(1,"Signal");
    return(0);
}
int deinit()
{
    return(0);
}

//
//
//
//
//


int start()
{
   if (Bars <= 1) return(0);
   int ExtCountedBars = IndicatorCounted();
   if (ExtCountedBars < 0) return(-1); 
   int limit = Bars - 2;
   
   if(ExtCountedBars > 1) limit = Bars - ExtCountedBars;

   int i;
   
   for( i=limit; i>=0; i--)
   {
      double dividend = Close[i]-Close[i+1];
      double divisor  = MathMax(High[i],Close[i+1])-MathMin(Low[i],Close[i+1]);
         if (divisor!=0)
		 {
		       
			    if(AbsoluteValue)
			   {
               Buffer2[i] =  MathAbs(dividend)/divisor*Volume[i];
			   }
			   else
			   {
			   Buffer2[i] = dividend/divisor*Volume[i];
			   }
		 }	   
         else 
         {		 
		 Buffer2[i] = 0;
		 }
   }         
   for(i=limit; i>=0; i--)
   {
   Buffer1[i] = iMAOnArray(Buffer2,0,Smooth,0,SmoothMethod,i);
   }
   return(0);
}
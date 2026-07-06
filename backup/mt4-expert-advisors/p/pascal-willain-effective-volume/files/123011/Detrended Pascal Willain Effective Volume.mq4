
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

extern int Detrended_Period = 10; 

double Buffer1[];
double Buffer2[];
double Buffer3[];

//------------------------------------------------------------------
//
//------------------------------------------------------------------
int init()
{
    
	IndicatorShortName("Detrended Pascal Willain Effective Volume");
    IndicatorDigits(Digits+1);
    IndicatorBuffers(3);
	
	


    SetIndexBuffer(0, Buffer2);
	SetIndexStyle(0, DRAW_LINE); 
    SetIndexLabel(0,"Detrended Pascal Willain Effective Volume");
	
	SetIndexBuffer(1, Buffer3);
	SetIndexStyle(1, DRAW_LINE); 
    SetIndexLabel(1,"Signal");
	
	
	SetIndexBuffer(2, Buffer1);	
	SetIndexStyle(2, DRAW_NONE); 
	
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
   int limit = Bars - 1;
   if(ExtCountedBars > 1) limit = Bars - ExtCountedBars - 1;
    
   int pos; 
   
   limit = Bars - 2;
   if(ExtCountedBars > 1) limit = Bars - ExtCountedBars - 1;
   
   pos = limit;
   while (pos >= 0)
   {
      double dividend = Close[pos]-Close[pos+1];
      double divisor  = MathMax(High[pos],Close[pos+1])-MathMin(Low[pos],Close[pos+1]);
         if (divisor!=0)
		 {
                if(AbsoluteValue)
			   {
               Buffer1[pos] =  MathAbs(dividend)/divisor*Volume[pos];
			   }
			   else
			   {
			   Buffer1[pos] = dividend/divisor*Volume[pos];
			   }
		 }	   
         else 
         {		 
		 Buffer1[pos] = 0;
		 }
	pos--;	 
   }         
   
   
   limit = Bars - 2 -Detrended_Period ;
   if(ExtCountedBars > 1) limit = Bars - ExtCountedBars - 1;   
   
   pos = limit;
   while (pos >= 0)
   {
      
        double MA = iMAOnArray(Buffer1,0,Detrended_Period,0,MODE_SMA,pos);
   

		
		if (MA != 0)
		{
            Buffer2[pos] = Buffer1[pos]-MA;
		}
        else
        {
		Buffer2[pos]=0;
        }		
         
   pos--;
   } 
   
   
   limit = Bars - 2 -Detrended_Period- Smooth;
   if(ExtCountedBars > 1) limit = Bars - ExtCountedBars - 1;
   
   pos = limit;
   while (pos >= 0)
   {
   Buffer3[pos] = iMAOnArray(Buffer2,0,Smooth,0,SmoothMethod,pos);
   pos--;
   }
   return(0);
}

// This indicator is a port of WAVE-PM Metatrade indicator
// The original indicator:
//   developed by Mark Whistler/EcTrader.net
//  email: Mark@WallStreetRockStar.com
// http://www.WallStreetRockStar.com
// http://www.fxVolatility.com

// Please visit the http://www.fxVolatility.com to by ebook with
// detailed explanation on how the indicator is used.

//+------------------------------------------------------------------+
//|                               Copyright © 2016, Gehtsoft USA LLC | 
//|                                            http://fxcodebase.com |
//|                         Donate / Support:  https://goo.gl/9Rj74e | 
//+------------------------------------------------------------------+
//|                                      Developed by : Mario Jemic  |                    
//|                                          mario.jemic@gmail.com   |
//|                     BitCoin: 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF  |
//+------------------------------------------------------------------+

#property indicator_buffers 2
#property indicator_separate_window
#property indicator_levelcolor clrTomato
#property indicator_color1 Blue     
#property indicator_color2 Red  

#property indicator_levelcolor clrTomato
   

     extern int   ShortBandsPeriod= 14;
     extern int ShortBandsShift= 0 ;
     extern double ShortBandsDeviations= 2.2;

    extern int  LongBandsPeriod= 55;
    extern int LongBandsShift= 0;
    extern double LongBandsDeviations= 2.2;

    extern int Chars= 100;

    extern double central= 0.5;
    extern double overbought= 0.8;
    extern double oversold= 0.2;
	extern double  Level1=0.3;
	extern double  Level2= 0.7;

double ShortOscillator[];
double LongOscillator[];
double ShortDev[];
double ShortDev1[];

double LongDev[];
double LongDev1[];

int init(){
   
   IndicatorShortName("Active Volatility Energy - Price Mass");
   IndicatorBuffers(6);
   
   SetIndexStyle(0,DRAW_LINE); 
   SetIndexBuffer(0,ShortOscillator);
   SetIndexLabel(0,"ShortOscillator");
   
   
      SetIndexStyle(1,DRAW_LINE); 
   SetIndexBuffer(1,LongOscillator);
   SetIndexLabel(1,"LongOscillator");
   
    SetIndexBuffer(2,ShortDev);
   SetIndexBuffer(3,ShortDev1);
   
     SetIndexBuffer(4,LongDev);
   SetIndexBuffer(5,LongDev1);
   
   SetLevelValue(1,central);
   SetLevelValue(2,overbought);
   SetLevelValue(3,oversold);
   SetLevelValue(4,Level1);
   SetLevelValue(5,Level2);


   
   return(0);
}

int start()
  {
   
   int i;
   int counted_bars=IndicatorCounted();
   int limit = Bars-counted_bars-1;
   double avg;
   double sum;
   double temp;
   int j;
   
   for (i=limit; i>=0; i--){
   
             
		avg= iMA(NULL,0,ShortBandsPeriod,0,MODE_SMA,PRICE_CLOSE,i+ShortBandsShift);
		
		sum=0;
		
		for (j=ShortBandsPeriod-1; j>=0; j--){
		 temp = Close[i+j] - avg;
		 sum = sum + temp * temp;
		}
         
		ShortDev[i]= ShortBandsDeviations * MathSqrt(sum / ShortBandsPeriod);
        ShortDev1[i] = MathPow((ShortDev[i] / Point), 2);
		
		
		    //if  ( i < limit - Chars)
			//{
         
			
			  temp=0;
				for (j=Chars-1; j>=0; j--){				
				 temp = temp + ShortDev1[i+j];
				}
			
            temp = MathSqrt(temp / Chars) * Point;
            if (temp != 0)
			{
                temp = ShortDev[i] / temp;
            }

				
         
			ShortOscillator[i] = MathTanh(temp);
				
		   //}
   }
   
   
    for (i=limit; i>=0; i--){
   
             
		avg= iMA(NULL,0,LongBandsPeriod,0,MODE_SMA,PRICE_CLOSE,i+LongBandsShift);
		
		sum=0;
		
		for (j=LongBandsPeriod-1; j>=0; j--){
		 temp = Close[i+j] - avg;
		 sum = sum + temp * temp;
		}
         
		LongDev[i]= LongBandsDeviations * MathSqrt(sum / LongBandsPeriod);
        LongDev1[i] = MathPow((LongDev[i] / Point), 2);
		
		
		    //if  ( i < limit - Chars)
			//{
     
			
			  temp=0;
				for (j=Chars-1; j>=0; j--){				
				 temp = temp + LongDev1[i+j];
				}
			
            temp = MathSqrt(temp / Chars) * Point;
            if (temp != 0)
			{
                temp = LongDev[i] / temp;
            }
		
		
		
		    LongOscillator[i] = MathTanh(temp);
		   //}
   }
    
     
   
//----
   return(0);
}



double MathTanh(double x)
{ 
   double exp;
   double returnNum;
   if(x>0)
     {
       exp=MathExp(-2*x);
       returnNum= (1-exp)/(1+exp);
       return (returnNum);
     }
   else
     {
       exp=MathExp(2*x);
       returnNum=(exp-1)/(1+exp);
       return (returnNum);
     }
}
// More information about this indicator can be found at:
// http://fxcodebase.com/code/viewtopic.php?f=38&t=67338

//+------------------------------------------------------------------+
//|                               Copyright © 2019, Gehtsoft USA LLC | 
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

#property copyright "Copyright © 2019, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"
#property version   "1.0"
#property strict

#property indicator_separate_window
#property indicator_buffers 4
#property indicator_color1 Green
#property indicator_color2 Red
#property indicator_color3 DarkBlue
#property indicator_color4 LightBlue

 
#property indicator_level1 25
#property indicator_level2 20 
     
#property indicator_levelcolor Red
#property indicator_levelwidth 2
#property indicator_levelstyle STYLE_DOT
 
extern int Length=14;
//extern double Strong_Trend=25;
//extern double Weak_Trend=20;


enum Price_Types{ Close_Price=1,  Open_Price=2, High_Price=3, Low_Price=4, Median_Price=4, Typical_Price=4, Weighted_Price=4 };
 
input  Price_Types Price_Type = Close_Price;
 
 
double Pozitiv[], Negativ[], Weak[], Neutral[];

int init()
{
 IndicatorShortName("Advanced_ADX");
 IndicatorDigits(Digits);
 IndicatorBuffers(4);
 
 SetIndexStyle(0,DRAW_HISTOGRAM);
 SetIndexBuffer(0,Pozitiv);
 SetIndexStyle(1,DRAW_HISTOGRAM);
 SetIndexBuffer(1,Negativ);
 SetIndexStyle(2,DRAW_HISTOGRAM);
 SetIndexBuffer(2,Weak);
 SetIndexStyle(3,DRAW_HISTOGRAM);
 SetIndexBuffer(3,Neutral);

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
 double ADX,DIP,DIM;

 pos=limit;
 while(pos>=0)
 {
  ADX=iADX(NULL, 0, Length, (Price_Type-1), MODE_MAIN, pos);
  DIP=iADX(NULL, 0, Length, (Price_Type-1), MODE_PLUSDI, pos);
  DIM=iADX(NULL, 0, Length, (Price_Type-1), MODE_MINUSDI, pos);
  
  
  Pozitiv[pos]=0.;
  Negativ[pos]=0.;
  Weak[pos]=0.;
  Neutral[pos]=0.;
  
  
  if (ADX>indicator_level1)
  { 
  
     if (DIP > DIM)
	 {
	 Pozitiv[pos]=ADX;
	 }
	 else
	 {
	 Negativ[pos]=ADX;
	 }
    
  }
  
  else if (ADX<indicator_level2)
  
  {
  
        Weak[pos]=ADX;
  
  }
  
  else
  {  
  
        Neutral[pos]=ADX;  
  
  }
  
  pos--;
 } 
 return(0);
}


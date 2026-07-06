//+------------------------------------------------------------------+
//|                                                          WSI.mq4 |
//|                             Copyright (c) 2017, Gehtsoft USA LLC | 
//|                                            http://fxcodebase.com |
//|                                   Paypal: https://goo.gl/9Rj74e  | 
//+------------------------------------------------------------------+
//|                                      Developed by : Mario Jemic  |                    
//|                                          mario.jemic@gmail.com   |
//|                   BitCoin : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF   |
//+------------------------------------------------------------------+

#property indicator_buffers 2
#property indicator_separate_window
#property indicator_width1 2
#property indicator_color1 clrLime
#property indicator_width2 2
#property indicator_color2 clrRed
#property indicator_levelcolor clrYellow
#property indicator_levelwidth 1
#property indicator_levelstyle STYLE_DOT

extern int CCI_Period  = 100;
extern int ADX_Period  = 100;

double WSI[];
double Up[];
double Dn[];
double Price[];
double CCI[];
double ADX[];

int init(){
   
   IndicatorShortName("WSI");
   IndicatorBuffers(6);
   
   SetIndexStyle(0,DRAW_HISTOGRAM);
   SetIndexBuffer(0,Up);
   SetIndexLabel(0,"WSI Up");
   SetIndexStyle(1,DRAW_HISTOGRAM);
   SetIndexBuffer(1,Dn);
   SetIndexLabel(1,"WSI Down");
   
   SetIndexBuffer(2,WSI);
   SetIndexBuffer(3,Price);
   SetIndexBuffer(4,CCI);
   SetIndexBuffer(5,ADX);
   
   SetLevelValue(0,0);
   
   return(0);
}

int start(){
   
   int i;
   int counted_bars=IndicatorCounted();
   int limit = Bars-counted_bars-1;
   
   for(i=limit; i>=0; i--){
      
      Price[i] = iMA(NULL,0,1,0,MODE_SMA,PRICE_TYPICAL,i);
      CCI[i]   = iCCI(NULL,0,CCI_Period,PRICE_TYPICAL,i);
      ADX[i]   = iADX(NULL,0,ADX_Period,PRICE_CLOSE,MODE_MAIN,i);
      
      WSI[i]=(CCI[i]*Price[i]* ADX[i]) / 1000;
	  
      if (WSI[i] >= 0)
         Up[i] = WSI[i];
      else
         Dn[i] = WSI[i]; 
         
   }
   
//----
   return(0);
}
  

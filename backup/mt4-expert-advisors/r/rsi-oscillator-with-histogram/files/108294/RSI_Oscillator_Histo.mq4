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
#property indicator_levelcolor clrYellow

extern int   Short_RSI_Period = 10;
extern int   Long_RSI_Period  = 25;
extern int   MVA_Period       = 5;
extern color Up_Color         = clrLime;
extern color Dn_Color         = clrRed;
extern int   Bars_Width       = 3;

double UP[];
double DOWN[];
double Long[];
double Short[];
double Buffer[];
double MVA[];

int Multiplier = 1;

int init(){
   
   IndicatorShortName("RSI_Oscillator_Histo");
   IndicatorBuffers(6);
   
   SetIndexStyle(0,DRAW_HISTOGRAM,STYLE_SOLID,Bars_Width,Up_Color);
   SetIndexBuffer(0,UP);
   SetIndexLabel(0,"UP");
   SetIndexStyle(1,DRAW_HISTOGRAM,STYLE_SOLID,Bars_Width,Dn_Color);
   SetIndexBuffer(1,DOWN);
   SetIndexLabel(1,"DOWN");
      
   SetIndexBuffer(2,Long);
   SetIndexBuffer(3,Short);
   SetIndexBuffer(4,Buffer);
   SetIndexBuffer(5,MVA);
   
   SetLevelValue(0,0);
   
   return(0);
}

int start()
  {
   
   int i;
   int counted_bars=IndicatorCounted();
   int limit = Bars-counted_bars-1;
      
   for(i=limit-Long_RSI_Period; i>=0; i--){
      
      Long[i]   = iRSI(NULL,0,Long_RSI_Period,PRICE_CLOSE,i);
      Short[i]  = iRSI(NULL,0,Short_RSI_Period,PRICE_CLOSE,i);
      Buffer[i] = Short[i] - Long[i];
      MVA[i] = sma(Buffer,MVA_Period,i);
      
   }
   
   for(i=limit-Long_RSI_Period; i>=0; i--){
      
      if (MVA[i] > MVA[i+1])
         UP[i] = MVA[i];
      else
         DOWN[i] = MVA[i];

   }
   
   
   
//----
   return(0);
}
  
//+------------------------------------------------------------------+
//| Simple MA                                                        |
//+------------------------------------------------------------------+

double sma( double& ind_buffer_data_x1[], int p, int j, bool current = false )
{
   double dblSum = 0.0;
   
   for ( int inx = 0; inx < p; inx++ )
   {
      if (current){
         if (inx==0) dblSum += ind_buffer_data_x1[0]; else dblSum += ind_buffer_data_x1[j+((inx-1)*Multiplier)];
      }else
         dblSum += ind_buffer_data_x1[j+(inx*Multiplier)];
   }
   
   return( dblSum / p );
}
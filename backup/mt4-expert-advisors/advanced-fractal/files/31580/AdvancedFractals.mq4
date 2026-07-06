// More information about this indicator can be found at:
// http://fxcodebase.com/code/viewtopic.php?f=38&t=17244

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

#property indicator_chart_window
#property indicator_buffers 2
#property indicator_color1 Red
#property indicator_color2 Blue

extern int Frames=2;

double ExtUpFractalsBuffer[];
double ExtDownFractalsBuffer[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
//---- indicator buffers mapping  
    SetIndexBuffer(0,ExtUpFractalsBuffer);
    SetIndexBuffer(1,ExtDownFractalsBuffer);   
//---- drawing settings
    SetIndexStyle(0,DRAW_ARROW,0,4);
    SetIndexArrow(0,119);
    SetIndexStyle(1,DRAW_ARROW,0,4);
    SetIndexArrow(1,119);
//----
    SetIndexEmptyValue(0,0.0);
    SetIndexEmptyValue(1,0.0);
//---- name for DataWindow
    SetIndexLabel(0,"Fractal Up");
    SetIndexLabel(1,"Fractal Down");
//---- initialization done   
   return(0);
  }
//+------------------------------------------------------------------+
//| Custor indicator deinitialization function                       |
//+------------------------------------------------------------------+
int deinit()
  {

   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int start()
  {
   int    i,nCountedBars;
   bool   bFound;
   double dCurrent;
   nCountedBars=IndicatorCounted();
//---- last counted bar will be recounted    
   if(nCountedBars<=2)
      i=Bars-nCountedBars-3;
   if(nCountedBars>2)
   {
      nCountedBars--;
      i = MathMax(Frames + 1, Bars - nCountedBars - 1);
   }

   while(i>=Frames+1)
     {
      bool FrUp=true;
      bool FrDn=true;
      int ii;
      for (ii=1;ii<=Frames;ii++)
      {
       if (High[i+ii]>=High[i] || High[i-ii]>=High[i]) FrUp=false;
       if (Low[i+ii]<=Low[i] || Low[i-ii]<=Low[i]) FrDn=false;
      }
     
      //----Fractals up
      if (FrUp)
        {
         ExtUpFractalsBuffer[i]=High[i];
        }
      //----Fractals down
      if (FrDn)
        {
         ExtDownFractalsBuffer[i]=Low[i];
        }
      i--;
     }

   return(0);
  }


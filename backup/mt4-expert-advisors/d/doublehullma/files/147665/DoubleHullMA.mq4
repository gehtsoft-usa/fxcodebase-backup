// More information about this indicator can be found at:
// https://fxcodebase.com/code/viewtopic.php?f=38&t=72775

//+------------------------------------------------------------------------------------------------+
//|                                                            Copyright © 2022, Gehtsoft USA LLC  | 
//|                                                                         http://fxcodebase.com  |
//+------------------------------------------------------------------------------------------------+
//|                                                                   Developed by : Mario Jemic   |                    
//|                                                                       mario.jemic@gmail.com    |
//|                                                        https://AppliedMachineLearning.systems  |
//|                                                                       https://mario-jemic.com/ |
//+------------------------------------------------------------------------------------------------+

//+------------------------------------------------------------------------------------------------+
//|                                           Our work would not be possible without your support. |
//+------------------------------------------------------------------------------------------------+
//|                                                               Paypal: https://goo.gl/9Rj74e    |
//|                                                             Patreon :  https://goo.gl/GdXWeN   |  
//+------------------------------------------------------------------------------------------------+

//+------------------------------------------------------------------------------------------------+
//|BitCoin                    : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF                                 |  
//|Ethereum                   : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D                         |  
//|SOL Address                : 4tJXw7JfwF3KUPSzrTm1CoVq6Xu4hYd1vLk3VF2mjMYh                       |
//|Cardano/ADA                : addr1v868jza77crzdc87khzpppecmhmrg224qyumud6utqf6f4s99fvqv         |  
//|Dogecoin Address           : DBGXP1Nc18ZusSRNsj49oMEYFQgAvgBVA8                                 |
//|SHIB Address               : 0x1817D9ebb000025609Bf5D61E269C64DC84DA735                         |              
//|Binance(ERC20 & BSC only)  : 0xe84751063de8ade7c5fbff5e73f6502f02af4e2c                         | 
//|BitCoin Cash               : 1BEtS465S3Su438Kc58h2sqvVvHK9Mijtg                                 | 
//|LiteCoin                   : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD                                 |  
//+------------------------------------------------------------------------------------------------+




#property copyright "Copyright © 2022, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"
#property version "1.0"
#property strict

//13.05.2016   - v1
//18.08.2019   - v2     - Correction for signal drawing
//19.08.2019   - v3.1   - Arows on first entry signal; Entry levels

#property indicator_chart_window 

#property indicator_buffers 12

#property indicator_color1 clrAqua 
#property indicator_color2 clrTomato 
#property indicator_color3 clrDodgerBlue
#property indicator_color4 clrMagenta
#property indicator_color5 clrDodgerBlue  //signals
#property indicator_color6 clrMagenta
#property indicator_color7 clrLime  //arrows
#property indicator_color8 clrGold
#property indicator_color9 clrLime  //entrys
#property indicator_color10 clrGold


#property indicator_width1 3
#property indicator_width2 3
#property indicator_width3 2
#property indicator_width4 2
#property indicator_width5 1  //signals
#property indicator_width6 1
#property indicator_width7 2  //arrows
#property indicator_width8 2
#property indicator_width9 1  //entrys
#property indicator_width10 1

//---- input parameters 
//###################################################################
extern bool       Show_EntryLevels=true;
extern bool       Set_Only_LimitOrder=true;
extern string ___Hull_MovingAverage___="----------------------------------------------------";
extern int       Fast_Period=12;
extern int       Slow_Period=120;
extern ENUM_MA_METHOD     method =MODE_LWMA;
extern ENUM_APPLIED_PRICE price  =PRICE_CLOSE;
extern string ___ADX___="----------------------------------------------------";
extern int     ADX_Period  =12;
extern double  ADX_Limit   =20;
extern string ___ATR___="----------------------------------------------------";
extern int     ATR_Period        =14;
extern int     ATR_Smoothing     =35;
extern double  OffsetEntry_Factor=1.5;
extern string ___Filter___="----------------------------------------------------";
extern bool Enable_TrendFilter=true;
extern bool Enable_ADXFilter=true;
//###################################################################
//---- buffers 
double FastUPtrend[],FastDNtrend[],FastBuffer[];
double SlowUPtrend[],SlowDNtrend[],SlowBuffer[];
double SignalUP[],SignalDN[],SignalUP2[],SignalDN2[];
double entryUP[],entryDN[];
double ADXbuffer[];
double ATRbuffer[],ATRsmooth[];
//+------------------------------------------------------------------+ 
//| Custom indicator initialization function                         | 
//+------------------------------------------------------------------+ 
int init()
  {
   int iBuff=-1;
   iBuff++; SetIndexBuffer(iBuff,FastUPtrend); SetIndexLabel(iBuff,NULL);
   iBuff++; SetIndexBuffer(iBuff,FastDNtrend); SetIndexLabel(iBuff,NULL);

   iBuff++; SetIndexBuffer(iBuff,SlowUPtrend); SetIndexLabel(iBuff,NULL);
   iBuff++; SetIndexBuffer(iBuff,SlowDNtrend); SetIndexLabel(iBuff,NULL);
//--- arrws
   int iArrowUP=116;
   int iArrowDN=116;
   iBuff++; SetIndexBuffer(iBuff,SignalUP); SetIndexLabel(iBuff,NULL); SetIndexStyle(iBuff,DRAW_ARROW,STYLE_SOLID); SetIndexArrow(iBuff,iArrowUP); SetIndexEmptyValue(iBuff,EMPTY_VALUE);
   iBuff++; SetIndexBuffer(iBuff,SignalDN); SetIndexLabel(iBuff,NULL); SetIndexStyle(iBuff,DRAW_ARROW,STYLE_SOLID); SetIndexArrow(iBuff,iArrowDN); SetIndexEmptyValue(iBuff,EMPTY_VALUE);
//--- first signal
   int iArrowUP2=233;
   int iArrowDN2=234;
   iBuff++; SetIndexBuffer(iBuff,SignalUP2); SetIndexLabel(iBuff,NULL); SetIndexStyle(iBuff,DRAW_ARROW,STYLE_SOLID); SetIndexArrow(iBuff,iArrowUP2);  SetIndexEmptyValue(iBuff,EMPTY_VALUE);
   iBuff++; SetIndexBuffer(iBuff,SignalDN2); SetIndexLabel(iBuff,NULL); SetIndexStyle(iBuff,DRAW_ARROW,STYLE_SOLID); SetIndexArrow(iBuff,iArrowDN2);  SetIndexEmptyValue(iBuff,EMPTY_VALUE);
//--- entrys
   int iArrowUPentry=164; //59;
   int iArrowDNentry=164; //59;
   iBuff++; SetIndexBuffer(iBuff,entryUP); SetIndexLabel(iBuff,"HullEntry LONG"); 
   SetIndexStyle(iBuff,DRAW_ARROW,STYLE_SOLID); SetIndexArrow(iBuff,iArrowUPentry); SetIndexEmptyValue(iBuff,EMPTY_VALUE); if(Show_EntryLevels==false) SetIndexStyle(iBuff,DRAW_NONE);
   iBuff++; SetIndexBuffer(iBuff,entryDN); SetIndexLabel(iBuff,"HullEntry SHORT"); 
   SetIndexStyle(iBuff,DRAW_ARROW,STYLE_SOLID); SetIndexArrow(iBuff,iArrowDNentry); SetIndexEmptyValue(iBuff,EMPTY_VALUE); if(Show_EntryLevels==false) SetIndexStyle(iBuff,DRAW_NONE);
//--- help
   iBuff++; SetIndexBuffer(iBuff,FastBuffer); SetIndexLabel(iBuff,"Hull fast ("+(string)Fast_Period+")"); SetIndexStyle(iBuff,DRAW_NONE); SetIndexEmptyValue(iBuff,EMPTY_VALUE);
   iBuff++; SetIndexBuffer(iBuff,SlowBuffer); SetIndexLabel(iBuff,"Hull slow ("+(string)Slow_Period+")"); SetIndexStyle(iBuff,DRAW_NONE); SetIndexEmptyValue(iBuff,EMPTY_VALUE);

//--- more buffers
   IndicatorBuffers(15);
   iBuff++; SetIndexBuffer(iBuff,ADXbuffer); SetIndexEmptyValue(iBuff,EMPTY_VALUE);
   iBuff++; SetIndexBuffer(iBuff,ATRbuffer); SetIndexEmptyValue(iBuff,EMPTY_VALUE);
   iBuff++; SetIndexBuffer(iBuff,ATRsmooth); SetIndexEmptyValue(iBuff,EMPTY_VALUE);  
//---
   IndicatorShortName("smDoubleHull MA("+(string)Fast_Period+","+(string)Slow_Period+")");
   IndicatorDigits(Digits);

   SetIndexDrawBegin(0,Slow_Period+2);
   SetIndexDrawBegin(1,Slow_Period+2);
   return(0);
  }
//+------------------------------------------------------------------+ 
//| Custor indicator deinitialization function                       | 
//+------------------------------------------------------------------+ 
int deinit()
  {
// 
//Comment("");
   return(0);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double WMA(int x,int p)
  {
   return(iMA(NULL, 0, p, 0, method, price, x));
  }
//+------------------------------------------------------------------+ 
//| Custom indicator iteration function                              | 
//+------------------------------------------------------------------+ 
int start()
  {
   int counted_bars=IndicatorCounted();

   if(counted_bars<0)
      return(-1);

   int x=0;
   int p;
//int p = MathSqrt(period);
   int e=Bars-counted_bars+Slow_Period+1;

//-- 1. Fast Hull MA
//=========================================================
   double vect[],trend[];
   p=(int)MathSqrt((double)Fast_Period);

   if(e>Bars) e=Bars;

   ArrayResize(vect,e);
   ArraySetAsSeries(vect,true);
   ArrayResize(trend,e);
   ArraySetAsSeries(trend,true);

   for(x=0; x<e; x++)
      vect[x]=2*WMA(x,(int)(Fast_Period/2.0))-WMA(x,Fast_Period);
   for(x=0; x<e-Fast_Period; x++)
      FastBuffer[x]=iMAOnArray(vect,0,p,0,method,x);

   for(x=e-Fast_Period; x>=0; x--)
     {
      trend[x]=trend[x+1];
      if(FastBuffer[x]> FastBuffer[x+1]) trend[x] =1;
      if(FastBuffer[x]< FastBuffer[x+1]) trend[x] =-1;

      if(trend[x]>0)
        {
         FastUPtrend[x]=FastBuffer[x];
         if(trend[x+1]<0) FastUPtrend[x+1]=FastBuffer[x+1];
         FastDNtrend[x]=EMPTY_VALUE;
        }
      else
      if(trend[x]<0)
        {
         FastDNtrend[x]=FastBuffer[x];
         if(trend[x+1]>0) FastDNtrend[x+1]=FastBuffer[x+1];
         FastUPtrend[x]=EMPTY_VALUE;
        }
     }
//=========================================================

//-- 2. Slow Hull MA
//=========================================================
   p=(int)MathSqrt((double)Slow_Period);

   for(x=0; x<e; x++)
      vect[x]=2*WMA(x,(int)(Slow_Period/2.0))-WMA(x,Slow_Period);
   for(x=0; x<e-Slow_Period; x++)
      SlowBuffer[x]=iMAOnArray(vect,0,p,0,method,x);

   for(x=e-Slow_Period; x>=0; x--)
     {
      trend[x]=trend[x+1];
      if(SlowBuffer[x]> SlowBuffer[x+1]) trend[x] =1;
      if(SlowBuffer[x]< SlowBuffer[x+1]) trend[x] =-1;

      if(trend[x]>0)
        {
         SlowUPtrend[x]=SlowBuffer[x];
         if(trend[x+1]<0) SlowUPtrend[x+1]=SlowBuffer[x+1];
         SlowDNtrend[x]=EMPTY_VALUE;
        }
      else
      if(trend[x]<0)
        {
         SlowDNtrend[x]=SlowBuffer[x];
         if(trend[x+1]>0) SlowDNtrend[x+1]=SlowBuffer[x+1];
         SlowUPtrend[x]=EMPTY_VALUE;
        }
     }
//=========================================================

//-- 3. ADX, ATR
//=========================================================
   for(x=e-Slow_Period; x>=0; x--)
     {
      ADXbuffer[x]=iADX(Symbol(),Period(),ADX_Period,PRICE_CLOSE,MODE_MAIN,x);
      ATRbuffer[x]=iATR(Symbol(),Period(),ATR_Period,x);
     }
   for(x=e-Slow_Period-ATR_Smoothing; x>=0; x--)
     ATRsmooth[x]=iMAOnArray(ATRbuffer,0,ATR_Smoothing,0,MODE_SMA,x);
     
//-- 4. Signals
//=========================================================
   double entryValue=0;
   if(Enable_TrendFilter==true)
     {
      for(x=e-Slow_Period; x>=0; x--)
        {
         if(Time[x]==D'2019.07.16 08:00')
            int vv=9;
         //-- 4.1 LONG signal
         if(FastBuffer[x]>FastBuffer[x+1] && SlowBuffer[x]>SlowBuffer[x+1])
           {
            if(Enable_ADXFilter==false)
              {
               SignalUP[x]=SlowBuffer[x];
              }
            else
            if(Enable_ADXFilter==true)
              {
               if(ADXbuffer[x]>ADX_Limit)
                  SignalUP[x]=SlowBuffer[x];
               else
                  SignalUP[x]=EMPTY_VALUE;
              }
            //========================
            //--- arrow, entry long
            if(SignalUP[x]!=EMPTY_VALUE && SignalUP[x+1]!=EMPTY_VALUE && SignalUP[x+2]==EMPTY_VALUE && SignalUP2[x+2]==EMPTY_VALUE)
              {
               SignalUP2[x]=SignalUP[x];
               SignalUP[x]=EMPTY_VALUE;
               entryValue=Low[x+1]+ATRsmooth[x+1]*OffsetEntry_Factor;
               //entryValue=Low[x+1]+ATRbuffer[x+1]*OffsetEntry_Factor;               
               if(Set_Only_LimitOrder==true)
                 {
                  if(Open[x]<entryValue)
                     entryUP[x]=entryValue;
                 }
               else
                  entryUP[x]=entryValue;
              }
           }
         else
            SignalUP[x]=EMPTY_VALUE;

         //-- 4.2 SHORT signal
         if(FastBuffer[x]<FastBuffer[x+1] && SlowBuffer[x]<SlowBuffer[x+1])
           {
            if(Enable_ADXFilter==false)
              {
               SignalDN[x]=SlowBuffer[x];
              }
            else
            if(Enable_ADXFilter==true)
              {
               if(ADXbuffer[x]>ADX_Limit)
                  SignalDN[x]=SlowBuffer[x];
               else
                  SignalDN[x]=EMPTY_VALUE;
              }
            //========================
            //--- arrow, entry short
            if(SignalDN[x]!=EMPTY_VALUE && SignalDN[x+1]!=EMPTY_VALUE && SignalDN[x+2]==EMPTY_VALUE && SignalDN2[x+2]==EMPTY_VALUE)
              {
               SignalDN2[x]=SignalDN[x];
               SignalDN[x]=EMPTY_VALUE;
               entryValue=High[x+1]-ATRsmooth[x+1]*OffsetEntry_Factor;
               //entryValue=High[x+1]-ATRbuffer[x+1]*OffsetEntry_Factor;               
               if(Set_Only_LimitOrder==true)
                 {
                  if(Open[x]>entryValue)
                     entryDN[x]=entryValue;
                 }
               else
                  entryDN[x]=entryValue;
              }
           }
        }
     }
   else
     {
      SignalUP[x]=EMPTY_VALUE;
      SignalDN[x]=EMPTY_VALUE;
     }

   return(0);
  }
//+------------------------------------------------------------------+ 

//+------------------------------------------------------------------------------------------------+
//|                                                                    We appreciate your support. | 
//+------------------------------------------------------------------------------------------------+
//|                                                               Paypal: https://goo.gl/9Rj74e    |
//|                                                             Patreon :  https://goo.gl/GdXWeN   |  
//+------------------------------------------------------------------------------------------------+
//|                                                                   Developed by : Mario Jemic   |                    
//|                                                                       mario.jemic@gmail.com    |
//|                                                        https://AppliedMachineLearning.systems  |
//|                                                                       https://mario-jemic.com/ |
//+------------------------------------------------------------------------------------------------+
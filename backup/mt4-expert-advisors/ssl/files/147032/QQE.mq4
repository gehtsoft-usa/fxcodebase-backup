// More information about this indicator can be found at:
//https://fxcodebase.com/code/viewtopic.php?f=38&t=72608

//+------------------------------------------------------------------------------------------------+
//|                                                            Copyright © 2022, Gehtsoft USA LLC  | 
//|                                                                         http://fxcodebase.com  |
//+------------------------------------------------------------------------------------------------+
//|                                                              Support our efforts by donating   | 
//|                                                                 Paypal: https://goo.gl/9Rj74e  |
//+------------------------------------------------------------------------------------------------+
//|                                                                   Developed by : Mario Jemic   |                    
//|                                                                       mario.jemic@gmail.com    |
//|                                                        https://AppliedMachineLearning.systems  |
//|                                                             Patreon :  https://goo.gl/GdXWeN   |  
//+------------------------------------------------------------------------------------------------+

//Your donations will allow the service to continue onward.
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
//----
#property indicator_separate_window
#property indicator_buffers 2
#property indicator_color1 Navy
#property indicator_style1 STYLE_SOLID
#property indicator_width1 2
#property indicator_color2 Navy
#property indicator_style2 STYLE_DOT
//----
extern int SF=5;
//----
int RSI_Period=14;
int Wilders_Period;
int StartBar;
//----
double TrLevelSlow[];
double AtrRsi[];
double MaAtrRsi[];
double Rsi[];
double RsiMa[];
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int init()
  {
   Wilders_Period=RSI_Period*2-1;
   if(Wilders_Period<SF)
      StartBar=SF;
   else
      StartBar=Wilders_Period;
//----
   IndicatorBuffers(5);
   SetIndexBuffer(0,RsiMa);
   SetIndexStyle(0,DRAW_LINE,STYLE_SOLID,2);
   SetIndexLabel(0,"Value 1");
   SetIndexDrawBegin(0,StartBar);
   SetIndexStyle(1,DRAW_LINE,STYLE_DOT);
   SetIndexBuffer(1,TrLevelSlow);
   SetIndexLabel(1,"Value 2");
   SetIndexDrawBegin(1,StartBar);
   SetIndexBuffer(2,AtrRsi);
   SetIndexBuffer(3,MaAtrRsi);
   SetIndexBuffer(4,Rsi);
   IndicatorShortName(StringConcatenate("QQE(",SF,")"));
   return(0);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int start()
  {
   int counted,i;
   double rsi0,rsi1,dar,tr,dv;
//----
   if(Bars<=StartBar) return(0);
//----
   int counted_bars=IndicatorCounted();
   if(counted_bars<0) return(-1);
   if(counted_bars>0) counted_bars--;
   int limit=Bars-counted_bars;
   if(counted_bars==0) limit-=1+1;

   /*if(counted_bars==0)
     {
      ArrayInitialize(TrLevelSlow,0.0);
      ArrayInitialize(AtrRsi,0.0);
      ArrayInitialize(MaAtrRsi,0.0);
      ArrayInitialize(Rsi,0.0);
      ArrayInitialize(RsiMa,0.0);
     }*/
//----
   for(i=limit; i>=0; i--)
      Rsi[i]=iRSI(NULL,0,RSI_Period,PRICE_CLOSE,i);
   for(i=limit; i>0; i--)
     {
      RsiMa[i]=iMAOnArray(Rsi,0,SF,0,MODE_EMA,i);
      AtrRsi[i]=MathAbs(RsiMa[i+1]-RsiMa[i]);
     }
   for(i=limit; i>=0; i--)
      MaAtrRsi[i]=iMAOnArray(AtrRsi,0,Wilders_Period,0,MODE_EMA,i);
   i=limit;
   tr=TrLevelSlow[i];
   rsi1=iMAOnArray(Rsi,0,SF,0,MODE_EMA,i);
   while(i>0)
     {
      i--;
      rsi0=iMAOnArray(Rsi,0,SF,0,MODE_EMA,i);
      dar=iMAOnArray(MaAtrRsi,0,Wilders_Period,0,MODE_EMA,i)*4.236;
      dv=tr;
      if(rsi0<tr)
        {
         tr=rsi0+dar;
         if(rsi1<dv)
            if(tr>dv)
               tr=dv;
        }
      else if(rsi0>tr)
        {
         tr=rsi0-dar;
         if(rsi1>dv)
            if(tr<dv)
               tr=dv;
        }
      TrLevelSlow[i]=tr;
      rsi1=rsi0;
     }
//----
   return(0);
  }
//+------------------------------------------------------------------+

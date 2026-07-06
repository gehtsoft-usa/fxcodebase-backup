// More information about this indicator can be found at:
// https://fxcodebase.com/code/viewtopic.php?f=38&t=74649

//+------------------------------------------------------------------------------------------------+
//|                                                            Copyright © 2024, Gehtsoft USA LLC  | 
//|                                                                         http://fxcodebase.com  |
//+------------------------------------------------------------------------------------------------+
//|                                                                    Developed by : Mario Jemic  |                                                                                      
//|                                                                         mario.jemic@gmail.com  |                                                                         
//|                                                        https://AppliedMachineLearning.systems  |                                                                      
//+------------------------------------------------------------------------------------------------+

//+------------------------------------------------------------------------------------------------+
//|                                           Our work would not be possible without your support. |
//+------------------------------------------------------------------------------------------------+
//|                                                              Paypal: https://goo.gl/9Rj74e     |
//|                                                            Patreon : https://goo.gl/GdXWeN     |  
//|                                                     Buy Me a Coffee: http://tiny.cc/pjh9vz     |
//+------------------------------------------------------------------------------------------------+

#property copyright "Copyright © 2024, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"
#property version "1.0"


#property indicator_buffers 6
#property indicator_color1 Black
#property indicator_color2 0XFFFFFFFF  // MediumBlue
#property indicator_color3 0xFFFFFFFF  // Yellow
#property indicator_color4 0XFFFFFFFF  // MediumBlue
#property indicator_color5 Green
#property indicator_color6 Red
#property indicator_separate_window

extern int RSI_Period = 13;         //8-25
extern int RSI_Price = 0;           //0-6
extern int Volatility_Band = 34;    //20-40
extern int RSI_Price_Line = 2;      
extern int RSI_Price_Type = 0;      //0-3
extern int Trade_Signal_Line = 7;   
extern int Trade_Signal_Type = 0;   //0-3

double RSIBuf[],UpZone[],MdZone[],DnZone[],MaBuf[],MbBuf[];

int init()
  {
   IndicatorShortName("TDI");
   SetIndexBuffer(0,RSIBuf);
   SetIndexBuffer(1,UpZone);
   SetIndexBuffer(2,MdZone);
   SetIndexBuffer(3,DnZone);
   SetIndexBuffer(4,MaBuf);
   SetIndexBuffer(5,MbBuf);
   
   SetIndexStyle(0,DRAW_NONE); 
   SetIndexStyle(1,DRAW_LINE); 
   SetIndexStyle(2,DRAW_LINE);   //,0,2
   SetIndexStyle(3,DRAW_LINE);
   SetIndexStyle(4,DRAW_LINE);   //,0,2
   SetIndexStyle(5,DRAW_LINE);   //,0,2
   
   SetIndexLabel(0,NULL); 
   SetIndexLabel(1,"VB High"); 
   SetIndexLabel(2,"Market Base Line"); 
   SetIndexLabel(3,"VB Low"); 
   SetIndexLabel(4,"RSI Price Line");
   SetIndexLabel(5,"Trade Signal Line");
 
   SetLevelValue(0,50);
   SetLevelValue(1,68);
   SetLevelValue(2,32);
   SetLevelStyle(STYLE_DOT,1,DimGray);
   
   return(0);
  }

int start()
  {
   double MA,RSI[];
   ArrayResize(RSI,Volatility_Band);
   int counted_bars=IndicatorCounted();
   int limit = Bars-counted_bars-1;
   for(int i=limit; i>=0; i--)
   {
      RSIBuf[i] = (iRSI(NULL,0,RSI_Period,RSI_Price,i)); 
      MA = 0;
      for(int x=i; x<i+Volatility_Band; x++) {
         RSI[x-i] = RSIBuf[x];
         MA += RSIBuf[x]/Volatility_Band;
      }
      UpZone[i] = (MA + (1.6185 * StDev(RSI,Volatility_Band)));
      DnZone[i] = (MA - (1.6185 * StDev(RSI,Volatility_Band)));  
      MdZone[i] = ((UpZone[i] + DnZone[i])/2);
      }
   for (i=limit-1;i>=0;i--)  
      {
       MaBuf[i] = (iMAOnArray(RSIBuf,0,RSI_Price_Line,0,RSI_Price_Type,i));
       MbBuf[i] = (iMAOnArray(RSIBuf,0,Trade_Signal_Line,0,Trade_Signal_Type,i));   
      } 
//----
   return(0);
  }
  
double StDev(double& Data[], int Per)
{return(MathSqrt(Variance(Data,Per)));
}
double Variance(double& Data[], int Per)
{double sum, ssum;
  for (int i=0; i<Per; i++)
  {sum += Data[i];
   ssum += MathPow(Data[i],2);
  }
  return((ssum*Per - sum*sum)/(Per*(Per-1)));
}
//+------------------------------------------------------------------+
//+------------------------------------------------------------------------------------------------+
//|                                                                    We appreciate your support. | 
//+------------------------------------------------------------------------------------------------+
//|                                                               Paypal: https://goo.gl/9Rj74e    |
//|                                                             Patreon :  https://goo.gl/GdXWeN   |  
//|                                                     Buy Me a Coffee: http://tiny.cc/pjh9vz     |
//+------------------------------------------------------------------------------------------------+
//|  Cryptocurrency  |  Network                    |  Address                                      |
//+------------------------------------------------+-----------------------------------------------+
//|  USDT            |  ERC20 (ETH Ethereum)       |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7   | 
//|  USDT            |  TRC20 (Tron)               |  TTBXsfuPm2rk36AkdemY7muNXGjyziC86g           |
//|  USDT            |  BEP20 (BSC BNB Smart Chain)|  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7   |
//|  USDT            |  Matic Polygon              |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7   |
//|  USDT            |  SOL Solana                 |  3nh5rpUKopcYLNU4zGCdUFAkM3iRQq8VVUmuzVG6VDf2 |
//|  USDT            |  ARBITRUM Arbitrum One      |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7   |
//+------------------------------------------------+-----------------------------------------------+
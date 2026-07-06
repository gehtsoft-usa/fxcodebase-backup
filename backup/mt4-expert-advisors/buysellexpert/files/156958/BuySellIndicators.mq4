// More information about this indicator can be found at:
// https://fxcodebase.com/code/viewtopic.php?f=38&t=75275

//+------------------------------------------------------------------------------------------------+
//|                                                            Copyright © 2024, Gehtsoft USA LLC  | 
//|                                                                         http://fxcodebase.com  |
//+------------------------------------------------------------------------------------------------+
//|                                                                   Developed by : Mario Jemic   |                    
//|                                                                       mario.jemic@gmail.com    |
//|                                                https://appliedmachinelearning.systems/contact/ | 
//+------------------------------------------------------------------------------------------------+

//+------------------------------------------------------------------------------------------------+
//|                                           Our work would not be possible without your support. |
//+------------------------------------------------------------------------------------------------+
//|                                                               Paypal:  https://goo.gl/9Rj74e   |
//|                                                             Patreon :  http://tiny.cc/1ybwxz   |   
//|                                                      Buy Me a Coffee:  http://tiny.cc/bj7vxz   |  
//+------------------------------------------------------------------------------------------------+

#property copyright "Copyright © 2024, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"
#property version "1.0"
 
#property indicator_chart_window
#property indicator_buffers 6
#property indicator_color1 Blue
#property indicator_color2 Red
#property indicator_color3 Blue
#property indicator_color4 Red
#property indicator_color5 Blue
#property indicator_color6 Red
//---- input parameters
 
//---- buffers
double dUpRviBuffer[];
double dDownRviBuffer[];
double dUpMacdBuffer[];
double dDownMacdBuffer[];
double dUpBothBuffer[];
double dDownBothBuffer[];
 
 
int RowNum = 0;
int LastTrend = -1;
int UP_IND    = 1;
int DOWN_IND  = 0;
 
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
//---- indicator buffers mapping  
    SetIndexBuffer(0,dUpRviBuffer);
    SetIndexBuffer(1,dDownRviBuffer);   
    SetIndexBuffer(2,dUpMacdBuffer);
    SetIndexBuffer(3,dDownMacdBuffer);   
    SetIndexBuffer(4,dUpBothBuffer);
    SetIndexBuffer(5,dDownBothBuffer);   
//---- drawing settings
    SetIndexStyle(0,DRAW_ARROW);
    SetIndexArrow(0,233);
    SetIndexStyle(1,DRAW_ARROW);
    SetIndexArrow(1,234);
 
    SetIndexStyle(2,DRAW_ARROW);
    SetIndexArrow(2,241);
    SetIndexStyle(3,DRAW_ARROW);
    SetIndexArrow(3,242);
 
    SetIndexStyle(4,DRAW_ARROW);
    SetIndexArrow(4,252);
    SetIndexStyle(5,DRAW_ARROW);
    SetIndexArrow(5,252);
 
//----
    SetIndexEmptyValue(0,0.0);
    SetIndexEmptyValue(1,0.0);
    SetIndexEmptyValue(2,0.0);
    SetIndexEmptyValue(3,0.0);
    SetIndexEmptyValue(4,0.0);
    SetIndexEmptyValue(5,0.0);
//---- name for DataWindow
    SetIndexLabel(0,"Rvi Buy");
    SetIndexLabel(1,"Rvi Sell");
    SetIndexLabel(2,"Macd Buy");
    SetIndexLabel(3,"Macd Sell");
    SetIndexLabel(4,"Strong Buy");
    SetIndexLabel(5,"Strong Sell");
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Custor indicator deinitialization function                       |
//+------------------------------------------------------------------+
int deinit()
  {
//---- 
   
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int start()
  {
    int nBars,nCountedBars;
    nCountedBars=IndicatorCounted();
//---- check for possible errors
    if(nCountedBars<0) return(-1);
//---- last counted bar will be recounted    
    if(nCountedBars<=2)
       nBars=Bars-nCountedBars-3;
    if(nCountedBars>2)
      {
       nCountedBars--;
       nBars=Bars-nCountedBars-1;
      }
 
   for (int ii=0; ii<nBars; ii++)
   {
      dUpMacdBuffer[ii]=0;
      dDownMacdBuffer[ii] = 0;
      dUpRviBuffer[ii]=0;
      dDownRviBuffer[ii] = 0;
      dUpBothBuffer[ii] = 0;
      dDownBothBuffer[ii] = 0;
 
      // Check if RVI has been changed
      double val0=iRVI(NULL, 0, 10,MODE_MAIN,ii);
      double sig0=iRVI(NULL, 0, 10,MODE_SIGNAL,ii);
      
      double val1=iRVI(NULL, 0, 10,MODE_MAIN,ii+1);
      double sig1=iRVI(NULL, 0, 10,MODE_SIGNAL,ii+1);
      
      if ((val0 > sig0) && (val1 < sig1))
      {
         dUpRviBuffer[ii] = Low[ii] - 2 * MarketInfo(Symbol(),MODE_POINT);
      }
      if ((val0 < sig0) && (val1 > sig1))
      {
         dDownRviBuffer[ii] = High[ii] + 2 * MarketInfo(Symbol(),MODE_POINT);
     }   
 
      // Check if MACD has been changed
      double valm0=iMACD(NULL,0,12,26,9,PRICE_CLOSE,MODE_MAIN,ii);
      double sigm0=iMACD(NULL,0,12,26,9,PRICE_CLOSE,MODE_SIGNAL,ii);
      
      double valm1=iMACD(NULL,0,12,26,9,PRICE_CLOSE,MODE_MAIN,ii+1);
      double sigm1=iMACD(NULL,0,12,26,9,PRICE_CLOSE,MODE_SIGNAL,ii+1);
      
      if ((valm0 > sigm0) && (valm1 < sigm1))
      {
         dUpMacdBuffer[ii] = Low[ii] - 0.0004;
      }
      if ((valm0 < sigm0) && (valm1 > sigm1))
      {
         dDownMacdBuffer[ii] = High[ii] + 2 * MarketInfo(Symbol(),MODE_POINT);
      }
      
      if ((dUpRviBuffer[ii] != 0) && (dUpMacdBuffer[ii]))
      {
	    dUpMacdBuffer[ii] = 0;
	    dUpRviBuffer[ii] = 0;
            dUpBothBuffer[ii] = Low[ii] - 2 * MarketInfo(Symbol(),MODE_POINT);
            if ((Period() >= 60) && (ii == 0))
            {
               Print("Buy alert");
               PlaySound("alert2.wav");
            }
      }
      if ((dDownRviBuffer[ii] != 0) && (dDownMacdBuffer[ii]))
      {
	 dDownMacdBuffer[ii] = 0;
	 dDownRviBuffer[ii] = 0;
         dDownBothBuffer[ii] = High[ii] + 2 * MarketInfo(Symbol(),MODE_POINT);
         if ((Period() >= 60) && (ii == 0))
         {
            Print("Sell alert");
            PlaySound("alert2.wav");
         }
      }
   }
 
}

//+------------------------------------------------------------------------------------------------+
//|                                                                    We appreciate your support. | 
//+------------------------------------------------------------------------------------------------+
//|                                                               Paypal:  https://goo.gl/9Rj74e   |
//|                                                             Patreon :  http://tiny.cc/1ybwxz   |   
//|                                                      Buy Me a Coffee:  http://tiny.cc/bj7vxz   |  
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

//Available @ https://fxcodebase.com/code/viewtopic.php?f=38&t=73755

//+------------------------------------------------------------------------------------------------+
//|                                                            Copyright © 2023, Gehtsoft USA LLC  | 
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


#property copyright "Copyright © 2023, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"
#property version "1.0"
//----
#property indicator_separate_window
#property indicator_buffers 1
#property indicator_color1 SkyBlue
#property indicator_width1 2
//---- input parameters
extern int     Price         =0;   //Apply to Price(0-Close;1-Open;2-High;3-Low;4-Median price;5-Typical price;6-Weighted Close) 
extern int     Length        =14;  //Period of NonLagMA
//---- indicator buffers
double RegSlope[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
  int init()
  {
   SetIndexStyle(0,DRAW_LINE);
   SetIndexBuffer(0,RegSlope);
   string short_name;
//---- indicator line
   IndicatorDigits(MarketInfo(Symbol(),MODE_DIGITS));
//---- name for DataWindow and indicator subwindow label
   short_name="LinearRegSlope("+Length+")";
   IndicatorShortName(short_name);
   SetIndexLabel(0,"LinearRegSlope");
   SetIndexDrawBegin(0,Length);
   //----
   SetLevelValue(0, 0);   
   SetLevelStyle(STYLE_SOLID, 1, DimGray);
   //--- 
   return(0);
  }
//+------------------------------------------------------------------+
//| LinearRegSlope_v1                                                |
//+------------------------------------------------------------------+
int start()
  {
   int    i,shift, counted_bars=IndicatorCounted(),limit;
   double price;
   if(counted_bars > 0) limit=Bars-counted_bars;
   if(counted_bars < 0) return(0);
   if(counted_bars ==0) limit=Bars-Length-1;
   if(counted_bars < 1)
      for(i=1;i<Length;i++) RegSlope[Bars-i]=0;
   double SumBars=Length * (Length - 1) * 0.5;
   double SumSqrBars=(Length - 1.0) * Length * (2.0 * Length - 1.0)/6.0;
   for(shift=limit;shift>=0;shift--)
     {
      double Sum1=0;
      for(i=0;i<=Length-1;i++) Sum1+=i*iMA(NULL,0,1,0,1,Price,i+shift);
      double SumY=0;
      for(i=0;i<=Length-1;i++) SumY+=iMA(NULL,0,1,0,1,Price,i+shift);
      double Sum2=SumBars * SumY;
      double Num1=Length * Sum1 - Sum2;
      double Num2=SumBars * SumBars - Length * SumSqrBars;
      if(Num2!=0)
         RegSlope[shift]=100*Num1/Num2;
      else
          RegSlope[shift] = 0;


      int bars = 500;
      double max = RegSlope[ArrayMaximum(RegSlope, bars, 0)];
      SetLevelValue(1, max);
      SetLevelValue(2, -max);
   }
//----
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
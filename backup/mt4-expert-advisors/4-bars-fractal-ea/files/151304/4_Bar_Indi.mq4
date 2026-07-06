// More information about this indicator can be found at:
// https://fxcodebase.com/code/viewtopic.php?f=38&t=73846

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
#property strict
#property indicator_chart_window

#property indicator_buffers   4

#property indicator_color1 clrBlue
#property indicator_color2 clrBlue
#property indicator_color3 clrRed
#property indicator_color4 clrRed

#property indicator_width1 2
#property indicator_width2 2
#property indicator_width3 2
#property indicator_width4 2

extern   bool        SoundAlert  =  false;


double up[], up_dot[];
double down[], down_dot[];

static datetime prevtime=0;
double Range,AvgRange;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- indicator buffers mapping
      SetIndexBuffer(0,up);
      SetIndexStyle(0,DRAW_ARROW);
      SetIndexArrow(0,241);
      SetIndexLabel(0,"Buy");
      
      SetIndexBuffer(1,up_dot);
      SetIndexStyle(1,DRAW_ARROW);
      SetIndexArrow(1,108);
      SetIndexLabel(1,"Buy");
      
      SetIndexBuffer(2,down);
      SetIndexStyle(2,DRAW_ARROW);
      SetIndexArrow(2,242);
      SetIndexLabel(2,"Sell");
      
      SetIndexBuffer(3,down_dot);
      SetIndexStyle(3,DRAW_ARROW);
      SetIndexArrow(3,108);
      SetIndexLabel(3,"Sell");
      
      SetIndexDrawBegin(0,10);
      SetIndexDrawBegin(1,10);
      SetIndexDrawBegin(2,10);
      SetIndexDrawBegin(3,10);
      
      IndicatorSetString(INDICATOR_SHORTNAME,"4 Bar");
      
      if(ChartGetInteger(0,CHART_FOREGROUND))
      ChartSetInteger(0,CHART_FOREGROUND,false);
//---

   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
  {
//---
   
   int i = 1;
   
   if(rates_total>prev_calculated)      
     while(i <= rates_total-prev_calculated){
      // Arrow Place Space -------------------------------
         int counter=i;
         Range=0;
         AvgRange=0;
         
         if(i+9 < rates_total)
         for(counter=i;counter<=i+9;counter++)
         {
            AvgRange=AvgRange+MathAbs(High[counter]-Low[counter]);
         }
         Range=AvgRange/10;
         
      // -----------------------------------------------
      if(i+3 <= rates_total){
      if(Close[i]>Open[i] && Close[i]>High[i+1] && Close[i]>High[i+3]){
      up[i] = Low[i]-Range*0.5;
      up_dot[i] = Close[i];   
      }
      
      if(Close[i]<Open[i] && Close[i]<Low[i+1] && Close[i]<Low[i+3]){
      down[i] = High[i]+Range*0.5;
      down_dot[i] = Close[i];
      }
     }
      
      i++;
      
     }
     
     // Signal Alert -------------------------  
      if(up[1]!=EMPTY_VALUE && prevtime!=Time[0] && SoundAlert){
         prevtime=Time[0];
         Alert(Symbol()," 4 Bar Buy");
         //PlaySound ("alert.wav");
      } 
      
      if(down[1]!=EMPTY_VALUE && prevtime!=Time[0] && SoundAlert){
         prevtime=Time[0];
         Alert(Symbol()," 4 Bar Sell");
         //PlaySound ("alert.wav");
      } 
   
//--- return value of prev_calculated for next call
   return(rates_total);
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
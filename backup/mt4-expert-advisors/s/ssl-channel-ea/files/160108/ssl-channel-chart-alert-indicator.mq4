// More information about this indicator can be found at:
// https://fxcodebase.com/code/viewtopic.php?f=38&p=147153#p147153

//+------------------------------------------------------------------------------------------------+
//|                                                            Copyright © 2025, Gehtsoft USA LLC  |
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

#property copyright "Copyright © 2025, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"
#property version   "1.10"
//----
#property indicator_chart_window
#property indicator_buffers 2
#property indicator_color1 Red
#property indicator_color2 DeepSkyBlue
#property indicator_width1 2
#property indicator_width2 2
//----
extern int  Lb           =10;
extern bool alertsOn     =false;
extern bool alertsMessage=true;
extern bool alertsSound  =false;
extern bool alertsEmail  =false;
//----
double ssld[];
double sslu[];
double Hlv[];
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int init()
  {
   IndicatorBuffers(3);
   SetIndexBuffer(0,ssld); SetIndexDrawBegin(0,Lb+1);
   SetIndexBuffer(1,sslu); SetIndexDrawBegin(0,Lb+1);
   SetIndexBuffer(2,Hlv);
   return(0);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int start()
  {
   int counted_bars=IndicatorCounted();
   int i,limit;
//----
   if(counted_bars<0) return(-1);
   if(counted_bars>0) counted_bars--;
   limit=Bars-counted_bars;
//----
   for(i=limit;i>=0;i--)
     {
      Hlv[i]=Hlv[i+1];
      if(Close[i]>iMA(Symbol(),0,Lb,0,MODE_SMA,PRICE_HIGH,i+1)) Hlv[i]= 1;
      if(Close[i]<iMA(Symbol(),0,Lb,0,MODE_SMA,PRICE_LOW,i+1))  Hlv[i]=-1;
      if(Hlv[i]==-1)
        {
         ssld[i]=iMA(Symbol(),0,Lb,0,MODE_SMA,PRICE_HIGH,i+1);
         sslu[i]=iMA(Symbol(),0,Lb,0,MODE_SMA,PRICE_LOW ,i+1);
        }
      else
        {
         ssld[i]=iMA(Symbol(),0,Lb,0,MODE_SMA,PRICE_LOW ,i+1);
         sslu[i]=iMA(Symbol(),0,Lb,0,MODE_SMA,PRICE_HIGH,i+1);
        }
     }
//----
   if (alertsOn)
      if (Hlv[0]!=Hlv[1])
         if (Hlv[0]==1)
            doAlert("up");
         else  doAlert("down");
//----
   return(0);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void doAlert(string doWhat)
  {
   static string   previousAlert="nothing";
   static datetime previousTime;
   string message;
//----
     if (previousAlert!=doWhat || previousTime!=Time[0]) 
     {
      previousAlert =doWhat;
      previousTime  =Time[0];
//----
      message= StringConcatenate(Symbol()," at ",TimeToStr(TimeLocal(),TIME_SECONDS)," SSL trend changed to ",doWhat);
      if (alertsMessage) Alert(message);
      if (alertsEmail)   SendMail(StringConcatenate(Symbol(),"SSL "),message);
      if (alertsSound)   PlaySound("alert2.wav");
     }
  }
//+------------------------------------------------------------------+
// More information about this indicator can be found at:
// https://fxcodebase.com/code/viewtopic.php?f=38&p=147153#p147153

//+------------------------------------------------------------------------------------------------+
//|                                                            Copyright © 2025, Gehtsoft USA LLC  |
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
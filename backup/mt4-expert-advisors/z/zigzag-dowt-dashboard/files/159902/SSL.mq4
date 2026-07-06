//Available @  https://fxcodebase.com/code/viewtopic.php?f=38&p=159874#p159874

// +------------------------------------------------------------------------------------------------+
// |                                                            Copyright © 2025, Gehtsoft USA LLC   | 
// |                                                                         http://fxcodebase.com   |
// |                                                               PayPal: https://goo.gl/9Rj74e     |
// +------------------------------------------------------------------------------------------------+
// |                                                                   Developed by: Mario Jemic     |                    
// |                                                                     mario.jemic@gmail.com       |
// |                                                                 https://mario-jemic.com/        | 
// |                                                             Patreon: http://tiny.cc/1ybwxz      |   
// |                                                      Buy Me a Coffee: http://tiny.cc/bj7vxz     |  
// +-----------------+----------------------+---------------------------------------------------------+
// |  Cryptocurrency |  Network             |  Address                                                |
// +-----------------+----------------------+---------------------------------------------------------+
// |  BTC            |  BTC                 |  16F5k43RXibTmna4np8bPVgmXM1CzjXFJJ                     | 
// |  SOL            |  SOL                 |  3nh5rpUKopcYLNU4zGCdUFAkM3iRQq8VVUmuzVG6VDf2           | 
// |  ETH            |  ERC20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7             |
// |  BNB            |  BEP20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7             | 
// |  USDT           |  BEP20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7             | 
// |  XRP            |  BEP20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7             | 
// +-----------------+----------------------+---------------------------------------------------------+


#property copyright "Copyright © 2025, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"
#property version "1.0"

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
//Available @  https://fxcodebase.com/code/viewtopic.php?f=38&p=159874#p159874

// +------------------------------------------------------------------------------------------------+
// |                                                            Copyright © 2025, Gehtsoft USA LLC   | 
// |                                                                         http://fxcodebase.com   |
// |                                                               PayPal: https://goo.gl/9Rj74e     |
// +------------------------------------------------------------------------------------------------+
// |                                                                   Developed by: Mario Jemic     |                    
// |                                                                     mario.jemic@gmail.com       |
// |                                                                 https://mario-jemic.com/        | 
// |                                                             Patreon: http://tiny.cc/1ybwxz      |   
// |                                                      Buy Me a Coffee: http://tiny.cc/bj7vxz     |  
// +-----------------+----------------------+---------------------------------------------------------+
// |  Cryptocurrency |  Network             |  Address                                                |
// +-----------------+----------------------+---------------------------------------------------------+
// |  BTC            |  BTC                 |  16F5k43RXibTmna4np8bPVgmXM1CzjXFJJ                     | 
// |  SOL            |  SOL                 |  3nh5rpUKopcYLNU4zGCdUFAkM3iRQq8VVUmuzVG6VDf2           | 
// |  ETH            |  ERC20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7             |
// |  BNB            |  BEP20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7             | 
// |  USDT           |  BEP20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7             | 
// |  XRP            |  BEP20               |  0xe53aab6bc468a963a02d1319660ee60cf80fc8e7             | 
// +-----------------+----------------------+---------------------------------------------------------+
// More information about this indicator can be found at:
// https://fxcodebase.com/code/viewtopic.php?f=38&t=71787

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
//---- indicator settings
#property  indicator_separate_window
#property  indicator_buffers 2
#property  indicator_color1  DodgerBlue
#property  indicator_color2  Red

//---- indicator parameters
extern int AroonPeriod = 14;
extern bool MailAlert = true;  //Alerts will be mailed to address set in MT4 options
extern bool SoundAlert = true; //Alerts will sound on indicator cross

//---- indicator buffers
double     AroonUpBuffer[];
double     AroonDnBuffer[];

int LastBars = 0;

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
   //---- 2 additional buffers are used for counting.
   IndicatorBuffers(4);
   SetIndexBuffer(0, AroonUpBuffer);
   SetIndexBuffer(1, AroonDnBuffer);

   //---- drawing settings
   SetIndexStyle(0,DRAW_LINE,STYLE_SOLID,1);
   SetIndexStyle(1,DRAW_LINE,STYLE_SOLID,1);
  SetIndexDrawBegin(0,200);
  SetIndexDrawBegin(1,200);
   IndicatorDigits(1);
   
   //---- name for DataWindow and indicator subwindow label
   IndicatorShortName("Aroon Up & Dn("+(string)AroonPeriod+")");
   //---- initialization done
   return(0);
  }
//+------------------------------------------------------------------+
//| Aroon Up & Dn                                                    |
//+------------------------------------------------------------------+
int start()  
  {
   int      ArPer,limit,i;     
   int      UpBarDif,DnBarDif;
   int      counted_bars=IndicatorCounted(); 
   ArPer=AroonPeriod;                  //Short name
   
   //---- check for possible errors
   if(counted_bars<0) return(-1);
   if(AroonPeriod<1) return(-1);      
   //---- initial zero
   if(counted_bars<1)
     {
      for(i=1;i<=ArPer;i++) AroonUpBuffer[Bars-i]=0.0;
      for(i=1;i<=ArPer;i++) AroonDnBuffer[Bars-i]=0.0;
     } 

   //---- last counted bar will be recounted
   if(counted_bars>0) counted_bars--;
   limit=Bars-counted_bars;

   //----Calculation---------------------------
   for( i=0; i<limit; i++)
   {
  	   int HH = Highest(NULL,0,MODE_HIGH,ArPer,i);   //Periods from HH  	   
  	   int LL = Lowest(NULL,0,MODE_LOW,ArPer,i);		  //Periods from LL

      UpBarDif = i-HH;	                       //Period substraction
      DnBarDif = i-LL;	                          //Period substraction
      
      AroonUpBuffer[i]=100+(100/ArPer)*(UpBarDif);            //Adjusted Aroon Up
      AroonDnBuffer[i]=100+(100/ArPer)*(DnBarDif);            //Adjusted Aroon Down

      if (LastBars != Bars)
      {
//         if ((AroonUpBuffer[0] > AroonDnBuffer[0]) && (AroonUpBuffer[1] <= AroonDnBuffer[1]))
         if (AroonUpBuffer[0] >= 100 && AroonDnBuffer[0] <=30)
         {
            if (MailAlert) SendMail("Aroon Up & Down Indicator Alert", "The indicator produced a cross (Blue ABOVE Red) on " + Year() + "-" + Month() + "-" + Day() + " " + Hour() + ":" + Minute());
            if (SoundAlert) Alert("Aroon Up & Down produced a cross (Blue ABOVE Red)");
         }
//         else if ((AroonUpBuffer[0] < AroonDnBuffer[0]) && (AroonUpBuffer[1] >= AroonDnBuffer[1]))
         else if (AroonUpBuffer[0] <= 30 && AroonUpBuffer[0] >= 100)
         {
            if (MailAlert) SendMail("Aroon Up & Down Indicator Alert", "The indicator produced a cross (Blue BELOW Red) on " + Year() + "-" + Month() + "-" + Day() + " " + Hour() + ":" + Minute());
            if (SoundAlert) Alert("Aroon Up & Down produced a cross (Blue BELOW Red)");
         }
         LastBars = Bars;
      }
   }
   return(0);
  }
  
// More information about this indicator can be found at:
// http://fxcodebase.com/ 

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
//---- indicator settings
#property  indicator_chart_window
#property  indicator_buffers 7
#property  indicator_color1  Red
#property  indicator_color2  DodgerBlue

//---- indicator parameters
extern int ADXPeriod=14;
//---- indicator buffers
double     ind_buffer1[];
double     ind_buffer2[];
//double     ind_buffer3[];
double        HighBarBuffer[];
double        LowBarBuffer[];
double     ArOscBuffer[];
double b4plusdi,b4minusdi,nowplusdi,nowminusdi;
double blue  [ ]; 
double  red [];

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
//----additional buffers are used for counting.
   IndicatorBuffers(7);
   SetIndexBuffer(2,HighBarBuffer);
   SetIndexBuffer(3,LowBarBuffer);
   SetIndexBuffer(4,ArOscBuffer);
//---- drawing settings
   SetIndexStyle(0,DRAW_HISTOGRAM,STYLE_SOLID,2);
   SetIndexStyle(1,DRAW_HISTOGRAM,STYLE_SOLID,2);
//SetIndexDrawBegin(0,1500);
//SetIndexDrawBegin(1,1500);  
   IndicatorDigits(MarketInfo(Symbol(),MODE_DIGITS)+1);
//---- indicator buffers mapping
   SetIndexBuffer(0,ind_buffer1);
   SetIndexBuffer(1,ind_buffer2);
   SetIndexBuffer(2,HighBarBuffer);
   SetIndexBuffer(3,LowBarBuffer);
   SetIndexBuffer(4,ArOscBuffer);
      SetIndexBuffer(5, blue   ) ; 
   SetIndexLabel(5,"blue");
   SetIndexBuffer   ( 6,  red ) ;
   SetIndexLabel(6,"red");
//---- name for DataWindow and indicator subwindow label
//---- initialization done
   return(0);
  }
//+------------------------------------------------------------------+
//| Aroon Oscilator                                                  |
//+------------------------------------------------------------------+
int start()
  {
      //ArraySetAsSeries(white,false);
   //ArraySetAsSeries(red,false);
   double   ArOsc=0;
   int      ArPer,i;
   int counted_bars=IndicatorCounted();
   if(counted_bars<0) return(-1);
   if(counted_bars>0) counted_bars--;
   int limit=Bars-counted_bars;
   if(counted_bars==0) limit-=1+ADXPeriod;
//----Calculation---------------------------
   for(i=1; i<limit; i++)
     {
      // b4plusdi = iADX( NULL,0,14,PRICE_CLOSE,MODE_PLUSDI,i-1);
      nowplusdi=iADX(NULL,0,ADXPeriod,PRICE_CLOSE,MODE_PLUSDI,i);
      //b4minusdi = iADX(NULL,0,14,PRICE_CLOSE,MODE_MINUSDI,i-1);
      nowminusdi=iADX(NULL,0,ADXPeriod,PRICE_CLOSE,MODE_MINUSDI,i);
      //----
      if(nowminusdi>nowplusdi)
        {
       
red[i]    =   1;
ind_buffer2[i]=Low[i];
ind_buffer1[i]=High[i];
        }
      if(nowplusdi>nowminusdi)
        {
          //ObjectCreate("teee"+i, OBJ_VLINE, 0, Time[i], 0); 

blue[i]    =   2; 
ind_buffer1[i]=Low[i];
ind_buffer2[i]=High[i];
        }
     }
//---- done
   return(0);
  }
//+------------------------------------------------------------------+

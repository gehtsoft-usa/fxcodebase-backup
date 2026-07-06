// More information about this indicator can be found at:
//https://fxcodebase.com/code/viewtopic.php?f=38&t=71813
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
#property indicator_chart_window

//---- input parameters
extern int DAYS=5;
enum EnableDisable
   {
   Enable = 0,
   Disable = 1
   };

extern    EnableDisable    AlertSendNotification   =   Enable    ;   //  Alert Send Notification
//---- Variables
double yesterday_close,Current_price;
double phigh,plow,plownew;
int i=1;

//---- Buffers
double daily_high[20] ;
double daily_low[20] ;


string    upcommingSignal     =   "NONE"   ;  
datetime   NewCandleTimeCurrent    ;  

extern  color  above_line_color    =     clrGreen ;   //  Above Line Color
extern  color  below_line_color    =  clrRed  ;   //  Below Line Color

extern int  above_line_width    =  1   ;    //  Above Line Width 
extern int  below_line_width    =  1;       //  Below Line Width 



//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int   index  = 0  ;
int init()
   {
//---- indicators
//----
      return(0);
   }

//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
int deinit()
   {
//----
     ObjectDelete( "5dayHigh" );
      ObjectDelete( "5dayLow" );
//----
      return(0);
   }

//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int start()
   {
      int    counted_bars=IndicatorCounted();
//----
      Current_price= MarketInfo( Symbol(), MODE_BID);
//---- TODO: add your code here
      ArrayResize( daily_high, DAYS);
      ArrayResize( daily_low, DAYS);
      ArrayInitialize( daily_high, 0);
      ArrayInitialize( daily_low, 0);
      ArrayCopySeries( daily_low, MODE_LOW, Symbol(), PERIOD_D1);
      ArrayCopySeries( daily_high, MODE_HIGH, Symbol(), PERIOD_D1);
/* initialise */
      plow = daily_low[ 1];
      phigh = daily_high[1];
      for(i=1;i<DAYS; i++)
         {
            if(plow > daily_low[i])
               {
                  plow = daily_low[i] ;
               }
         }
      for(i=1;i<DAYS; i++)
         {
            if(phigh < daily_high[i])
               {
                  phigh = daily_high[ i];
               }
         }

      Comment("\n5dayH ",phigh,"\n5dayL ",plow);

      ObjectDelete( "5dayHigh" );
      ObjectDelete( "5dayLow" );

ObjectCreate( "5dayHigh" , OBJ_HLINE,0, CurTime(),phigh) ;
ObjectSetInteger(0 ,  "5dayHigh",OBJPROP_COLOR,above_line_color );
ObjectSetInteger(0 ,"5dayHigh",OBJPROP_WIDTH,above_line_width);
ObjectSetInteger (   0 ,   "5dayHigh",OBJPROP_STYLE,STYLE_SOLID);

ObjectCreate( 0  ,  "5dayLow" , OBJ_HLINE,0, CurTime(),plow) ;
ObjectSetInteger(   0 ,  "5dayLow" ,OBJPROP_COLOR,below_line_color  ) ;
ObjectSetInteger(  0  ,"5dayLow",OBJPROP_WIDTH,below_line_width);
ObjectSetInteger(   0 , "5dayLow" ,OBJPROP_STYLE,STYLE_SOLID);

      ObjectsRedraw( );
if  (  AlertSendNotification    ==   Enable)
{
      if (Bid >= phigh   && upcommingSignal     ==   "NONE"    )
         {
         upcommingSignal     =  "ACTIVATED";  
         Comment  (Symbol( ), " has hit a 5 day HIGH. Bounce or Breakout?"," -",phigh     )  ;           
            Alert(Symbol( ), " has hit a 5 day HIGH. Bounce or Breakout?"," -",phigh);
           SendNotification(Symbol()+" has hit a 5 day HIGH. Bounce or Breakout?"+" -"+phigh);

         }


      if  (  Bid    <=phigh-fx_pips_evaluation(Symbol())*10*Point()   &&    Bid     >  phigh-fx_pips_evaluation(Symbol())*20*Point()   ){
         
      
     upcommingSignal    =  "NONE";
      }


  


      if (Bid <= plow   &&  upcommingSignal    ==   "NONE"      )
         {
            Comment (Symbol( ), " has hit a 5 day LOW. Bounce or Breakout?"," -",plow  );
            upcommingSignal     =  "ACTIVATED";  
            Alert(Symbol( ), " has hit a 5 day LOW. Bounce or Breakout?"," -",plow);
            SendNotification(Symbol( )+ " has hit a 5 day LOW. Bounce or Breakout?"+" -"+plow);

              
         
         }
       if   (  Bid >=  plow+ fx_pips_evaluation(Symbol())*10*Point()  &&   Bid   <=   plow    +  fx_pips_evaluation(Symbol())* 20*Point()    )   {
               upcommingSignal       =   "NONE";
      }

   }
      return(0);
   }







int fx_pips_evaluation(string  symbol_mapping )
   {
   int digits = (int)MarketInfo(symbol_mapping, MODE_DIGITS);
   if(digits == 2)
   {
   return   100;
   }
   else
   if(digits ==  1)
   {
   return  10 ;
   }
   else
   if(digits ==  4  ||  digits == 5 ||  digits == 3)
   {
   return 10;
   }
   else
   {
   return  1;
   }
   return 0;
   }
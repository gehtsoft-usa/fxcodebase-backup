// More information about this indicator can be found at:
// https://fxcodebase.com/code/viewtopic.php?f=38&t=72005

//+------------------------------------------------------------------------+
//|                                    Copyright © 2021, Gehtsoft USA LLC  |
//|                                                 http://fxcodebase.com  |
//+------------------------------------------------------------------------+
//|                                      Support our efforts by donating   |
//|                                         Paypal: https://goo.gl/9Rj74e  |
//+------------------------------------------------------------------------+
//|                                           Developed by : Mario Jemic   |
//|                                               mario.jemic@gmail.com    |
//|                                https://AppliedMachineLearning.systems  |
//|                                     Patreon :  https://goo.gl/GdXWeN   |
//+------------------------------------------------------------------------+

//+------------------------------------------------------------------------+
//|BitCoin Address            : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF         |
//|Ethereum Address           : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D |
//|Dogecoin Address           : DNDTFfmVa2Gjts5YvSKEYaiih6cums2L6C         |
//|Binance(ERC20 & BSC only)  : 0xe84751063de8ade7c5fbff5e73f6502f02af4e2c |
//|Binance Address (BEP2 only): bnb136ns6lfw4zs5hg4n85vdthaad7hq5m4gtkgf23 |
//|Binance MEMO (BEP2 only)   : 107152697                                  |
//|LiteCoin Address           : LLU8PSY2vsq7B9kRELLZQcKf5nJQrdeqwD         |
//+------------------------------------------------------------------------+


#property copyright "Copyright © 2021, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"
#property version   "1.0"
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+

input string InpToken= "1713382528:AAHoApYKcGBuTLyvgfFfDD5FgRzC2JkcLoA";//  Telegram Token
//5145766648:AAGWa_vZhqigpYIs_uJNTFygUOWpE7ML_1k
//"1713382528:AAHoApYKcGBuTLyvgfFfDD5FgRzC2JkcLoA";
input string  channel_id  =  "-1001534350961";// Telegram channel Id
string  Initial_Value   =   "NONE";

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int OnInit()
  {
//---
//  Setting initial Value
   string name;
   string output[];
   int i;
   for(int i =ObjectsTotal(NULL, 0,OBJ_EDIT) - 1; i >= 0; i--)
     {
      name = ObjectName(NULL, i, 0, OBJ_EDIT);
      int k = StringSplit(name, StringGetCharacter("_", 0), output);
      if(ArraySize(output)  > 1)
        {
         if(output[0]   ==   "Tester")
           {
            Initial_Value    =   name    ;
           }

        }
     }
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//---

  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {

   string name;
   string output[];
   int i;
   for(int i =ObjectsTotal(NULL, 0,OBJ_EDIT) - 1; i >= 0; i--)
     {
      name = ObjectName(NULL, i, 0, OBJ_EDIT);
      int k = StringSplit(name, StringGetCharacter("_", 0), output);
      if(ArraySize(output)  > 1)
        {
         if(output[0]   ==   "Tester")
           {
            if(Initial_Value   !=    name)
              {
               ObjectDelete(0,  Initial_Value);
               Initial_Value    =    name;
               fx_web_request_telegram(ObjectGetString(0,name,OBJPROP_TEXT,0))    ;
              }



           }

        }
     }





//---



  }
//+------------------------------------------------------------------+



//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int fx_web_request_telegram(string OrderType)
  {
   string headers;
   char post[], result[];
   string url  =   StringFormat("https://api.telegram.org/bot"+InpToken+"/sendMessage?chat_id="+channel_id+"&text=Symbol :","");
   int res = WebRequest("POST", url   +Symbol()  +  ",Order Type:" + OrderType, "", NULL, 10000, post, ArraySize(post), result, headers);
   string  server_response_data   =CharArrayToString(result);
   if(res  == 200)
     {
      return true;
     }
   else
     {

      return false;
     }
  }
//+------------------------------------------------------------------+

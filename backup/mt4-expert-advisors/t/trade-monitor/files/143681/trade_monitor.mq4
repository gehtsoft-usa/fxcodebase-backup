// More information about this indicator can be found at:
//https://fxcodebase.com/code/viewtopic.php?f=38&t=71517

//+------------------------------------------------------------------------------------------------+
//|                                                            Copyright © 2021, Gehtsoft USA LLC  |
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

//+------------------------------------------------------------------------------------------------+
//|BitCoin Address            : 15VCJTLaz12Amr7adHSBtL9v8XomURo9RF                                 |
//|Ethereum Address           : 0x8C110cD61538fb6d7A2B47858F0c0AaBd663068D                         |
//|Cardano/ADA                : addr1v868jza77crzdc87khzpppecmhmrg224qyumud6utqf6f4s99fvqv         |
//|Dogecoin Address           : DNDTFfmVa2Gjts5YvSKEYaiih6cums2L6C                                 |
//|Binance(ERC20 & BSC only)  : 0xe84751063de8ade7c5fbff5e73f6502f02af4e2c                         |
//+------------------------------------------------------------------------------------------------+

#property copyright "Copyright © 2021, Gehtsoft USA LLC"
#property link      "http://fxcodebase.com"
#property version   "1.0"

#property strict

//Signaler v2.0
// More templates and snippets on https://github.com/sibvic/mq4-templates
input string   AlertsSection            = ""; // == Alerts ==
input bool     popup_alert              = false; // Popup message
input bool     notification_alert       = false; // Push notification
input bool     email_alert              = false; // Email
input bool     play_sound               = false; // Play sound on alert
input string   sound_file               = ""; // Sound file
input bool     start_program            = false; // Start external program
input string   program_path             = ""; // Path to the external program executable
input bool     advanced_alert           = false; // Advanced alert (Telegram/Discord/other platform (like another MT4))
input string   advanced_key             = ""; // Advanced alert key
input string   Comment2                 = "- You can get a key via @profit_robots_bot Telegram Bot. Visit ProfitRobots.com for discord/other platform keys -";
input string   Comment3                 = "- Allow use of dll in the indicator parameters window -";
input string   Comment4                 = "- Install AdvancedNotificationsLib.dll -";

// AdvancedNotificationsLib.dll could be downloaded here: http://profitrobots.com/Home/TelegramNotificationsMT4
#import "AdvancedNotificationsLib.dll"
void AdvancedAlert(string key, string text, string instrument, string timeframe);
#import
#import "shell32.dll"
int ShellExecuteW(int hwnd,string Operation,string File,string Parameters,string Directory,int ShowCmd);
#import

class Signaler
{
   string _prefix;
public:
   Signaler()
   {
   }

   void SetMessagePrefix(string prefix)
   {
      _prefix = prefix;
   }

   void SendNotifications(const string subject, string message = NULL)
   {
      if (message == NULL)
         message = subject;
      if (_prefix != "" && _prefix != NULL)
         message = _prefix + message;

      if (start_program)
         ShellExecuteW(0, "open", program_path, "", "", 1);
      if (popup_alert)
         Alert(message);
      if (email_alert)
         SendMail(subject, message);
      if (play_sound)
         PlaySound(sound_file);
      if (notification_alert)
         SendNotification(message);
      if (advanced_alert && advanced_key != "" && !IsTesting())
         AdvancedAlert(advanced_key, message, "", "");
   }
};

// Trades monitor v3.0

// Action v2.0

#ifndef IAction_IMP
#define IAction_IMP

interface IAction
{
public:
   virtual void AddRef() = 0;
   virtual void Release() = 0;
   
   virtual bool DoAction(const int period, const datetime date) = 0;
};

#endif
#ifndef TradingMonitor_IMP
#define TradingMonitor_IMP

class TradingMonitor
{
   int active_ticket[1000];
   double active_type[1000];
   double active_price[1000];
   double active_stoploss[1000];
   double active_takeprofit[1000];
   bool active_still_active[1000];
   int active_total;
   IAction* _closedTradeAction;
   IAction* _orderChangedAction;
   IAction* _newOrderAction;
public:
   TradingMonitor()
   {
      _closedTradeAction = NULL;
      _orderChangedAction = NULL;
      _newOrderAction = NULL;
   }

   ~TradingMonitor()
   {
      if (_closedTradeAction != NULL)
         _closedTradeAction.Release();
      if (_orderChangedAction != NULL)
         _orderChangedAction.Release();
      if (_newOrderAction != NULL)
         _newOrderAction.Release();
   }

   void SetClosedTradeAction(IAction* action)
   {
      if (_closedTradeAction != NULL)
         _closedTradeAction.Release();
      _closedTradeAction = action;
      if (_closedTradeAction != NULL)
         _closedTradeAction.AddRef();
   }

   void SetOnOrderChanged(IAction* action)
   {
      if (_orderChangedAction != NULL)
         _orderChangedAction.Release();
      _orderChangedAction = action;
      if (_orderChangedAction != NULL)
         _orderChangedAction.AddRef();
   }

   void SetOnNewOrder(IAction* action)
   {
      if (_newOrderAction != NULL)
         _newOrderAction.Release();
      _newOrderAction = action;
      if (_newOrderAction != NULL)
         _newOrderAction.AddRef();
   }

   void DoWork()
   {
      bool changed = false;
      int total = OrdersTotal();
      for (int i = 0; i < total; i++)
      {
         if (!OrderSelect(i, SELECT_BY_POS, MODE_TRADES))
            continue;
         int ticket = OrderTicket();
         int index = getOrderCacheIndex(ticket);
         if (index == -1)
         {
            changed = true;
            if (_newOrderAction != NULL)
               _newOrderAction.DoAction(0, 0);
         }
         else
         {
            active_still_active[index] = true; // order is still there
            if (OrderOpenPrice() != active_price[index] ||
                  OrderStopLoss() != active_stoploss[index] ||
                  OrderTakeProfit() != active_takeprofit[index] ||
                  OrderType() != active_type[index])
            {
               changed = true;
               if (_orderChangedAction != NULL)
                  _orderChangedAction.DoAction(0, 0);
            }
         }
      }

      for (int index = 0; index < active_total; index++)
      {
         if (active_still_active[index] == false)
         {
            changed = true;
            if (_closedTradeAction != NULL && OrderSelect(active_ticket[index], MODE_HISTORY))
               _closedTradeAction.DoAction(0, 0);
         }
         
         active_still_active[index] = false;
      }
      if (changed)
         updateActiveOrders();
   }
private:
   int getOrderCacheIndex(const int ticket)
   {
      for (int i = 0; i < active_total; i++)
      {
         if (active_ticket[i] == ticket)
            return i;
      }
      return -1;
   }

   /**
   * read in the current state of all open orders 
   * and trades so we can track any changes in the next tick
   */ 
   void updateActiveOrders()
   {
      active_total = OrdersTotal();
      for (int i = 0; i < active_total; i++)
      {
         if (!OrderSelect(i, SELECT_BY_POS, MODE_TRADES))
            continue;
         active_ticket[i] = OrderTicket();
         active_type[i] = OrderType();
         active_price[i] = OrderOpenPrice();
         active_stoploss[i] = OrderStopLoss();
         active_takeprofit[i] = OrderTakeProfit();
         active_still_active[i] = false; // filled in the next tick
      }
   }
};

#endif
// AAction v1.0


#ifndef AAction_IMP
#define AAction_IMP

class AAction : public IAction
{
protected:
   int _references;
   AAction()
   {
      _references = 1;
   }
public:
   void AddRef()
   {
      ++_references;
   }

   void Release()
   {
      --_references;
      if (_references == 0)
         delete &this;
   }
};

#endif

TradingMonitor tradingMonitor;
Signaler signaler;

class OnTradeCloseAction : public AAction
{
public:
   virtual bool DoAction(const int period, const datetime date)
   {
      signaler.SendNotifications("Trade " + IntegerToString(OrderTicket()) + " closed");
      return true;
   }
};

class OnTradeOpenActionAction : public AAction
{
public:
   virtual bool DoAction(const int period, const datetime date)
   {
      signaler.SendNotifications("New trade opened: " + IntegerToString(OrderTicket()));
      return true;
   }
};

int OnInit()
{   
   OnTradeOpenActionAction* onNewTradeAction = new OnTradeOpenActionAction();
   tradingMonitor.SetOnNewOrder(onNewTradeAction);
   onNewTradeAction.Release();

   OnTradeCloseAction* onTradeClosedAction = new OnTradeCloseAction();
   tradingMonitor.SetClosedTradeAction(onTradeClosedAction);
   onTradeClosedAction.Release();

   return INIT_SUCCEEDED;
}

void OnDeinit(const int reason)
{
}

void OnTick()
{
   tradingMonitor.DoWork();
}

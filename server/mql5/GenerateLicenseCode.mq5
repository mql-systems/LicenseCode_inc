//+------------------------------------------------------------------+
//|                                          GenerateLicenseCode.mq5 |
//|                            Copyright 2021, Diamond Systems Corp. |
//|                                   https://github.com/mql-systems |
//+------------------------------------------------------------------+
#property copyright "Copyright 2021, Diamond Systems Corp."
#property link      "https://github.com/mql-systems"
#property version   "1.00"
#property script_show_inputs

//--- includes
#include <DS\LicenseCode\LicenseCode.mqh>

//--- enums
enum ENUM_GENERATE_LICENSE_CODE_TYPE
{
   GLCT_LIFETIME = 1,   // Lifetime
   GLCT_LIMITED  = 2,   // Limited
};


//--- inputs
input ENUM_GENERATE_LICENSE_CODE_TYPE  i_LicenseType = GLCT_LIFETIME;         // License type
input ulong                            i_AccountLogin = NULL;                 // Account login
input string                           i_LifetimeLicenseKey = "";             // Lifetime license key
input string                           i_s1 = "";                             // ======= For Limited license ========
input string                           i_LimitedLicenseKey = "";              // Limited license key
input datetime                         i_LimitedLicenseTime = __DATETIME__;   // Limited license datetime

//--- global variables
CLicenseCode LicenseCode;

//+------------------------------------------------------------------+
//| Script program start function                                    |
//+------------------------------------------------------------------+
void OnStart()
{
   ObjectsDeleteAll(ChartID(), "LicenseCode");
   
   //--- Check input parameters
   if (i_AccountLogin < 1)
   {
      Alert("ERROR: Account login");
      return;
   }
   else if (StringLen(i_LifetimeLicenseKey) < 1)
   {
      Alert("ERROR: Lifetime license key");
      return;
   }
   
   if (i_LicenseType == GLCT_LIMITED)
   {
      if (StringLen(i_LimitedLicenseKey) != 32)
      {
         Alert("ERROR: Limited license key");
         return;
      }
      else if (i_LimitedLicenseTime <= TimeCurrent())
      {
         Alert("ERROR: Limited license datetime");
         return;
      }
   }

   //--- Generate license code
   string lic;
   if (i_LicenseType == GLCT_LIFETIME)
      lic = "Lifetime license: "+LicenseCode.GenerateLicenseCode(i_AccountLogin, i_LifetimeLicenseKey);
   else
      lic = "Limited license: "+LicenseCode.GenerateLicenseCode(i_AccountLogin, i_LifetimeLicenseKey, i_LimitedLicenseKey, i_LimitedLicenseTime);
   
   if (StringLen(lic) > 40)
      CreateObjEdit(100, 100, "Limited license: Code in \"Toolbox > Experts\"");
   else
      CreateObjEdit(100, 100, lic);
   Print(lic);
}

void CreateObjEdit(const int x, const int y, const string text)
{
   long chartID = ChartID();
   string objName = "LicenseCode";
   
   ObjectCreate(chartID, objName, OBJ_EDIT, 0, 0, 0);
   //---
   ObjectSetInteger(chartID, objName, OBJPROP_XDISTANCE, x);
   ObjectSetInteger(chartID, objName, OBJPROP_YDISTANCE, y);
   ObjectSetInteger(chartID, objName, OBJPROP_XSIZE, 500);
   ObjectSetInteger(chartID, objName, OBJPROP_YSIZE, 40);
   ObjectSetString(chartID, objName, OBJPROP_TEXT, text);
   // ObjectSetInteger(chartID, objName, OBJPROP_ALIGN, align);
}

//+------------------------------------------------------------------+

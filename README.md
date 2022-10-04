# License Code Library (Multi-MQL)

Multi-MQL library for licensing systems written in the MQL4 and MQL5 languages.

## Install

```bash
git clone https://github.com/mql-systems/LicenseCode_inc.git MqlIncludes/DS/LicenseCode

cd YourMT4(or5)Terminal/MQL4(or5)/Include
mkdir DS
ln -s MqlIncludes/DS/LicenseCode ./DS/LicenseCode
```

## Generating keys and licenses

Servers for generating keys and licenses

- [PHP](https://github.com/mql-systems/LicenseCode_inc/tree/main/server/php)
- [MQL4](https://github.com/mql-systems/LicenseCode_inc/tree/main/server/mql4)
- [MQL5](https://github.com/mql-systems/LicenseCode_inc/tree/main/server/mql5)

## Usage example

```mql5
#include <DS\LicenseCode\LicenseCode.mqh>

CLicenseCode LicenseCode;

input string i_LicenseCode = ""; // License code

int OnInit()
{
   //--- For a Lifetime license
   LicenseCode.Init(i_LicenseCode, "KeyLifetime");

   //--- For a Limited license
   // LicenseCode.Init(i_LicenseCode, "KeyLifetime", "KeyLimited");
}

void OnTick()
{
   //--- License verifcation
   if (! LicenseCode.CheckLicense())
   {
      if (LicenseCode.GetLicenseStatus() == -1)
         Comment("ERROR: License invalid - ",i_LicenseCode);
   }
   else
      Comment("Price: ", SymbolInfoDouble(Symbol(), SYMBOL_BID));
}
```

Ready-made examples in the "[examples](https://github.com/mql-systems/LicenseCode_inc/tree/main/examples)" folder.
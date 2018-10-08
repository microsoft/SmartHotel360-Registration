using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace SmartHotel.Registration.Wcf.Data.Generators
{
    public class CultureGenerator
    {
        public static string GetLanguageFromCultureCode(string code)
        {
            if (code == "de-de") return "German";
            if (code == "es-US") return "Spanish";
            if (code == "fr-FR") return "French";

            return "English";
        }

        public List<String> Cultures
        {
            get
            {
                return new string[]
                {
                    "en-us",
                    "de-de",
                    "es-US",
                    "fr-FR"
                }.ToList();
            }
        }
    }
}
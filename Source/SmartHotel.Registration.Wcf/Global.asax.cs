using SmartHotel.Registration.Wcf.Services;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using System.Web;
using System.Web.Security;
using System.Web.SessionState;

namespace SmartHotel.Registration.Wcf
{
    public class Global : System.Web.HttpApplication
    {

        async void Application_Start(object sender, EventArgs e)
        {
            var isStoreKPIEnabled = Environment.GetEnvironmentVariable("UseStoreKPIsStatefulService");
            if (isStoreKPIEnabled == bool.TrueString)
            {
                await UpdateRegistrationKPIStatefulService();
            }
        }

        async Task UpdateRegistrationKPIStatefulService()
        {
            var registrationKPIService = new RegistrationKPIService();
            await registrationKPIService.SendBookingListInfo();
        }
    }
}
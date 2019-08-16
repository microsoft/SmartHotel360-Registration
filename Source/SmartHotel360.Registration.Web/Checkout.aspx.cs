using SmartHotel360.Registration.Data;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace SmartHotel360.Registration
{
    public partial class Checkout : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (IsPostBack)
                return;

            var registrationProvided =
                int.TryParse(Request.QueryString["registration"], out int registrationId);
            if (!registrationProvided)
                Response.Redirect("Default.aspx");

            using (var client = ServiceClientFactory.NewServiceClient())
            {
                var checkin = client.GetCheckout(registrationId);
                CustomerName.Value = checkin.CustomerName;
                Passport.Value = checkin.Passport;
                CustomerId.Value = checkin.CustomerId;
                Address.Value = checkin.Address;
                Amount.Value = checkin.Amount.ToString();
            }
        }

        protected void BackBtn_Click(Object sender, EventArgs e)
        {
            Response.Redirect($"Default.aspx");
        }
    }
}
using SmartHotel.Registration.Data;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace SmartHotel.Registration
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
                var checkout = client.GetCheckout(registrationId);
                CustomerName.Value = checkout.CustomerName;
                Passport.Value = checkout.Passport;
                CustomerId.Value = checkout.CustomerId;
                Address.Value = checkout.Address;
                Amount.Value = checkout.Amount.ToString();
                Floor.Value = checkout.Floor.ToString();
                RoomNumber.Value = checkout.RoomNumber.ToString();
                CreditCard.Attributes["value"] = checkout.CreditCard;
                Total.Value = checkout.Total.ToString();
            }
        }

        protected void BackBtn_Click(Object sender, EventArgs e)
        {
            Response.Redirect($"Default.aspx");
        }

        protected void CheckoutBtn_Click(Object sender, EventArgs e)
        {
           
        }
    }
}
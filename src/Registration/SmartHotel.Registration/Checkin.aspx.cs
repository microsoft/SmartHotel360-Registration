using SmartHotel.Registration.Data;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace SmartHotel.Registration
{
    public partial class Checkin : Page
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
                var checkin = client.GetCheckin(registrationId);

                CustomerName.Value = checkin.CustomerName;
                Passport.Value = checkin.Passport;
                CustomerId.Value = checkin.CustomerId;
                Address.Value = checkin.Address;
                Amount.Value = checkin.Amount.ToString();
                Floor.Value = checkin.Floor.ToString();
                RoomNumber.Value = checkin.RoomNumber.ToString();
                CreditCard.Attributes["value"] = checkin.CreditCard;
                Total.Value = checkin.Total.ToString();
            }
        }

        protected void BackBtn_Click(Object sender, EventArgs e)
        {
            Response.Redirect($"Default.aspx");
        }

        protected void CheckinBtn_Click(Object sender, EventArgs e)
        {
            var registrationId = int.Parse(Request.QueryString["registration"]);

            using (var client = ServiceClientFactory.NewServiceClient())
            {
                client.PostCheckin(registrationId);
            }

            Response.Redirect($"Default.aspx");
        }
    }
}
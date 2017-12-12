using Newtonsoft.Json;
using SmartHotel.Model;
using System;
using System.Collections.Generic;
using System.Net.Http;
using System.Net.Http.Headers;
using System.Threading.Tasks;
using System.Web.UI;
using System.Web.UI.HtmlControls;
using System.Web.UI.WebControls;

namespace SmartHotel.Registration
{
    public partial class _Default : Page
    {
        protected async void Page_Load(object sender, EventArgs e)
        {
            if (IsPostBack)
                return;

            using (var client = ServiceClientFactory.NewServiceClient())
            {
                var registrations = client.GetTodayRegistrations();
                RegistrationGrid.DataSource = registrations;
                RegistrationGrid.DataBind();
            }

            using (var client = new HttpClient())
            {
                var hostIp = Environment.GetEnvironmentVariable("Fabric_NodeIPOrFQDN");

                client.BaseAddress = new Uri($"http://{hostIp}:19081/");
                client.DefaultRequestHeaders.Accept.Clear();
                client.DefaultRequestHeaders.Accept.Add(new MediaTypeWithQualityHeaderValue("application/json"));

                var JsonSentiments = "";

                HttpResponseMessage response = await client.GetAsync("SmartHotel.RegistrationApp/SentimentIntegration/api/values");
                if (response.IsSuccessStatusCode)
                {
                    JsonSentiments = await response.Content.ReadAsStringAsync();
                }

                var sentiments = JsonConvert.DeserializeObject<List<Tweet>>(JsonSentiments);

                var sentimentControl = Page.Master.FindControl("Sentiments") as HtmlGenericControl;
                sentimentControl.InnerText = sentiments.Count.ToString();

            }
        }

        protected void RegistrationGrid_SelectedIndexChanged(Object sender, EventArgs e)
        {
            GridViewRow row = RegistrationGrid.SelectedRow;

            var registrationId = RegistrationGrid.DataKeys[RegistrationGrid.SelectedIndex]["Id"];
            var registrationType = RegistrationGrid.DataKeys[RegistrationGrid.SelectedIndex]["Type"].ToString();

            if (registrationType == "CheckIn")
            {
                Response.Redirect($"Checkin.aspx?registration={registrationId}");
            }

            if (registrationType == "CheckOut")
            {
                Response.Redirect($"Checkout.aspx?registration={registrationId}");
            }
        }

        protected void RegistrationGrid_RowDataBound(object sender, GridViewRowEventArgs e)
        {
            if (e.Row.RowType != DataControlRowType.DataRow)
                return;
            e.Row.Attributes["onclick"] = Page.ClientScript.GetPostBackClientHyperlink(RegistrationGrid, "Select$" + e.Row.RowIndex);
        }
    }
}
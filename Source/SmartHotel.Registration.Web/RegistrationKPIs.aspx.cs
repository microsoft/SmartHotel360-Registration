using Newtonsoft.Json;
using SmartHotel.Registration.Models;
using SmartHotel.Registration.Services;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Net.Http;
using System.Net.Http.Headers;
using System.Text;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace SmartHotel.Registration
{
    public partial class RegistrationKPIs : System.Web.UI.Page
    {       
        protected async void Page_Load(object sender, EventArgs e)
        {
            if (IsPostBack)
                return;

            var hostIp = Environment.GetEnvironmentVariable("Fabric_NodeIPOrFQDN");
            var fullAppName = Environment.GetEnvironmentVariable("Fabric_ApplicationName");
            var appName = fullAppName.Substring(8);

            var registrationKPIService = new RegistrationKPIService();
            var result = await registrationKPIService.GetBookingListInfo();

            DropdownlistSetup(result);
            ChartAllSetup(result);
        }

        protected async void Selection_Change(Object sender, EventArgs e)
        {
            var registrationKPIService = new RegistrationKPIService();

            if (CustomerList.SelectedItem.Value.Equals("All"))
            {
                var result = await registrationKPIService.GetBookingListInfo();
                ChartAllSetup(result);
            }
            else
            {
                var bookingAggregates = await registrationKPIService.GetBookingInfo(CustomerList.SelectedItem.Value);
                ChartPerCustomerSetup(bookingAggregates);
            }                        
        }

        private void DropdownlistSetup(List<BookingAggregates> bookingAggregates)
        {
            foreach (var bookingAggregate in bookingAggregates)
            {
                CustomerList.Items.Add(new ListItem(bookingAggregate.Name, bookingAggregate.Passport));
            }
        }

        private void ChartAllSetup(List<BookingAggregates> bookingAggregates)
        {
            Chart.ImageStorageMode = System.Web.UI.DataVisualization.Charting.ImageStorageMode.UseHttpHandler;

            Chart.Series["NumberOfCheckin"].Points.AddXY("Winter", bookingAggregates.Sum(x => x.NumberOfCheckinWinterSeason));
            Chart.Series["NumberOfCheckin"].Points.AddXY("Spring", bookingAggregates.Sum(x => x.NumberOfCheckinSpringSeason));
            Chart.Series["NumberOfCheckin"].Points.AddXY("Summer", bookingAggregates.Sum(x => x.NumberOfCheckinSummerSeason));
            Chart.Series["NumberOfCheckin"].Points.AddXY("Autumn", bookingAggregates.Sum(x => x.NumberOfCheckinAutumnSeason));
        }

        private void ChartPerCustomerSetup(BookingAggregates bookingAggregates)
        {
            Chart.ImageStorageMode = System.Web.UI.DataVisualization.Charting.ImageStorageMode.UseHttpHandler;

            Chart.Series["NumberOfCheckin"].Points.AddXY("Winter", bookingAggregates.NumberOfCheckinWinterSeason);
            Chart.Series["NumberOfCheckin"].Points.AddXY("Spring", bookingAggregates.NumberOfCheckinSpringSeason);
            Chart.Series["NumberOfCheckin"].Points.AddXY("Summer", bookingAggregates.NumberOfCheckinSummerSeason);
            Chart.Series["NumberOfCheckin"].Points.AddXY("Autumn", bookingAggregates.NumberOfCheckinAutumnSeason);
        }

        protected void CancelBtn_Click(Object sender, EventArgs e)
        {
            Response.Redirect($"Default.aspx");
        }
    }
}
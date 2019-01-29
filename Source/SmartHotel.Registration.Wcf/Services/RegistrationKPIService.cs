using Newtonsoft.Json;
using SmartHotel.Registration.Wcf.Data;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Net.Http;
using System.Net.Http.Headers;
using System.Text;
using System.Threading.Tasks;
using System.Web;

namespace SmartHotel.Registration.Wcf.Services
{
    public class RegistrationKPIService
    {
        private readonly string _hostIp;
        private readonly string _fullAppName;
        private readonly string _appName;

        public RegistrationKPIService()
        {
            _hostIp = Environment.GetEnvironmentVariable("Fabric_NodeIPOrFQDN") ?? throw new ArgumentException();
            _fullAppName = Environment.GetEnvironmentVariable("Fabric_ApplicationName") ?? throw new ArgumentException();
            _appName = _fullAppName.Substring(8);
        }



        public async Task SendBookingListInfo()
        {
            using (var db = new BookingsDbContext())
            {
                var registrationList = db.Bookings
                    .Select(BookingToCheckin)
                    .ToList();

                if (registrationList.Count > 0)
                {
                    using (var client = new HttpClient())
                    {
                        client.BaseAddress = new Uri($"http://{_hostIp}:19081/");
                        client.DefaultRequestHeaders.Accept.Clear();
                        client.DefaultRequestHeaders.Accept.Add(new MediaTypeWithQualityHeaderValue("application/json"));

                        foreach (var reg in registrationList)
                        {
                            var partitionKey = Char.ToUpper(reg.Passport.First());
                            var postContent = new StringContent(JsonConvert.SerializeObject(reg), Encoding.UTF8, "application/json");
                            postContent.Headers.ContentType = new MediaTypeHeaderValue("application/json");
                            var response = await client.PostAsync($"{_appName}/SmartHotel.Registration.StoreKPIs/api/values?key={reg.Passport}&PartitionKey={partitionKey}&PartitionKind=Int64Range", postContent);
                            response.EnsureSuccessStatusCode();
                        }
                    }
                }
            }
        }

        public async Task SendBookingInfo(Data.Booking booking)
        {
            using (var client = new HttpClient())
            {
                client.BaseAddress = new Uri($"http://{_hostIp}:19081/");
                client.DefaultRequestHeaders.Accept.Clear();
                client.DefaultRequestHeaders.Accept.Add(new MediaTypeWithQualityHeaderValue("application/json"));

                var partitionKey = Char.ToUpper(booking.Passport.First());
                var postContent = new StringContent(JsonConvert.SerializeObject(booking), Encoding.UTF8, "application/json");
                postContent.Headers.ContentType = new MediaTypeHeaderValue("application/json");
                var response = await client.PostAsync($"{_appName}/SmartHotel.Registration.StoreKPIs/api/values?key={booking.Passport}&PartitionKey={partitionKey}&PartitionKind=Int64Range", postContent);
                response.EnsureSuccessStatusCode();
            }
        }

        private Models.Registration BookingToCheckin(Booking booking)
        {
            return new Models.Registration
            {
                Id = booking.Id,
                Type = "CheckIn",
                Date = booking.From,
                CustomerId = booking.CustomerId,
                CustomerName = booking.CustomerName,
                Passport = booking.Passport,
                Address = booking.Address,
                Amount = booking.Amount,
                From = booking.From,
                To = booking.To,
                Total = booking.Total
            };
        }
    }
}
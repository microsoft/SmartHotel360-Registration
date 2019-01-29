using Newtonsoft.Json;
using SmartHotel.Registration.Data;
using SmartHotel.Registration.Models;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Net.Http;
using System.Net.Http.Headers;
using System.Text;
using System.Threading.Tasks;
using System.Web;

namespace SmartHotel.Registration.Services
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

        public async Task<List<BookingAggregates>> GetBookingListInfo()
        {
            var result = new List<BookingAggregates>();
            using (var client = new HttpClient())
            {
                client.BaseAddress = new Uri($"http://{_hostIp}:19081/");
                client.DefaultRequestHeaders.Accept.Clear();
                client.DefaultRequestHeaders.Accept.Add(new MediaTypeWithQualityHeaderValue("application/json"));                
                for (int partitionKey = 0; partitionKey <= 9; partitionKey++)
                {
                    var response = await client.GetAsync($"{_appName}/SmartHotel.Registration.StoreKPIs/api/values?PartitionKey={partitionKey}&PartitionKind=Int64Range");
                    response.EnsureSuccessStatusCode();
                    var data = JsonConvert.DeserializeObject<List<KeyValuePair<string, BookingAggregates>>>(await response.Content.ReadAsStringAsync());
                    var bookingAggregateList = data.Select(x => x.Value);
                    result.AddRange(bookingAggregateList);
                }                
            }
            return result;
        }

        public async Task<BookingAggregates> GetBookingInfo(string key)
        {
            using (var client = new HttpClient())
            {
                client.BaseAddress = new Uri($"http://{_hostIp}:19081/");
                client.DefaultRequestHeaders.Accept.Clear();
                client.DefaultRequestHeaders.Accept.Add(new MediaTypeWithQualityHeaderValue("application/json"));
                var partitionKey = Char.ToUpper(key.First());
                var response = await client.GetAsync($"{_appName}/SmartHotel.Registration.StoreKPIs/api/values/{key}?PartitionKey={partitionKey}&PartitionKind=Int64Range");
                response.EnsureSuccessStatusCode();
                return JsonConvert.DeserializeObject<BookingAggregates>(await response.Content.ReadAsStringAsync());
            }
        }
    }
}
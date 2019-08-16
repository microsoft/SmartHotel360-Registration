using SmartHotel360.Registration.Data;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace SmartHotel360.Registration
{
    public static class ServiceClientFactory
    {
        public static ServiceClient NewServiceClient()
        {
            var client = new ServiceClient();
            var uri = Environment.GetEnvironmentVariable("WcfServiceUri");

            if (!string.IsNullOrEmpty(uri))
            {
                client.Endpoint.Address = new System.ServiceModel.EndpointAddress(uri);
            }

            return client;

        }
    }
}
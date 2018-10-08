using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace SmartHotel.Registration.Wcf.Data
{
    public class Booking
    {
        public int Id { get; set; }
        public byte[] RowVersion { get; set; }
        public DateTime From { get; set; }
        public DateTime To { get; set; }
        public string CustomerId { get; set; }
        public string CustomerName { get; set; }
        public string Passport { get; set; }
        public string Address { get; set; }
        public int Amount { get; set; }
        public int Total { get; set; }
        public string Type { get; set; }
        public string Culture { get; set; }
        public string PhoneNumber { get; set; }
    }
}
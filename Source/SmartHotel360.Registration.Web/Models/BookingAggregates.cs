using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace SmartHotel360.Registration.Models
{
    public class BookingAggregates
    {
        public string Name { get; set; }
        public string Passport { get; set; }
        public int TotalCheckin { get; set; }
        public int NumberOfCheckinWinterSeason { get; set; }
        public int NumberOfCheckinSpringSeason { get; set; }
        public int NumberOfCheckinSummerSeason { get; set; }
        public int NumberOfCheckinAutumnSeason { get; set; }
    }
}
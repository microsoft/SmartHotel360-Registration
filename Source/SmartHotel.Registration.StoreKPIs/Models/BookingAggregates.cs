using System;
using System.Collections.Generic;
using System.Linq;
using System.Runtime.Serialization;
using System.Threading.Tasks;

namespace SmartHotel.Registration.StoreKPIs.Models
{
    [Serializable]
    public class BookingAggregates
    {
        public BookingAggregates(Booking booking)
        {
            Name = booking.CustomerName;
            Passport = booking.Passport;
            Compute(booking);
        }

        public string Name { get; set; }
        public string Passport { get; set; }
        public int TotalCheckin { get; set; }
        public int NumberOfCheckinWinterSeason { get; set; } 
        public int NumberOfCheckinSpringSeason { get; set; } 
        public int NumberOfCheckinSummerSeason { get; set; } 
        public int NumberOfCheckinAutumnSeason { get; set; }

        public void Update(Booking booking) => 
            Compute(booking);

        private void Compute(Booking booking)
        {
            var month = booking.From.Month;
            
            if (month >= 12 || month < 03)
                NumberOfCheckinWinterSeason++;
            else if (month >= 09)
                NumberOfCheckinAutumnSeason++;
            else if (month >= 06)
                NumberOfCheckinSummerSeason++;
            else if (month >= 03)
                NumberOfCheckinSpringSeason++;

            TotalCheckin = NumberOfCheckinAutumnSeason +
                NumberOfCheckinSpringSeason +
                NumberOfCheckinSummerSeason +
                NumberOfCheckinWinterSeason;

        }
    }
}

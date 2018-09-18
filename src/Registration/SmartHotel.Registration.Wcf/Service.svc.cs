using System;
using System.Collections.Generic;
using System.Linq;
using System.Runtime.Serialization;
using System.ServiceModel;
using System.ServiceModel.Web;
using System.Text;
using SmartHotel.Registration.Wcf.Models;
using SmartHotel.Registration.Wcf.Data;

namespace SmartHotel.Registration.Wcf
{
    [ServiceBehavior(IncludeExceptionDetailInFaults = true)]
    public class Service : IService
    {
        public IEnumerable<Models.Registration> GetTodayRegistrations()
        {
            using (var db = new BookingsDbContext())
            {
                var checkins = db.Bookings
                .Where(b => b.From == DateTime.Today)
                .OrderByDescending(t => t.From)
                .Select(BookingToCheckin);

                var checkouts = db.Bookings
                    .Where(b => b.To == DateTime.Today)
                    .OrderByDescending(t=> t.To)
                    .Select(BookingToCheckout);

                var registrations = checkins.Concat(checkouts).OrderBy(r => r.Date);
                return registrations.ToList();
            }
        }

        public RegistrationDaySummary GetTodayRegistrationSummary()
        {
            using (var db = new BookingsDbContext())
            {
                var totalCheckins = db.Bookings
                .Count(b => b.From == DateTime.Today);

                var totalCheckouts = db.Bookings
                    .Count(b => b.To == DateTime.Today);

                var summary = new RegistrationDaySummary
                {
                    Date = DateTime.Today,
                    CheckIns = totalCheckins,
                    CheckOuts = totalCheckouts
                };

                return summary;
            }
        }

        public Models.Registration GetCheckin(int registrationId)
        {
            using (var db = new BookingsDbContext())
            {
                var checkin = db.Bookings
                .Where(b => b.Id == registrationId)
                .Select(BookingToCheckin)
                .First();

                return checkin;
            }
        }

        public void PostCheckin(int registrationId)
        {
            using (var db = new BookingsDbContext())
            {
                var booking = db.Bookings
                .Where(b => b.Id == registrationId)
                .First();

                booking.From = DateTime.Today.AddHours(-1);
                booking.To = DateTime.Today;

                db.SaveChanges();
            }
        }

        public Models.Registration GetCheckout(int registrationId)
        {
            using (var db = new BookingsDbContext())
            {
                var checkout = db.Bookings
                .Where(b => b.Id == registrationId)
                .Select(BookingToCheckin)
                .First();

                return checkout;
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
                Total = booking.Total,
                Floor = booking.Floor,
                RoomNumber = booking.RoomNumber,
                CreditCard = booking.CreditCard
            };
        }

        private Models.Registration BookingToCheckout(Booking booking)
        {
            return new Models.Registration
            {
                Id = booking.Id,
                Type = "CheckOut",
                Date = booking.To,
                CustomerId = booking.CustomerId,
                CustomerName = booking.CustomerName,
                Passport = booking.Passport,
                Address = booking.Address,
                Amount = booking.Amount,
                Total = booking.Total,
                Floor = booking.Floor,
                RoomNumber = booking.RoomNumber,
                CreditCard = booking.CreditCard
            };
        }
    }
}

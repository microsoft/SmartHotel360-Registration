using System;
using System.Collections.Generic;
using System.Linq;
using System.Runtime.Serialization;
using System.ServiceModel;
using System.ServiceModel.Web;
using System.Text;
using SmartHotel.Registration.Wcf.Models;
using SmartHotel.Registration.Wcf.Data;
using SmartHotel.Registration.Wcf.Data.Generators;

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
                    .Where(b => b.From == DateTime.Today ||
                                b.To == DateTime.Today)
                    .Select(ConvertToRegistration);

                var registrations = checkins.OrderBy(r => r.CustomerName);
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
                db.Bookings.Single(b => b.Id == registrationId).Type = "CheckOut";
                db.SaveChanges();
                return ConvertToRegistration(db.Bookings.Single(b => b.Id == registrationId));
            }
        }

        public Models.Registration GetCheckout(int registrationId)
        {
            using (var db = new BookingsDbContext())
            {
                db.Bookings.Single(b => b.Id == registrationId).Type = "CheckIn";
                db.SaveChanges();
                return ConvertToRegistration(db.Bookings.Single(b => b.Id == registrationId));
            }
        }

        private Models.Registration ConvertToRegistration(Booking booking)
        {
            return new Models.Registration
            {
                Id = booking.Id,
                Type = booking.Type,
                Date = booking.To,
                CustomerId = booking.CustomerId,
                CustomerName = booking.CustomerName,
                Passport = booking.Passport,
                Address = booking.Address,
                Amount = booking.Amount,
                Total = booking.Total,
                Culture = CultureGenerator.GetLanguageFromCultureCode(booking.Culture),
                PhoneNumber = booking.PhoneNumber
            };
        }
    }
}

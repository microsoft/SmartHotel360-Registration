using SmartHotel360.Registration.Wcf.Data;
using SmartHotel360.Registration.Wcf.Models;
using System;
using System.Collections.Generic;
using System.Linq;
using System.ServiceModel;

namespace SmartHotel360.Registration.Wcf
{
    [ServiceBehavior(IncludeExceptionDetailInFaults = true)]
    public class Service : IService
    {
        public IEnumerable<Models.Registration> GetRegistrations()
        {
            using (var db = new BookingsDbContext())
            {
                var registrations = db.Bookings
                    .Select(BookingToCheckin);

                return registrations.ToList();
            }
        }

        public IEnumerable<Models.Registration> GetTodayRegistrations()
        {
            using (var db = new BookingsDbContext())
            {
                var checkins = db.Bookings
                .Where(b => b.From == DateTime.Today)
                .Select(BookingToCheckin);

                var checkouts = db.Bookings
                    .Where(b => b.To == DateTime.Today)
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

        public void PostRegister(Booking booking)
        {
            using (var db = new BookingsDbContext())
            {
                var checkin = db.Bookings.Add(booking);
                db.SaveChanges();
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
                From = booking.From,
                To = booking.To,
                Address = booking.Address,
                Amount = booking.Amount,
                Total = booking.Total
            };
        }
    }
}

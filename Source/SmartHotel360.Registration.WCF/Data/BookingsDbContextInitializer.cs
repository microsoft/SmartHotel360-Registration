using SmartHotel360.Registration.Wcf.Data.Generators;
using SmartHotel360.Registration.Wcf.Data.Generators.Generators;
using System;
using System.Collections.Generic;
using System.Data.Entity;
using System.Linq;
using System.Web;

namespace SmartHotel360.Registration.Wcf.Data
{
    public class BookingsDbContextInitializer
        : CreateDatabaseIfNotExists<BookingsDbContext>
    {
        protected override void Seed(BookingsDbContext context)
        {
            var random = new Random();
            var addressGenerator = new AddressGenerator();
            var userNameGenerator = new UserNameGenerator();
            var passportGenerator = new PassportGenerator();

            for (int i = 0; i < 60; i++)
            {
                var fromDate = DateTime.Today.AddDays(random.Next(-2, 5));
                var toDate = fromDate.AddDays(random.Next(1, 5));

                context.Bookings.Add(new Booking
                {
                    CustomerId = "Cust-10" + i,
                    CustomerName = userNameGenerator.GetName(),
                    Address = addressGenerator.GetAddress(),
                    From = fromDate,
                    To = toDate,
                    Passport = passportGenerator.GetPassport(),
                    Amount = random.Next(10, 40) * 100
                });
            }

            context.SaveChanges();

            base.Seed(context);
        }
    }
}
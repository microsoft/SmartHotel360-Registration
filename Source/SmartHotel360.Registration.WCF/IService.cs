using SmartHotel360.Registration.Wcf.Data;
using SmartHotel360.Registration.Wcf.Models;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Runtime.Serialization;
using System.ServiceModel;
using System.ServiceModel.Web;
using System.Text;

namespace SmartHotel360.Registration.Wcf
{
    // NOTE: You can use the "Rename" command on the "Refactor" menu to change the interface name "IService1" in both code and config file together.
    [ServiceContract]
    public interface IService
    {
        [OperationContract]
        IEnumerable<Models.Registration> GetRegistrations();

        [OperationContract]
        IEnumerable<Models.Registration> GetTodayRegistrations();

        [OperationContract]
        RegistrationDaySummary GetTodayRegistrationSummary();

        [OperationContract]
        Models.Registration GetCheckin(int registrationId);

        [OperationContract]
        Models.Registration GetCheckout(int registrationId);

        [OperationContract]
        void PostRegister(Booking booking);
    }
}

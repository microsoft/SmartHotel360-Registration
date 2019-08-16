<%@ Page Language="C#" Async="true" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="Register.aspx.cs" Inherits="SmartHotel360.Registration.Register" %>

<asp:Content ID="BodyContent" ContentPlaceHolderID="MainContent" runat="server">
    <section class="sh-form">
        <h2 class="sh-title">Customer Reservation</h2>
        <div class="sh-form_wrapper">
            <div class="row">
                <section class="col-sm-6 customer-information">
                    <span class="sh-subtitle">Customer's information</span>
                    <div class="form-group">
                        <label class="sh-label" for="CustomerName">CUSTOMER NAME</label>
                        <input class="sh-input form-control" id="CustomerName" type="text" runat="server" />
                    </div>
                    <div class="form-group">
                        <label class="sh-label" for="Passport">PASSPORT Nº</label>
                        <input class="sh-input form-control" id="Passport" type="text" runat="server" />
                    </div>                   
                    <div class="form-group">
                        <label class="sh-label" for="Address">ADDRESS</label>
                        <input class="sh-input form-control" id="Address" type="text" runat="server" />
                    </div>                  
                </section>
                <section class="col-sm-6 room-information">
                    <span class="sh-subtitle">Room's information</span>
                    <div class="form-group">
                        <label class="sh-label" for="RoomType">ROOM TYPE</label>
                        <select class="sh-input form-control" id="RoomType">
                            <option class="sh-input_option" value="Double Room">Double Room</option>
                            <option class="sh-input_option" value="Single Room">Single Room</option>
                        </select>
                    </div>
                    <div class="form-group">
                        <label class="sh-label" for="RoomNumber">ROOM NUMBER</label>
                        <input class="sh-input form-control" id="RoomNumber" type="text" runat="server" />
                    </div>
                    <div class="form-group">
                        <label class="sh-label" for="Amount">AMOUNT</label>
                        <input class="sh-input form-control" id="Amount" type="text" runat="server"/>
                    </div>                   
                </section>
            </div>
            <div class="row">
                <section class="col-sm-6">
                    <div class="form-group">
                        <label class="sh-label" for="From">FROM</label>
                        <asp:Calendar id="Calendar1" runat="server"  SelectionMode="DayWeekMonth"></asp:Calendar>
                    </div>
                    
                </section>
                <section class="col-sm-6">      
                    <div class="form-group">
                        <label class="sh-label" for="From">TO</label>
                        <asp:Calendar id="Calendar2" runat="server"  SelectionMode="DayWeekMonth"></asp:Calendar>
                    </div>
                </section>
            </div>
            <br />
            <div class="row">
                <section class="col-sm-6">      
                    <div class="form-group">
                        <asp:Button ID="Button1" class="btn btn-success" runat="server" OnClick="AddRegisterBtn_Click"  Text="Register" />
                        <asp:Button ID="Button2" class="btn btn-secondary" runat="server" OnClick="CancelBtn_Click"  Text="Cancel" />
                    </div>
                </section>
            </div>
            
        </div>
    </section>
</asp:Content>

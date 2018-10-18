<%@ Page Title="About" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="Checkin.aspx.cs" Inherits="SmartHotel.Registration.Checkin" %>

<asp:Content ID="BodyContent" ContentPlaceHolderID="MainContent" runat="server">
    <section class="sh-form">
        <h2 class="sh-title">Customer Check In</h2>
        <div class="sh-form_wrapper">
            <div class="row">
                <asp:Button ID="cancel_btn" class="sh-close-btn btn pull-right" runat="server" OnClick="BackBtn_Click"/>
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
                        <label class="sh-label" for="CustomerId">CUSTOMER ID</label>
                        <input class="sh-input form-control" id="CustomerId" type="text" runat="server" disabled />
                    </div>
                    <div class="form-group">
                        <label class="sh-label" for="Address">ADDRESS</label>
                        <input class="sh-input form-control" id="Address" type="text" runat="server" />
                    </div>
                    <div class="form-group">
                        <label class="sh-label" for="CreditCard">CREDIT CARD</label>
                        <asp:TextBox ID="CreditCard" class="sh-input form-control" TextMode="Password" runat="server" disabled />
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
                        <label class="sh-label" for="Floor">FLOOR</label>
                        <input class="sh-input form-control" id="Floor" type="text" runat="server" />
                    </div>
                    <div class="form-group">
                        <label class="sh-label" for="Amount">AMOUNT</label>
                        <input class="sh-input form-control" id="Amount" type="text" runat="server" disabled />
                    </div>
                    <div class="form-group">
                        <label class="sh-label" for="Total">TOTAL</label>
                        <input class="sh-input form-control" id="Total" type="text" runat="server" disabled />
                    </div>
                    <div class="form-group">
                        <asp:Button ID="checkin_btn" class="sh-button btn pull-right" runat="server" OnClick="CheckinBtn_Click" Text="CHECK IN"/>
                    </div>                    
                </section>
            </div>
        </div>
    </section>
</asp:Content>

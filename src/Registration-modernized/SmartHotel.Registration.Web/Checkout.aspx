<%@ Page Title="About" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true" CodeBehind="Checkout.aspx.cs" Inherits="SmartHotel.Registration.Checkout" %>

<asp:Content ID="BodyContent" ContentPlaceHolderID="MainContent" runat="server">
    <h2>Customer Check Out</h2>
    <section>
        <section class="customer-information">
            <div>
                <label for="CustomerName">CUSTOMER NAME</label>
                <input id="CustomerName" type="text" runat="server" />
            </div>
            <div>
                <label for="Passport">PASSPORT Nº</label>
                <input id="Passport" type="text" runat="server" />
            </div>
            <div>
                <label for="CustomerId">CUSTOMER ID</label>
                <input id="CustomerId" type="text" runat="server" disabled />
            </div>
            <div>
                <label for="Address">ADDRESS</label>
                <input id="Address" type="text" runat="server" />
            </div>
        </section>
        <section class="room-information">
            <div>
                <label for="RoomType">ROOM TYPE</label>
                <select id="RoomType">
                    <option value="Double Room" />
                    <option value="Single Room" />
                </select>
            </div>
            <div>
                <label for="RoomNumber">ROOM Nº</label>
                <input id="RoomNumber" type="text" runat="server" />
            </div>
            <div>
                <label for="Amount">AMOUNT</label>
                <input id="Amount" type="text" runat="server" disabled/>
            </div>
            <div>
                <label for="Total">TOTAL</label>
                <input id="Total" type="text" runat="server" disabled />
            </div>
        </section>
    </section>
</asp:Content>